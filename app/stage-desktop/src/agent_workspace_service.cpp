#include "agent_workspace_service.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QStringList>
#include <QTextStream>
#include <QVariantMap>

namespace {

bool isWorkspaceRoot(const QDir& dir)
{
    return dir.exists(QStringLiteral("CMakeLists.txt"))
        && dir.exists(QStringLiteral("app/stage-desktop/qml"));
}

QString statusLabel(const QString& status)
{
    if (status.contains(QLatin1Char('?'))) {
        return QStringLiteral("新增");
    }
    if (status.contains(QLatin1Char('D'))) {
        return QStringLiteral("删除");
    }
    if (status.contains(QLatin1Char('R'))) {
        return QStringLiteral("重命名");
    }
    if (status.contains(QLatin1Char('A'))) {
        return QStringLiteral("新增");
    }
    return QStringLiteral("修改");
}

QString normalizeRelativePath(QString path)
{
    path = path.trimmed();
    if (path.startsWith(QStringLiteral("\"")) && path.endsWith(QStringLiteral("\"")) && path.size() > 1) {
        path = path.mid(1, path.size() - 2);
    }
    const int renameArrow = path.indexOf(QStringLiteral(" -> "));
    if (renameArrow >= 0) {
        path = path.mid(renameArrow + 4).trimmed();
    }
    return QDir::cleanPath(path);
}

QString firstLine(const QString& text)
{
    const QStringList lines = text.split(QLatin1Char('\n'), Qt::SkipEmptyParts);
    return lines.isEmpty() ? QString() : lines.constFirst().trimmed();
}

} // namespace

AgentWorkspaceService::AgentWorkspaceService(QObject* parent)
    : QObject(parent)
    , m_workspacePath(resolveWorkspacePath())
{
}

QString AgentWorkspaceService::workspacePath() const
{
    return m_workspacePath;
}

QString AgentWorkspaceService::workspaceName() const
{
    return QFileInfo(m_workspacePath).fileName();
}

QString AgentWorkspaceService::repoName() const
{
    return workspaceName();
}

QString AgentWorkspaceService::branchName() const
{
    QString branch = firstLine(runGit({QStringLiteral("branch"), QStringLiteral("--show-current")}));
    if (branch.isEmpty()) {
        branch = firstLine(runGit({QStringLiteral("rev-parse"), QStringLiteral("--short"), QStringLiteral("HEAD")}));
    }
    if (branch.isEmpty()) {
        return QStringLiteral("无 Git");
    }
    const bool dirty = !runGit({QStringLiteral("status"), QStringLiteral("--short")}).trimmed().isEmpty();
    return dirty ? branch + QStringLiteral("*") : branch;
}

QString AgentWorkspaceService::activeEditorPath() const
{
    const QString changedPath = activePathFromChanges();
    if (!changedPath.isEmpty()) {
        return changedPath;
    }
    const QString fallback = QStringLiteral("app/stage-desktop/qml/features/ability/agent/AgentView.qml");
    return QFileInfo(m_workspacePath + QLatin1Char('/') + fallback).exists() ? fallback : QStringLiteral("app/stage-desktop/qml/main.qml");
}

QString AgentWorkspaceService::changeSummary() const
{
    const QString shortStat = firstLine(runGit({QStringLiteral("diff"), QStringLiteral("--shortstat")}));
    const QVariantList files = changedFiles(100);
    if (files.isEmpty()) {
        return QStringLiteral("工作区干净");
    }
    if (!shortStat.isEmpty()) {
        return shortStat;
    }
    return QStringLiteral("%1 个工作区改动").arg(files.size());
}

QVariantList AgentWorkspaceService::projectTree(int maxEntries) const
{
    QVariantList items;
    const QStringList priorityPaths = {
        QStringLiteral("app"),
        QStringLiteral("app/stage-desktop"),
        QStringLiteral("app/stage-desktop/qml"),
        QStringLiteral("app/stage-desktop/qml/features"),
        QStringLiteral("app/stage-desktop/qml/features/ability"),
        QStringLiteral("app/stage-desktop/qml/features/ability/agent")
    };

    for (int i = 0; i < priorityPaths.size() && items.size() < maxEntries; ++i) {
        const QString path = priorityPaths.at(i);
        const QFileInfo info(m_workspacePath + QLatin1Char('/') + path);
        if (info.exists() && info.isDir()) {
            items.append(fileTreeItem(info.fileName(), path, i, true, true, false));
        }
    }

    const QDir agentDir(m_workspacePath + QStringLiteral("/app/stage-desktop/qml/features/ability/agent"));
    const QFileInfoList agentFiles = agentDir.entryInfoList(
        {QStringLiteral("*.qml")},
        QDir::Files,
        QDir::Name | QDir::IgnoreCase);
    for (const QFileInfo& file : agentFiles) {
        if (items.size() >= maxEntries) {
            return items;
        }
        const QString relativePath = QStringLiteral("app/stage-desktop/qml/features/ability/agent/") + file.fileName();
        items.append(fileTreeItem(file.fileName(), relativePath, 6, false, false, relativePath == activeEditorPath()));
    }

    const QDir rootDir(m_workspacePath);
    const QFileInfoList rootEntries = rootDir.entryInfoList(
        QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot,
        QDir::DirsFirst | QDir::Name | QDir::IgnoreCase);
    for (const QFileInfo& entry : rootEntries) {
        if (items.size() >= maxEntries) {
            break;
        }
        const QString name = entry.fileName();
        if (name == QStringLiteral(".git") || name == QStringLiteral("build") || name == QStringLiteral(".DS_Store") || name == QStringLiteral("app")) {
            continue;
        }
        items.append(fileTreeItem(name, name, 0, entry.isDir(), false, false));
    }

    return items;
}

QVariantList AgentWorkspaceService::changedFiles(int maxEntries) const
{
    QVariantList items;
    const QString statusOutput = runGit({
        QStringLiteral("status"),
        QStringLiteral("--short"),
        QStringLiteral("--untracked-files=normal")
    });
    const QStringList lines = statusOutput.split(QLatin1Char('\n'), Qt::SkipEmptyParts);
    for (const QString& line : lines) {
        if (items.size() >= maxEntries || line.size() < 4) {
            break;
        }
        const QString status = line.left(2);
        const QString path = normalizeRelativePath(line.mid(3));
        if (!path.isEmpty()) {
            items.append(changedFileItem(status, path));
        }
    }
    return items;
}

QVariantList AgentWorkspaceService::editorTabs(int maxTabs) const
{
    QVariantList tabs;
    const QString activePath = activeEditorPath();
    const QVariantList changed = changedFiles(maxTabs);
    for (const QVariant& item : changed) {
        if (tabs.size() >= maxTabs) {
            break;
        }
        const QVariantMap map = item.toMap();
        const QString path = map.value(QStringLiteral("path")).toString();
        QVariantMap tab;
        tab.insert(QStringLiteral("label"), QFileInfo(path).fileName());
        tab.insert(QStringLiteral("path"), path);
        tab.insert(QStringLiteral("active"), path == activePath);
        tab.insert(QStringLiteral("dirty"), true);
        tabs.append(tab);
    }

    bool hasActive = false;
    for (const QVariant& tabValue : tabs) {
        if (tabValue.toMap().value(QStringLiteral("path")).toString() == activePath) {
            hasActive = true;
            break;
        }
    }
    if (!hasActive && tabs.size() < maxTabs) {
        QVariantMap tab;
        tab.insert(QStringLiteral("label"), QFileInfo(activePath).fileName());
        tab.insert(QStringLiteral("path"), activePath);
        tab.insert(QStringLiteral("active"), true);
        tab.insert(QStringLiteral("dirty"), false);
        tabs.prepend(tab);
    }
    return tabs;
}

QVariantList AgentWorkspaceService::editorRows(const QString& relativePath, int maxLines) const
{
    QVariantList rows;
    const QString path = relativePath.trimmed().isEmpty() ? activeEditorPath() : normalizeRelativePath(relativePath);
    QFile file(m_workspacePath + QLatin1Char('/') + path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QVariantMap row;
        row.insert(QStringLiteral("lineNo"), QStringLiteral("--"));
        row.insert(QStringLiteral("text"), QStringLiteral("无法读取文件：%1").arg(path));
        row.insert(QStringLiteral("kind"), QStringLiteral("warn"));
        rows.append(row);
        return rows;
    }

    QTextStream stream(&file);
    int lineNo = 0;
    int firstVisibleLine = 1;
    QStringList allLines;
    while (!stream.atEnd()) {
        allLines.append(stream.readLine());
    }

    for (int i = 0; i < allLines.size(); ++i) {
        if (allLines.at(i).contains(QStringLiteral("Component {")) && i + 1 < allLines.size()
            && allLines.at(i + 1).contains(QStringLiteral("id: idePage"))) {
            firstVisibleLine = qMax(1, i - 8);
            break;
        }
        if (allLines.at(i).contains(QStringLiteral("id: idePage"))) {
            firstVisibleLine = qMax(1, i - 9);
            break;
        }
    }

    const int startIndex = qMin(qMax(0, firstVisibleLine - 1), qMax(0, allLines.size() - 1));
    const int endIndex = qMin(allLines.size(), startIndex + qMax(1, maxLines));
    for (int i = startIndex; i < endIndex; ++i) {
        ++lineNo;
        QVariantMap row;
        row.insert(QStringLiteral("lineNo"), QString::number(i + 1));
        row.insert(QStringLiteral("text"), allLines.at(i).isEmpty() ? QStringLiteral(" ") : allLines.at(i));
        row.insert(QStringLiteral("kind"), allLines.at(i).startsWith(QLatin1Char('+')) ? QStringLiteral("added") : QStringLiteral("normal"));
        rows.append(row);
    }
    return rows;
}

QVariantList AgentWorkspaceService::diffRows(const QString& relativePath, int maxRows) const
{
    QVariantList rows;
    const QString path = relativePath.trimmed().isEmpty() ? activeEditorPath() : normalizeRelativePath(relativePath);
    const QString diff = runGit({
        QStringLiteral("diff"),
        QStringLiteral("--unified=7"),
        QStringLiteral("--"),
        path
    }, 1200);

    auto appendRow = [&rows, maxRows](const QString& baseLine, const QString& workLine,
                                      const QString& baseText, const QString& workText,
                                      const QString& kind) {
        if (rows.size() >= maxRows) {
            return;
        }
        QVariantMap row;
        row.insert(QStringLiteral("baseLine"), baseLine);
        row.insert(QStringLiteral("workLine"), workLine);
        row.insert(QStringLiteral("baseText"), baseText.isEmpty() ? QStringLiteral(" ") : baseText);
        row.insert(QStringLiteral("workText"), workText.isEmpty() ? QStringLiteral(" ") : workText);
        row.insert(QStringLiteral("kind"), kind);
        rows.append(row);
    };

    if (!diff.isEmpty()) {
        int baseLine = 0;
        int workLine = 0;
        const QStringList lines = diff.split(QLatin1Char('\n'));
        for (const QString& line : lines) {
            if (rows.size() >= maxRows) {
                break;
            }
            if (line.startsWith(QStringLiteral("@@"))) {
                const QStringList parts = line.split(QLatin1Char(' '), Qt::SkipEmptyParts);
                if (parts.size() >= 3) {
                    const QString oldRange = parts.at(1).mid(1);
                    const QString newRange = parts.at(2).mid(1);
                    baseLine = oldRange.section(QLatin1Char(','), 0, 0).toInt();
                    workLine = newRange.section(QLatin1Char(','), 0, 0).toInt();
                }
                continue;
            }
            if (line.startsWith(QStringLiteral("---")) || line.startsWith(QStringLiteral("+++")) || line.startsWith(QStringLiteral("diff --git")) || line.startsWith(QStringLiteral("index "))) {
                continue;
            }
            if (line.startsWith(QLatin1Char('-'))) {
                appendRow(QString::number(baseLine), QString(), line.mid(1), QString(), QStringLiteral("removed"));
                ++baseLine;
                continue;
            }
            if (line.startsWith(QLatin1Char('+'))) {
                appendRow(QString(), QString::number(workLine), QString(), line.mid(1), QStringLiteral("added"));
                ++workLine;
                continue;
            }
            if (line.startsWith(QLatin1Char(' '))) {
                const QString text = line.mid(1);
                appendRow(QString::number(baseLine), QString::number(workLine), text, text, QStringLiteral("context"));
                ++baseLine;
                ++workLine;
            }
        }
    }

    if (!rows.isEmpty()) {
        return rows;
    }

    const QVariantList editor = editorRows(path, maxRows);
    for (const QVariant& item : editor) {
        const QVariantMap source = item.toMap();
        const QString lineNo = source.value(QStringLiteral("lineNo")).toString();
        const QString text = source.value(QStringLiteral("text")).toString();
        appendRow(lineNo, lineNo, text, text, QStringLiteral("context"));
    }
    return rows;
}

QVariantList AgentWorkspaceService::terminalEntries(int maxEntries) const
{
    QVariantList entries;
    const QStringList statusLines = runGit({QStringLiteral("status"), QStringLiteral("--short")})
        .split(QLatin1Char('\n'), Qt::SkipEmptyParts);

    auto append = [&entries, maxEntries](const QString& text) {
        if (entries.size() >= maxEntries) {
            return;
        }
        QVariantMap row;
        row.insert(QStringLiteral("text"), text);
        entries.append(row);
    };

    append(QStringLiteral("$ pwd"));
    append(m_workspacePath);
    append(QStringLiteral("$ git branch --show-current"));
    append(branchName());
    append(QStringLiteral("$ git status --short"));
    if (statusLines.isEmpty()) {
        append(QStringLiteral("working tree clean"));
    } else {
        for (const QString& line : statusLines) {
            append(line.trimmed());
        }
    }
    return entries;
}

QString AgentWorkspaceService::readFile(const QString& relativePath, int maxBytes) const
{
    const QString absolutePath = safeAbsolutePath(relativePath);
    if (absolutePath.isEmpty()) {
        return QStringLiteral("Cannot read path outside workspace: %1").arg(relativePath);
    }

    QFile file(absolutePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return QStringLiteral("Cannot open file: %1").arg(relativePath);
    }

    const QByteArray raw = file.read(qMax(1, maxBytes));
    return QString::fromUtf8(raw);
}

QString AgentWorkspaceService::gitBaseFile(const QString& relativePath, int maxBytes) const
{
    const QString path = normalizeRelativePath(relativePath);
    if (path.isEmpty()) {
        return {};
    }

    QProcess process;
    process.setWorkingDirectory(m_workspacePath);
    process.start(QStringLiteral("git"), {
        QStringLiteral("show"),
        QStringLiteral("HEAD:%1").arg(path)
    });
    if (!process.waitForFinished(1200) || process.exitStatus() != QProcess::NormalExit || process.exitCode() != 0) {
        return QStringLiteral("No HEAD version for %1").arg(path);
    }
    return QString::fromUtf8(process.read(qMax(1, maxBytes)));
}

bool AgentWorkspaceService::writeFile(const QString& relativePath, const QString& content)
{
    const QString absolutePath = safeAbsolutePath(relativePath);
    if (absolutePath.isEmpty()) {
        return false;
    }

    QFile file(absolutePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate)) {
        return false;
    }
    file.write(content.toUtf8());
    return true;
}

QString AgentWorkspaceService::gitDiff(const QString& relativePath, int maxBytes) const
{
    const QString path = normalizeRelativePath(relativePath);
    const QString diff = runGit({
        QStringLiteral("diff"),
        QStringLiteral("--"),
        path
    }, 1200);
    if (diff.isEmpty()) {
        return QStringLiteral("No unstaged diff for %1").arg(path);
    }
    return diff.left(qMax(1, maxBytes));
}

QString AgentWorkspaceService::terminalText(int maxEntries) const
{
    QStringList lines;
    const QVariantList entries = terminalEntries(maxEntries);
    for (const QVariant& entry : entries) {
        lines.append(entry.toMap().value(QStringLiteral("text")).toString());
    }
    return lines.join(QLatin1Char('\n'));
}

QString AgentWorkspaceService::runBuild()
{
    const QString buildDir = m_workspacePath + QStringLiteral("/build");
    if (!QFileInfo(buildDir).isDir()) {
        return QStringLiteral("Build directory not found: %1").arg(buildDir);
    }

    QProcess process;
    process.setWorkingDirectory(m_workspacePath);
    process.start(QStringLiteral("cmake"), {
        QStringLiteral("--build"),
        buildDir,
        QStringLiteral("--target"),
        QStringLiteral("OpenNekoEngine"),
        QStringLiteral("-j4")
    });
    if (!process.waitForStarted(2000)) {
        return QStringLiteral("Failed to start build command.");
    }
    process.waitForFinished(120000);
    const QString output = QString::fromUtf8(process.readAllStandardOutput());
    const QString error = QString::fromUtf8(process.readAllStandardError());
    return (output + (error.isEmpty() ? QString() : QStringLiteral("\n") + error)).trimmed();
}

QString AgentWorkspaceService::resolveWorkspacePath() const
{
    QDir dir(QCoreApplication::applicationDirPath());
    for (int i = 0; i < 10; ++i) {
        if (isWorkspaceRoot(dir)) {
            return dir.absolutePath();
        }
        if (!dir.cdUp()) {
            break;
        }
    }

    dir = QDir::current();
    for (int i = 0; i < 10; ++i) {
        if (isWorkspaceRoot(dir)) {
            return dir.absolutePath();
        }
        if (!dir.cdUp()) {
            break;
        }
    }
    return QCoreApplication::applicationDirPath();
}

QString AgentWorkspaceService::runGit(const QStringList& arguments, int timeoutMs) const
{
    if (m_workspacePath.isEmpty()) {
        return {};
    }
    QProcess process;
    process.setWorkingDirectory(m_workspacePath);
    process.start(QStringLiteral("git"), arguments);
    if (!process.waitForFinished(timeoutMs) || process.exitStatus() != QProcess::NormalExit || process.exitCode() != 0) {
        return {};
    }
    return QString::fromUtf8(process.readAllStandardOutput()).trimmed();
}

QString AgentWorkspaceService::safeAbsolutePath(const QString& relativePath) const
{
    const QString normalized = normalizeRelativePath(relativePath);
    if (normalized.isEmpty() || normalized.startsWith(QStringLiteral("../")) || normalized == QStringLiteral("..")) {
        return {};
    }

    const QDir root(m_workspacePath);
    const QString absolutePath = QFileInfo(root.absoluteFilePath(normalized)).canonicalFilePath();
    const QString rootPath = QFileInfo(m_workspacePath).canonicalFilePath();
    if (absolutePath.isEmpty() || rootPath.isEmpty() || (absolutePath != rootPath && !absolutePath.startsWith(rootPath + QLatin1Char('/')))) {
        return {};
    }
    return absolutePath;
}

QVariantMap AgentWorkspaceService::fileTreeItem(const QString& label, const QString& relativePath, int depth, bool folder, bool expanded, bool active) const
{
    QVariantMap item;
    item.insert(QStringLiteral("label"), label);
    item.insert(QStringLiteral("path"), relativePath);
    item.insert(QStringLiteral("depth"), depth);
    item.insert(QStringLiteral("folder"), folder);
    item.insert(QStringLiteral("expanded"), expanded);
    item.insert(QStringLiteral("active"), active);
    return item;
}

QVariantMap AgentWorkspaceService::changedFileItem(const QString& status, const QString& path) const
{
    QVariantMap item;
    item.insert(QStringLiteral("fileName"), QFileInfo(path).fileName());
    item.insert(QStringLiteral("path"), path);
    item.insert(QStringLiteral("status"), statusLabel(status));
    item.insert(QStringLiteral("rawStatus"), status.trimmed());
    item.insert(QStringLiteral("active"), path == activeEditorPath());

    const QString numstat = firstLine(runGit({QStringLiteral("diff"), QStringLiteral("--numstat"), QStringLiteral("--"), path}));
    const QStringList parts = numstat.split(QLatin1Char('\t'));
    item.insert(QStringLiteral("added"), parts.size() >= 2 && parts.at(0) != QStringLiteral("-") ? QStringLiteral("+") + parts.at(0) : QString());
    item.insert(QStringLiteral("removed"), parts.size() >= 2 && parts.at(1) != QStringLiteral("-") ? QStringLiteral("-") + parts.at(1) : QString());
    return item;
}

QString AgentWorkspaceService::activePathFromChanges() const
{
    const QString preferred = QStringLiteral("app/stage-desktop/qml/features/ability/agent/AgentView.qml");
    const QString statusOutput = runGit({
        QStringLiteral("status"),
        QStringLiteral("--short"),
        QStringLiteral("--untracked-files=normal")
    });
    const QStringList lines = statusOutput.split(QLatin1Char('\n'), Qt::SkipEmptyParts);
    QString firstQml;
    for (const QString& line : lines) {
        if (line.size() < 4) {
            continue;
        }
        const QString path = normalizeRelativePath(line.mid(3));
        if (path == preferred) {
            return path;
        }
        if (firstQml.isEmpty() && path.endsWith(QStringLiteral(".qml"))) {
            firstQml = path;
        }
    }
    return firstQml;
}
