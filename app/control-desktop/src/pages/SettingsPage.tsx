import { type ReactNode, useState } from "react";
import {
  Bot,
  Cat,
  ChevronRight,
  Cloud,
  Database,
  FolderOpen,
  Info,
  KeyRound,
  Languages,
  LockKeyhole,
  Monitor,
  Moon,
  Palette,
  Settings,
  ShieldCheck,
  SlidersHorizontal,
  Sparkles,
  Sun,
  Trash2,
  UserRound,
  Volume2,
} from "lucide-react";
import { PageHeading, SettingRow, Toggle } from "../components/ui";
import type { AuthSessionSnapshot } from "../auth/authService";

type SettingsSection = "general" | "companion" | "agent" | "account" | "privacy" | "about";

const settingsSections = [
  { id: "general", label: "通用", icon: Settings },
  { id: "companion", label: "桌宠", icon: Cat },
  { id: "agent", label: "Agent", icon: Bot },
  { id: "account", label: "账号与同步", icon: UserRound },
  { id: "privacy", label: "隐私与数据", icon: ShieldCheck },
  { id: "about", label: "关于", icon: Info },
] as const;

interface SettingsPageProps {
  stageRunning: boolean;
  onOpenAccount: () => void;
  authSession: AuthSessionSnapshot;
}

export function SettingsPage({ stageRunning, onOpenAccount, authSession }: SettingsPageProps) {
  const [section, setSection] = useState<SettingsSection>("general");
  const [launchAtLogin, setLaunchAtLogin] = useState(false);
  const [tray, setTray] = useState(true);
  const [notifications, setNotifications] = useState(true);
  const [clickThrough, setClickThrough] = useState(false);
  const [localOnly, setLocalOnly] = useState(true);
  const accountConnection = !authSession.profile
    ? { label: "未登录", description: "登录后验证账号并使用账号服务。", className: "" }
    : authSession.verification === "offline"
      ? { label: "账号离线", description: "已读取本机账号，当前无法验证服务端连接。", className: "state-badge--warning" }
      : { label: "已验证", description: "账号凭据已通过服务端验证。", className: "state-badge--success" };

  return (
    <div className="page settings-page">
      <PageHeading title="设置" description="配置 NekoPapa 的桌面行为、连接与数据边界。" />

      <div className="settings-workspace">
        <aside className="settings-sidebar">
          {settingsSections.map((item) => {
            const Icon = item.icon;
            return (
              <button type="button" key={item.id} className={section === item.id ? "is-active" : ""} onClick={() => setSection(item.id)}>
                <Icon size={16} />
                <span>{item.label}</span>
                <ChevronRight size={14} />
              </button>
            );
          })}
        </aside>

        <section className="settings-content">
          {section === "general" ? (
            <>
              <SettingsSectionHeader title="通用" description="应用外观与系统行为。" icon={<SlidersHorizontal size={19} />} />
              <SettingsGroup title="外观">
                <SettingRow icon={<Palette size={17} />} title="主题" description="跟随系统外观" control={<select aria-label="主题"><option>跟随系统</option><option>浅色</option><option>深色</option></select>} />
                <SettingRow icon={<Languages size={17} />} title="语言" control={<span className="setting-value">简体中文</span>} />
                <SettingRow icon={<Sun size={17} />} title="强调色" description="用于主操作与当前选中状态" control={<span className="color-swatch" title="珊瑚粉" />} />
              </SettingsGroup>
              <SettingsGroup title="系统">
                <SettingRow icon={<Monitor size={17} />} title="登录时启动" description="登录系统后自动运行 NekoPapa" control={<Toggle checked={launchAtLogin} onChange={setLaunchAtLogin} label="登录时启动" />} />
                <SettingRow icon={<Moon size={17} />} title="关闭主窗口后保留托盘" control={<Toggle checked={tray} onChange={setTray} label="保留托盘" />} />
                <SettingRow icon={<Volume2 size={17} />} title="桌面通知" control={<Toggle checked={notifications} onChange={setNotifications} label="桌面通知" />} />
              </SettingsGroup>
            </>
          ) : null}

          {section === "companion" ? (
            <>
              <SettingsSectionHeader title="桌宠" description="独立透明 Stage 的窗口与渲染行为。" icon={<Cat size={19} />} />
              <SettingsGroup title="Stage">
                <SettingRow icon={<Sparkles size={17} />} title="运行状态" description="由原生 Stage sidecar 提供" control={<span className={`state-badge ${stageRunning ? "state-badge--success" : ""}`}>{stageRunning ? "运行中" : "已停止"}</span>} />
                <SettingRow icon={<FolderOpen size={17} />} title="Live2D 模型" description="尚未选择 Cubism 模型目录" control={<button type="button" className="button button--secondary">选择模型</button>} />
                <SettingRow icon={<Monitor size={17} />} title="窗口层级" control={<select aria-label="窗口层级"><option>始终置顶</option><option>普通窗口</option><option>桌面层</option></select>} />
                <SettingRow icon={<Cat size={17} />} title="非交互区域鼠标穿透" description="允许点击模型外的桌面内容" control={<Toggle checked={clickThrough} onChange={setClickThrough} label="鼠标穿透" />} />
              </SettingsGroup>
            </>
          ) : null}

          {section === "agent" ? (
            <>
              <SettingsSectionHeader title="Agent" description="模型提供方、执行权限与工具边界。" icon={<Bot size={19} />} />
              <SettingsGroup title="模型">
                <SettingRow icon={<Bot size={17} />} title="模型提供方" description="尚未配置" control={<button type="button" className="button button--secondary">配置</button>} />
                <SettingRow icon={<KeyRound size={17} />} title="访问凭据" description="凭据保存在系统安全存储" control={<span className="state-badge">未设置</span>} />
              </SettingsGroup>
              <SettingsGroup title="执行">
                <SettingRow icon={<LockKeyhole size={17} />} title="默认执行模式" control={<select aria-label="默认执行模式"><option>受控执行</option><option>只读</option></select>} />
                <SettingRow icon={<FolderOpen size={17} />} title="工作区访问" description="每个目录都需要明确授权" />
              </SettingsGroup>
            </>
          ) : null}

          {section === "account" ? (
            <>
              <SettingsSectionHeader title="账号与同步" description="管理登录状态与云端连接。" icon={<Cloud size={19} />} />
              <div className="account-panel">
                <span className="account-panel__avatar"><UserRound size={23} /></span>
                <div>
                  <strong>{authSession.profile?.displayName || "尚未登录"}</strong>
                  <p>{authSession.profile?.phone || "登录后可使用账号服务和已授权的同伴信息。"}</p>
                </div>
                <button type="button" className="button button--primary" onClick={onOpenAccount}>
                  {authSession.status === "signed-in" ? "账号中心" : "登录"}
                </button>
              </div>
              <SettingsGroup title="连接">
                <SettingRow
                  icon={<Cloud size={17} />}
                  title="账号连接"
                  description={accountConnection.description}
                  control={<span className={`state-badge ${accountConnection.className}`}>{accountConnection.label}</span>}
                />
                <SettingRow
                  icon={<Database size={17} />}
                  title="云同步"
                  description="跨设备同步尚未接入当前桌面端。"
                  control={<span className="state-badge">未配置</span>}
                />
              </SettingsGroup>
            </>
          ) : null}

          {section === "privacy" ? (
            <>
              <SettingsSectionHeader title="隐私与数据" description="本地存储、权限与数据生命周期。" icon={<ShieldCheck size={19} />} />
              <SettingsGroup title="数据策略">
                <SettingRow icon={<Database size={17} />} title="仅在本机处理" description="默认不上传对话、记忆和环境事件" control={<Toggle checked={localOnly} onChange={setLocalOnly} label="仅本机处理" />} />
                <SettingRow icon={<LockKeyhole size={17} />} title="应用权限" description="查看麦克风、摄像头与自动化授权" />
                <SettingRow icon={<FolderOpen size={17} />} title="打开数据目录" description="检查模型、日志和本地缓存" />
              </SettingsGroup>
              <SettingsGroup title="数据操作">
                <SettingRow icon={<Trash2 size={17} />} title="清除本地数据" description="删除会话、记忆索引和设置，无法撤销" control={<button type="button" className="button button--danger-soft">清除数据</button>} />
              </SettingsGroup>
            </>
          ) : null}

          {section === "about" ? (
            <>
              <SettingsSectionHeader title="关于" description="版本、许可和运行组件。" icon={<Info size={19} />} />
              <div className="about-panel">
                <span className="about-panel__mark"><Cat size={28} /></span>
                <div><h2>NekoPapa</h2><p>桌面原生的陪伴型 Agent 工作台</p></div>
                <span className="state-badge">v0.1.0</span>
              </div>
              <SettingsGroup title="组件">
                <SettingRow icon={<Monitor size={17} />} title="桌面主控台" control={<span className="setting-value">Tauri 2</span>} />
                <SettingRow icon={<Cat size={17} />} title="桌宠 Stage" control={<span className="setting-value">Native Cubism</span>} />
                <SettingRow icon={<ShieldCheck size={17} />} title="仓库许可" control={<span className="setting-value">Apache-2.0</span>} />
              </SettingsGroup>
            </>
          ) : null}
        </section>
      </div>
    </div>
  );
}

function SettingsSectionHeader({ title, description, icon }: { title: string; description: string; icon: ReactNode }) {
  return (
    <div className="settings-section-header">
      <span>{icon}</span>
      <div><h2>{title}</h2><p>{description}</p></div>
    </div>
  );
}

function SettingsGroup({ title, children }: { title: string; children: ReactNode }) {
  return (
    <section className="settings-section">
      <h3>{title}</h3>
      <div className="settings-group">{children}</div>
    </section>
  );
}
