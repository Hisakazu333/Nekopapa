import { useEffect, useRef, useState } from "react";
import {
  Bookmark,
  Cloud,
  Globe2,
  Home,
  LogIn,
  LogOut,
  MessageCircle,
  Settings,
  UserRound,
  UserCog,
  Zap,
  type LucideIcon,
} from "lucide-react";
import type { PageId } from "../App";
import type { AuthSessionSnapshot } from "../auth/authService";
import lumiaCutout from "../assets/lumia-cutout.png";
import type { Live2DRenderState } from "./Live2DCompanion";

interface NavigationItem {
  id: PageId;
  label: string;
  icon: LucideIcon;
}

const navigationItems: NavigationItem[] = [
  { id: "stage", label: "舞台", icon: Home },
  { id: "conversation", label: "对话", icon: MessageCircle },
  { id: "memory", label: "记忆", icon: Bookmark },
  { id: "world", label: "世界", icon: Globe2 },
];

interface TopNavigationProps {
  activePage: PageId;
  onNavigate: (page: PageId) => void;
  stageRunning: boolean;
  live2dState: Live2DRenderState;
  authSession: AuthSessionSnapshot;
  onOpenAccount: () => void;
  onSignOut: () => void;
}

const live2dLabels: Record<Live2DRenderState, string> = {
  idle: "Live2D 未挂载",
  loading: "Live2D 加载中",
  ready: "Live2D 已加载",
  error: "Live2D 异常",
};

export function TopNavigation({
  activePage,
  onNavigate,
  stageRunning,
  live2dState,
  authSession,
  onOpenAccount,
  onSignOut,
}: TopNavigationProps) {
  const [accountMenuOpen, setAccountMenuOpen] = useState(false);
  const [failedAvatarUrl, setFailedAvatarUrl] = useState("");
  const accountMenuRef = useRef<HTMLDivElement>(null);
  const accountTriggerRef = useRef<HTMLButtonElement>(null);
  const profile = authSession.profile;
  const visibleAvatarUrl = profile?.avatarUrl && profile.avatarUrl !== failedAvatarUrl
    ? profile.avatarUrl
    : undefined;
  const accountStatus = !profile
    ? { label: "未登录", stateClass: "" }
    : authSession.verification === "offline"
      ? { label: "账号离线", stateClass: "is-offline" }
      : { label: "账号已验证", stateClass: "is-online" };

  useEffect(() => {
    setFailedAvatarUrl("");
  }, [profile?.avatarUrl, profile?.id]);

  useEffect(() => {
    if (!accountMenuOpen) return;

    const handlePointerDown = (event: PointerEvent) => {
      if (!accountMenuRef.current?.contains(event.target as Node)) {
        setAccountMenuOpen(false);
      }
    };
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        event.preventDefault();
        setAccountMenuOpen(false);
        accountTriggerRef.current?.focus();
      }
    };
    document.addEventListener("pointerdown", handlePointerDown);
    document.addEventListener("keydown", handleKeyDown);
    return () => {
      document.removeEventListener("pointerdown", handlePointerDown);
      document.removeEventListener("keydown", handleKeyDown);
    };
  }, [accountMenuOpen]);

  const openAccount = () => {
    setAccountMenuOpen(false);
    onOpenAccount();
  };

  const signOut = () => {
    setAccountMenuOpen(false);
    onSignOut();
  };

  return (
    <header className="app-header">
      <div className="topbar">
        <div className="runtime-pills" aria-label="运行状态">
          <span className={`runtime-pill ${live2dState === "ready" ? "is-online" : ""} ${live2dState === "error" ? "is-error" : ""}`}>
            <i />{live2dLabels[live2dState]}
          </span>
          <span className={`runtime-pill ${live2dState === "ready" ? "is-online" : ""}`}>
            <i />角色{live2dState === "ready" ? "在线" : "待机"}
          </span>
          <span className={`runtime-pill ${stageRunning ? "is-online" : ""}`}>
            <i />桌面{stageRunning ? "在线" : "离线"}
          </span>
        </div>

        <nav className="topnav" aria-label="主导航">
          {navigationItems.map((item) => {
            const Icon = item.icon;
            const active = item.id === activePage;
            return (
              <button
                key={item.id}
                type="button"
                className={`topnav__item ${active ? "topnav__item--active" : ""}`}
                aria-current={active ? "page" : undefined}
                onClick={() => onNavigate(item.id)}
              >
                <Icon size={18} strokeWidth={1.75} aria-hidden="true" />
                <span>{item.label}</span>
              </button>
            );
          })}
        </nav>

        <div className="topbar-actions">
          <button
            type="button"
            className={`agent-shortcut ${activePage === "agent" ? "is-active" : ""}`}
            onClick={() => onNavigate("agent")}
          >
            <Zap size={17} aria-hidden="true" />
            <span>Agent</span>
          </button>
          <div className="account-menu" ref={accountMenuRef}>
            <button
              ref={accountTriggerRef}
              type="button"
              className={`account-menu__trigger ${accountMenuOpen ? "is-open" : ""}`}
              aria-label={profile ? `${profile.displayName} 账号菜单` : "NekoPapa 账号菜单"}
              aria-expanded={accountMenuOpen}
              title={profile ? `${profile.displayName} 账号` : "NekoPapa 账号"}
              onClick={() => setAccountMenuOpen((open) => !open)}
            >
              <span className={`account-menu__avatar ${visibleAvatarUrl ? "has-user-image" : ""}`} aria-hidden="true">
                {visibleAvatarUrl
                  ? <img src={visibleAvatarUrl} alt="" onError={() => setFailedAvatarUrl(visibleAvatarUrl)} />
                  : profile
                    ? <UserRound size={25} strokeWidth={1.7} />
                    : <img src={lumiaCutout} alt="" />}
              </span>
            </button>
            {accountMenuOpen ? (
              <div className="account-menu__panel" aria-label="账号菜单">
                <div className="account-menu__profile">
                  <span className={`account-menu__profile-avatar ${visibleAvatarUrl ? "has-user-image" : ""}`} aria-hidden="true">
                    {visibleAvatarUrl
                      ? <img src={visibleAvatarUrl} alt="" onError={() => setFailedAvatarUrl(visibleAvatarUrl)} />
                      : profile
                        ? <UserRound size={25} strokeWidth={1.7} />
                        : <img src={lumiaCutout} alt="" />}
                  </span>
                  <span>
                    <strong>{profile?.displayName || "未登录"}</strong>
                    <small>{accountStatus.label}</small>
                  </span>
                  <i className={accountStatus.stateClass} />
                </div>
                <div className="account-menu__divider" />
                <button type="button" onClick={openAccount}>
                  {profile ? <UserCog size={16} aria-hidden="true" /> : <LogIn size={16} aria-hidden="true" />}
                  <span>{profile ? "账号设置" : "登录账号"}</span>
                </button>
                {profile ? (
                  <button type="button" onClick={signOut}>
                    <LogOut size={16} aria-hidden="true" />
                    <span>退出登录</span>
                  </button>
                ) : (
                  <div className="account-menu__hint"><Cloud size={14} aria-hidden="true" />登录后使用账号服务</div>
                )}
              </div>
            ) : null}
          </div>
          <span className="runtime-state">
            <i className={stageRunning ? "is-online" : ""} />
            {stageRunning ? "运行中" : "待启动"}
          </span>
          <button
            type="button"
            className={`topbar-settings ${activePage === "settings" ? "is-active" : ""}`}
            aria-label="设置"
            title="设置"
            onClick={() => onNavigate("settings")}
          >
            <Settings size={22} strokeWidth={1.7} aria-hidden="true" />
          </button>
        </div>
      </div>
    </header>
  );
}
