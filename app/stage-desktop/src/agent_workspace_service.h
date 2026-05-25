#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>

class AgentWorkspaceService : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString workspacePath READ workspacePath CONSTANT)
    Q_PROPERTY(QString workspaceName READ workspaceName CONSTANT)
    Q_PROPERTY(QString branchName READ branchName CONSTANT)
    Q_PROPERTY(QString repoName READ repoName CONSTANT)
    Q_PROPERTY(QString activeEditorPath READ activeEditorPath CONSTANT)
    Q_PROPERTY(QString changeSummary READ changeSummary CONSTANT)

public:
    explicit AgentWorkspaceService(QObject* parent = nullptr);

    QString workspacePath() const;
    QString workspaceName() const;
    QString branchName() const;
    QString repoName() const;
    QString activeEditorPath() const;
    QString changeSummary() const;

    Q_INVOKABLE QVariantList projectTree(int maxEntries = 80) const;
    Q_INVOKABLE QVariantList changedFiles(int maxEntries = 40) const;
    Q_INVOKABLE QVariantList editorTabs(int maxTabs = 6) const;
    Q_INVOKABLE QVariantList editorRows(const QString& relativePath = QString(), int maxLines = 88) const;
    Q_INVOKABLE QVariantList diffRows(const QString& relativePath = QString(), int maxRows = 90) const;
    Q_INVOKABLE QVariantList terminalEntries(int maxEntries = 8) const;
    Q_INVOKABLE QString readFile(const QString& relativePath, int maxBytes = 200000) const;
    Q_INVOKABLE QString gitBaseFile(const QString& relativePath, int maxBytes = 200000) const;
    Q_INVOKABLE bool writeFile(const QString& relativePath, const QString& content);
    Q_INVOKABLE QString gitDiff(const QString& relativePath, int maxBytes = 120000) const;
    Q_INVOKABLE QString terminalText(int maxEntries = 12) const;
    Q_INVOKABLE QString runBuild();

private:
    QString resolveWorkspacePath() const;
    QString runGit(const QStringList& arguments, int timeoutMs = 900) const;
    QString safeAbsolutePath(const QString& relativePath) const;
    QVariantMap fileTreeItem(const QString& label, const QString& relativePath, int depth, bool folder, bool expanded, bool active) const;
    QVariantMap changedFileItem(const QString& status, const QString& path) const;
    QString activePathFromChanges() const;

    QString m_workspacePath;
};
