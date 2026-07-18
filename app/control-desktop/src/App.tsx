import { useCallback, useEffect, useState } from "react";
import { CircleAlert, CloudOff, Database, ShieldCheck, X } from "lucide-react";
import { authAdapter, type AuthSessionSnapshot } from "./auth/authService";
import { TopNavigation } from "./components/TopNavigation";
import type { Live2DRenderState } from "./components/Live2DCompanion";
import {
  getStageStatus,
  startStage,
  stopStage,
  type StageStatus,
} from "./bridge/stage";
import { AgentPage } from "./pages/AgentPage";
import { AuthDialog } from "./pages/AuthDialog";
import { ConversationPage } from "./pages/ConversationPage";
import { MemoryPage } from "./pages/MemoryPage";
import { SettingsPage } from "./pages/SettingsPage";
import { StagePage } from "./pages/StagePage";
import { WorldPage } from "./pages/WorldPage";

export type PageId =
  | "stage"
  | "conversation"
  | "memory"
  | "world"
  | "agent"
  | "settings";

const initialStageStatus: StageStatus = {
  state: "stopped",
  pid: null,
  message: "正在读取 Stage 状态",
  simulated: false,
  updatedAt: new Date().toISOString(),
};

const errorStatus = (error: unknown): StageStatus => ({
  state: "error",
  pid: null,
  message: error instanceof Error ? error.message : "Stage 命令执行失败",
  simulated: false,
  updatedAt: new Date().toISOString(),
});

interface AuthNotice {
  tone: "warning" | "error";
  message: string;
}

const authErrorMessage = (cause: unknown) => cause instanceof Error
  ? cause.message
  : "账号操作未完成，请稍后重试。";

export default function App() {
  const [activePage, setActivePage] = useState<PageId>("stage");
  const [authDialogOpen, setAuthDialogOpen] = useState(false);
  const [authSession, setAuthSession] = useState<AuthSessionSnapshot>({
    status: "signed-out",
    profile: null,
  });
  const [authNotice, setAuthNotice] = useState<AuthNotice | null>(null);
  const [stageStatus, setStageStatus] = useState<StageStatus>(initialStageStatus);
  const [stageBusy, setStageBusy] = useState(false);
  const [live2dState, setLive2dState] = useState<Live2DRenderState>("idle");
  const [pendingHomeMessage, setPendingHomeMessage] = useState<{
    id: number;
    text: string;
  } | null>(null);

  const refreshStageStatus = useCallback(async () => {
    try {
      setStageStatus(await getStageStatus());
    } catch (error) {
      setStageStatus(errorStatus(error));
    }
  }, []);

  useEffect(() => {
    void refreshStageStatus();
  }, [refreshStageStatus]);

  useEffect(() => {
    let active = true;
    void authAdapter.getSession()
      .then((session) => {
        if (active) setAuthSession(session);
      })
      .catch((cause) => {
        if (!active) return;
        setAuthSession({ status: "signed-out", profile: null });
        setAuthNotice({ tone: "error", message: authErrorMessage(cause) });
      });

    return () => {
      active = false;
    };
  }, []);

  const openAccount = useCallback(() => {
    setAuthDialogOpen(true);
  }, []);

  const closeAccount = useCallback(() => {
    setAuthDialogOpen(false);
  }, []);

  const completeAuthentication = useCallback((session: AuthSessionSnapshot, warning?: string) => {
    setAuthSession(session);
    setAuthDialogOpen(false);
    setAuthNotice(warning ? { tone: "warning", message: warning } : null);
  }, []);

  const signOutAccount = useCallback(async () => {
    try {
      const result = await authAdapter.signOut();
      completeAuthentication({ status: "signed-out", profile: null }, result.warning);
    } catch (cause) {
      setAuthNotice({ tone: "error", message: authErrorMessage(cause) });
    }
  }, [completeAuthentication]);

  const runStageAction = useCallback(async (action: "start" | "stop") => {
    setStageBusy(true);
    setStageStatus((current) => ({
      ...current,
      state: action === "start" ? "starting" : "stopping",
      message: action === "start" ? "正在启动桌宠舞台" : "正在停止桌宠舞台",
    }));

    try {
      const nextStatus = action === "start" ? await startStage() : await stopStage();
      setStageStatus(nextStatus);
    } catch (error) {
      setStageStatus(errorStatus(error));
    } finally {
      setStageBusy(false);
    }
  }, []);

  const stageRunning = stageStatus.state === "running";

  const openConversation = useCallback((message?: string) => {
    const text = message?.trim();
    if (text) {
      setPendingHomeMessage({ id: Date.now(), text });
    }
    setActivePage("conversation");
  }, []);

  return (
    <div
      className={`app-shell app-shell--windowed ${activePage === "stage" ? "app-shell--home" : ""}`}
    >
      <TopNavigation
        activePage={activePage}
        onNavigate={setActivePage}
        stageRunning={stageRunning}
        live2dState={live2dState}
        authSession={authSession}
        onOpenAccount={openAccount}
        onSignOut={() => void signOutAccount()}
      />

      <main className="app-main">
        {activePage === "stage" ? (
          <StagePage
            status={stageStatus}
            busy={stageBusy}
            onStart={() => void runStageAction("start")}
            onStop={() => void runStageAction("stop")}
            onOpenConversation={() => openConversation()}
            onSendMessage={openConversation}
            onOpenMemory={() => setActivePage("memory")}
            onOpenSettings={() => setActivePage("settings")}
            onLive2DStateChange={setLive2dState}
          />
        ) : null}
        {activePage === "conversation" ? (
          <ConversationPage
            initialMessage={pendingHomeMessage}
            onInitialMessageConsumed={() => setPendingHomeMessage(null)}
          />
        ) : null}
        {activePage === "memory" ? <MemoryPage /> : null}
        {activePage === "world" ? <WorldPage /> : null}
        {activePage === "agent" ? <AgentPage /> : null}
        {activePage === "settings" ? (
          <SettingsPage
            stageRunning={stageRunning}
            onOpenAccount={openAccount}
            authSession={authSession}
          />
        ) : null}
      </main>

      {activePage !== "stage" ? (
        <footer className="statusbar">
          <span><Database size={13} aria-hidden="true" /> NekoCore 待连接</span>
          <span><CloudOff size={13} aria-hidden="true" /> 云同步未配置</span>
          <span className="statusbar__spacer" />
          <span><ShieldCheck size={13} aria-hidden="true" /> 本地优先</span>
          <span className="statusbar__version">v0.1.0</span>
        </footer>
      ) : null}

      {authDialogOpen ? (
        <AuthDialog
          session={authSession}
          onClose={closeAccount}
          onAuthenticated={completeAuthentication}
        />
      ) : null}

      {authNotice ? (
        <div className={`auth-app-notice auth-app-notice--${authNotice.tone}`} role="alert">
          <CircleAlert size={17} aria-hidden="true" />
          <span>{authNotice.message}</span>
          <button type="button" onClick={() => setAuthNotice(null)} aria-label="关闭账号提示" title="关闭">
            <X size={15} aria-hidden="true" />
          </button>
        </div>
      ) : null}
    </div>
  );
}
