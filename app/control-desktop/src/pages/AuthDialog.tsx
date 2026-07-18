import {
  type FormEvent,
  type KeyboardEvent as ReactKeyboardEvent,
  useEffect,
  useRef,
  useState,
} from "react";
import {
  ArrowLeft,
  CheckCircle2,
  Eye,
  EyeOff,
  KeyRound,
  LoaderCircle,
  LockKeyhole,
  LogOut,
  Phone,
  QrCode,
  RefreshCw,
  ShieldCheck,
  UserRound,
  WifiOff,
  X,
} from "lucide-react";
import { QRCodeSVG } from "qrcode.react";
import { siApple, siHuawei, type SimpleIcon } from "simple-icons";
import appLogo from "../../src-tauri/icons/icon.png";
import lumiaCutout from "../assets/lumia-cutout.png";
import {
  AuthAdapterError,
  authAdapter,
  normalizeMainlandMobile,
  type AuthSessionSnapshot,
  type DeviceLoginChallenge,
  type DeviceLoginStatus,
} from "../auth/authService";
import "../styles/auth.css";

type AuthView = "login" | "register" | "qr";
type LoginMode = "code" | "password";
type RegistrationStep = 1 | 2;
type PendingAction =
  | "send-login-code"
  | "login-code"
  | "login-password"
  | "send-register-code"
  | "verify-register-mobile"
  | "send-register-password-code"
  | "complete-register"
  | "start-qr"
  | "sign-out";

const mobilePattern = /^1\d{10}$/;
const codePattern = /^\d{6}$/;

const qrStatusCopy: Record<DeviceLoginStatus, string> = {
  WAITING: "等待手机扫描",
  SCANNED: "已扫描，请在手机上确认",
  CONFIRMED: "登录已确认",
  EXPIRED: "二维码已过期",
  CANCELED: "已在手机上取消",
  CONSUMED: "二维码已使用，请刷新",
};

export interface AuthDialogProps {
  session: AuthSessionSnapshot;
  onClose: () => void;
  onAuthenticated: (session: AuthSessionSnapshot, warning?: string) => void;
}

export function AuthDialog({ session, onClose, onAuthenticated }: AuthDialogProps) {
  const dialogRef = useRef<HTMLElement>(null);
  const closeButtonRef = useRef<HTMLButtonElement>(null);
  const startRequestRef = useRef<AbortController | null>(null);
  const [view, setView] = useState<AuthView>("login");
  const [loginMode, setLoginMode] = useState<LoginMode>("code");
  const [mobile, setMobile] = useState("");
  const [code, setCode] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [registrationStep, setRegistrationStep] = useState<RegistrationStep>(1);
  const [registrationCode, setRegistrationCode] = useState("");
  const [registrationPasswordCode, setRegistrationPasswordCode] = useState("");
  const [registrationPassword, setRegistrationPassword] = useState("");
  const [registrationPasswordConfirm, setRegistrationPasswordConfirm] = useState("");
  const [showRegistrationPassword, setShowRegistrationPassword] = useState(false);
  const [pendingAction, setPendingAction] = useState<PendingAction | null>(null);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const [loginResendSeconds, setLoginResendSeconds] = useState(0);
  const [registrationResendSeconds, setRegistrationResendSeconds] = useState(0);
  const [passwordCodeResendSeconds, setPasswordCodeResendSeconds] = useState(0);
  const [qrChallenge, setQrChallenge] = useState<DeviceLoginChallenge | null>(null);
  const [qrStatus, setQrStatus] = useState<DeviceLoginStatus>("WAITING");
  const [qrSeconds, setQrSeconds] = useState(0);
  const [qrRetryNonce, setQrRetryNonce] = useState(0);

  const busy = pendingAction !== null;

  useEffect(() => {
    const previouslyFocused = document.activeElement instanceof HTMLElement
      ? document.activeElement
      : null;
    const firstInput = dialogRef.current?.querySelector<HTMLElement>("input:not([disabled])");
    (firstInput ?? closeButtonRef.current)?.focus();
    return () => previouslyFocused?.focus();
  }, []);

  useEffect(() => {
    const handleEscape = (event: KeyboardEvent) => {
      if (event.key === "Escape" && !busy) {
        event.preventDefault();
        authAdapter.cancelMobileRegistration();
        onClose();
      }
    };
    document.addEventListener("keydown", handleEscape);
    return () => document.removeEventListener("keydown", handleEscape);
  }, [busy, onClose]);

  useEffect(() => {
    if (loginResendSeconds <= 0) return;
    const timer = window.setInterval(() => {
      setLoginResendSeconds((seconds) => Math.max(0, seconds - 1));
    }, 1000);
    return () => window.clearInterval(timer);
  }, [loginResendSeconds]);

  useEffect(() => {
    if (registrationResendSeconds <= 0) return;
    const timer = window.setInterval(() => {
      setRegistrationResendSeconds((seconds) => Math.max(0, seconds - 1));
    }, 1000);
    return () => window.clearInterval(timer);
  }, [registrationResendSeconds]);

  useEffect(() => {
    if (passwordCodeResendSeconds <= 0) return;
    const timer = window.setInterval(() => {
      setPasswordCodeResendSeconds((seconds) => Math.max(0, seconds - 1));
    }, 1000);
    return () => window.clearInterval(timer);
  }, [passwordCodeResendSeconds]);

  useEffect(() => {
    if (!qrChallenge) return;
    const updateRemaining = () => {
      const remaining = Math.max(0, Math.ceil((qrChallenge.expiresAt - Date.now()) / 1000));
      setQrSeconds(remaining);
      if (remaining === 0) setQrStatus("EXPIRED");
    };
    updateRemaining();
    const timer = window.setInterval(updateRemaining, 1000);
    return () => window.clearInterval(timer);
  }, [qrChallenge]);

  useEffect(() => {
    if (!qrChallenge || view !== "qr") return;
    let stopped = false;
    let timer: number | undefined;

    const poll = async () => {
      if (stopped || Date.now() >= qrChallenge.expiresAt) {
        setQrStatus("EXPIRED");
        return;
      }
      try {
        // Let an in-flight poll finish after the dialog closes: CONFIRMED is a
        // one-time response and may already have been consumed by the server.
        const result = await authAdapter.pollDeviceLogin(qrChallenge);
        if (result.status === "CONFIRMED" && result.session) {
          onAuthenticated(result.session);
          return;
        }
        if (stopped) return;
        setQrStatus(result.status);
        if (["EXPIRED", "CANCELED", "CONSUMED"].includes(result.status)) return;
        timer = window.setTimeout(poll, qrChallenge.pollIntervalMs);
      } catch (cause) {
        if (stopped) return;
        showError(cause);
      }
    };

    timer = window.setTimeout(poll, qrChallenge.pollIntervalMs);
    return () => {
      stopped = true;
      if (timer !== undefined) window.clearTimeout(timer);
    };
  }, [onAuthenticated, qrChallenge, qrRetryNonce, view]);

  useEffect(() => () => {
    startRequestRef.current?.abort();
    authAdapter.cancelMobileRegistration();
  }, []);

  const trapFocus = (event: ReactKeyboardEvent<HTMLElement>) => {
    if (event.key !== "Tab") return;
    const focusable = Array.from(
      dialogRef.current?.querySelectorAll<HTMLElement>(
        'button:not([disabled]), input:not([disabled]), [href], [tabindex]:not([tabindex="-1"])',
      ) ?? [],
    ).filter((element) => !element.hasAttribute("hidden"));
    if (focusable.length === 0) {
      event.preventDefault();
      return;
    }
    const first = focusable[0];
    const last = focusable[focusable.length - 1];
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault();
      last.focus();
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault();
      first.focus();
    }
  };

  const resetFeedback = () => {
    setError("");
    setNotice("");
  };

  const showError = (cause: unknown) => {
    if (cause instanceof AuthAdapterError || cause instanceof Error) {
      setError(cause.message);
    } else {
      setError("操作未完成，请重试。");
    }
  };

  const validateMobile = (inputId = "auth-mobile") => {
    if (mobilePattern.test(normalizeMainlandMobile(mobile))) return true;
    setError("请输入正确的 11 位手机号。");
    dialogRef.current?.querySelector<HTMLInputElement>(`#${inputId}`)?.focus();
    return false;
  };

  const validatePassword = (value: string, inputId: string) => {
    if (value.length >= 6 && value.length <= 32 && new TextEncoder().encode(value).length <= 72) {
      return true;
    }
    setError("密码需为 6 至 32 个字符，且内容不能过长。");
    dialogRef.current?.querySelector<HTMLInputElement>(`#${inputId}`)?.focus();
    return false;
  };

  const sendLoginCode = async () => {
    resetFeedback();
    if (!validateMobile()) return;
    setPendingAction("send-login-code");
    try {
      await authAdapter.sendMobileCode(mobile);
      setLoginResendSeconds(60);
      setNotice("验证码已发送，请查看手机短信。");
    } catch (cause) {
      showError(cause);
    } finally {
      setPendingAction(null);
    }
  };

  const loginWithCode = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    resetFeedback();
    if (!validateMobile()) return;
    if (!codePattern.test(code)) {
      setError("请输入 6 位短信验证码。");
      dialogRef.current?.querySelector<HTMLInputElement>("#auth-code")?.focus();
      return;
    }
    setPendingAction("login-code");
    try {
      onAuthenticated(await authAdapter.loginWithMobileCode(mobile, code));
    } catch (cause) {
      showError(cause);
    } finally {
      setPendingAction(null);
    }
  };

  const loginWithPassword = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    resetFeedback();
    if (!validateMobile() || !validatePassword(password, "auth-password")) return;
    setPendingAction("login-password");
    try {
      onAuthenticated(await authAdapter.loginWithPassword(mobile, password));
    } catch (cause) {
      showError(cause);
    } finally {
      setPendingAction(null);
    }
  };

  const sendRegistrationCode = async () => {
    resetFeedback();
    if (!validateMobile("auth-register-mobile")) return;
    setPendingAction("send-register-code");
    try {
      await authAdapter.sendMobileCode(mobile, "register");
      setRegistrationResendSeconds(60);
      setNotice("验证码已发送，请查看手机短信。");
    } catch (cause) {
      showError(cause);
    } finally {
      setPendingAction(null);
    }
  };

  const verifyRegistrationMobile = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    resetFeedback();
    if (!validateMobile("auth-register-mobile")) return;
    if (!codePattern.test(registrationCode)) {
      setError("请输入 6 位短信验证码。");
      dialogRef.current?.querySelector<HTMLInputElement>("#auth-register-code")?.focus();
      return;
    }
    setPendingAction("verify-register-mobile");
    try {
      await authAdapter.beginMobileRegistration(mobile, registrationCode);
      setRegistrationStep(2);
      setNotice("手机号验证完成，请设置登录密码。");
      window.setTimeout(() => {
        dialogRef.current?.querySelector<HTMLInputElement>("#auth-register-password")?.focus();
      }, 0);
    } catch (cause) {
      showError(cause);
    } finally {
      setPendingAction(null);
    }
  };

  const sendRegistrationPasswordCode = async () => {
    resetFeedback();
    setPendingAction("send-register-password-code");
    try {
      await authAdapter.sendRegistrationPasswordCode(mobile);
      setPasswordCodeResendSeconds(60);
      setNotice("设置密码验证码已发送，请查看手机短信。");
    } catch (cause) {
      showError(cause);
    } finally {
      setPendingAction(null);
    }
  };

  const completeRegistration = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    resetFeedback();
    if (!codePattern.test(registrationPasswordCode)) {
      setError("请输入 6 位设置密码验证码。");
      dialogRef.current?.querySelector<HTMLInputElement>("#auth-register-password-code")?.focus();
      return;
    }
    if (!validatePassword(registrationPassword, "auth-register-password")) return;
    if (registrationPassword !== registrationPasswordConfirm) {
      setError("两次输入的密码不一致。");
      dialogRef.current?.querySelector<HTMLInputElement>("#auth-register-password-confirm")?.focus();
      return;
    }
    setPendingAction("complete-register");
    try {
      onAuthenticated(await authAdapter.completeMobileRegistration(
        mobile,
        registrationPassword,
        registrationPasswordCode,
      ));
    } catch (cause) {
      showError(cause);
    } finally {
      setPendingAction(null);
    }
  };

  const resetRegistration = () => {
    authAdapter.cancelMobileRegistration();
    setRegistrationStep(1);
    setRegistrationCode("");
    setRegistrationPasswordCode("");
    setRegistrationPassword("");
    setRegistrationPasswordConfirm("");
    setShowRegistrationPassword(false);
    setRegistrationResendSeconds(0);
    setPasswordCodeResendSeconds(0);
  };

  const openRegistration = () => {
    startRequestRef.current?.abort();
    startRequestRef.current = null;
    resetFeedback();
    resetRegistration();
    setQrChallenge(null);
    setView("register");
    window.setTimeout(() => {
      dialogRef.current?.querySelector<HTMLInputElement>("#auth-register-mobile")?.focus();
    }, 0);
  };

  const openLogin = () => {
    startRequestRef.current?.abort();
    startRequestRef.current = null;
    resetFeedback();
    resetRegistration();
    setQrChallenge(null);
    setView("login");
    window.setTimeout(() => {
      dialogRef.current?.querySelector<HTMLInputElement>("#auth-mobile")?.focus();
    }, 0);
  };

  const startQrLogin = async () => {
    startRequestRef.current?.abort();
    const controller = new AbortController();
    startRequestRef.current = controller;
    resetFeedback();
    resetRegistration();
    setView("qr");
    setQrChallenge(null);
    setQrStatus("WAITING");
    setPendingAction("start-qr");
    try {
      setQrChallenge(await authAdapter.startDeviceLogin(controller.signal));
    } catch (cause) {
      if (!(cause instanceof DOMException && cause.name === "AbortError")) {
        showError(cause);
        setQrStatus("WAITING");
      }
    } finally {
      if (startRequestRef.current === controller) startRequestRef.current = null;
      setPendingAction(null);
    }
  };

  const retryQrLogin = () => {
    resetFeedback();
    setQrRetryNonce((value) => value + 1);
  };

  const showProviderUnavailable = (provider: "华为" | "Apple") => {
    setError("");
    setNotice(`${provider}桌面授权尚未接入，请先使用手机号或扫码登录。`);
  };

  const signOut = async () => {
    resetFeedback();
    setPendingAction("sign-out");
    try {
      const result = await authAdapter.signOut();
      onAuthenticated({ status: "signed-out", profile: null }, result.warning);
    } catch (cause) {
      showError(cause);
    } finally {
      setPendingAction(null);
    }
  };

  return (
    <div
      className="auth-dialog-overlay"
      onMouseDown={(event) => {
        if (event.target === event.currentTarget && !busy) {
          authAdapter.cancelMobileRegistration();
          onClose();
        }
      }}
    >
      <section
        ref={dialogRef}
        className={`auth-dialog ${session.status === "signed-in" ? "auth-dialog--account" : ""}`}
        role="dialog"
        aria-modal="true"
        aria-labelledby="auth-dialog-title"
        onKeyDown={trapFocus}
      >
        <button
          ref={closeButtonRef}
          type="button"
          className="auth-close-button"
          onClick={() => {
            authAdapter.cancelMobileRegistration();
            onClose();
          }}
          disabled={busy}
          aria-label="关闭账号弹窗"
          title="关闭"
        >
          <X size={18} aria-hidden="true" />
        </button>

        {session.status === "signed-in" && session.profile ? (
          <AccountView
            session={session}
            busy={pendingAction === "sign-out"}
            error={error}
            onSignOut={() => void signOut()}
          />
        ) : (
          <div className="auth-login-layout">
            <div className="auth-login-panel">
              {view === "login" ? (
                <LoginView
                  mobile={mobile}
                  code={code}
                  password={password}
                  mode={loginMode}
                  showPassword={showPassword}
                  busy={busy}
                  pendingAction={pendingAction}
                  resendSeconds={loginResendSeconds}
                  error={error}
                  notice={notice}
                  onMobileChange={setMobile}
                  onCodeChange={setCode}
                  onPasswordChange={setPassword}
                  onModeChange={(nextMode) => {
                    resetFeedback();
                    setLoginMode(nextMode);
                  }}
                  onTogglePassword={() => setShowPassword((visible) => !visible)}
                  onSendCode={() => void sendLoginCode()}
                  onCodeLogin={loginWithCode}
                  onPasswordLogin={loginWithPassword}
                  onRegister={openRegistration}
                  onQrLogin={() => void startQrLogin()}
                  onHuawei={() => showProviderUnavailable("华为")}
                  onApple={() => showProviderUnavailable("Apple")}
                />
              ) : view === "register" ? (
                <RegistrationView
                  step={registrationStep}
                  mobile={mobile}
                  code={registrationCode}
                  passwordCode={registrationPasswordCode}
                  password={registrationPassword}
                  passwordConfirm={registrationPasswordConfirm}
                  showPassword={showRegistrationPassword}
                  busy={busy}
                  pendingAction={pendingAction}
                  resendSeconds={registrationResendSeconds}
                  passwordCodeResendSeconds={passwordCodeResendSeconds}
                  error={error}
                  notice={notice}
                  onMobileChange={setMobile}
                  onCodeChange={setRegistrationCode}
                  onPasswordCodeChange={setRegistrationPasswordCode}
                  onPasswordChange={setRegistrationPassword}
                  onPasswordConfirmChange={setRegistrationPasswordConfirm}
                  onTogglePassword={() => setShowRegistrationPassword((visible) => !visible)}
                  onSendCode={() => void sendRegistrationCode()}
                  onVerifyMobile={verifyRegistrationMobile}
                  onSendPasswordCode={() => void sendRegistrationPasswordCode()}
                  onComplete={completeRegistration}
                  onBack={registrationStep === 1 ? openLogin : () => {
                    resetFeedback();
                    authAdapter.cancelMobileRegistration();
                    setRegistrationStep(1);
                    setRegistrationPasswordCode("");
                    setRegistrationPassword("");
                    setRegistrationPasswordConfirm("");
                  }}
                />
              ) : (
                <QrLogin
                  challenge={qrChallenge}
                  status={qrStatus}
                  seconds={qrSeconds}
                  loading={pendingAction === "start-qr"}
                  error={error}
                  onBack={openLogin}
                  onRefresh={() => void startQrLogin()}
                  onRetry={retryQrLogin}
                />
              )}
            </div>
            <CompanionPanel view={view} status={qrStatus} hasError={Boolean(error)} />
          </div>
        )}
      </section>
    </div>
  );
}

function LoginView({
  mobile,
  code,
  password,
  mode,
  showPassword,
  busy,
  pendingAction,
  resendSeconds,
  error,
  notice,
  onMobileChange,
  onCodeChange,
  onPasswordChange,
  onModeChange,
  onTogglePassword,
  onSendCode,
  onCodeLogin,
  onPasswordLogin,
  onRegister,
  onQrLogin,
  onHuawei,
  onApple,
}: {
  mobile: string;
  code: string;
  password: string;
  mode: LoginMode;
  showPassword: boolean;
  busy: boolean;
  pendingAction: PendingAction | null;
  resendSeconds: number;
  error: string;
  notice: string;
  onMobileChange: (value: string) => void;
  onCodeChange: (value: string) => void;
  onPasswordChange: (value: string) => void;
  onModeChange: (mode: LoginMode) => void;
  onTogglePassword: () => void;
  onSendCode: () => void;
  onCodeLogin: (event: FormEvent<HTMLFormElement>) => void;
  onPasswordLogin: (event: FormEvent<HTMLFormElement>) => void;
  onRegister: () => void;
  onQrLogin: () => void;
  onHuawei: () => void;
  onApple: () => void;
}) {
  return (
    <div className="auth-mobile-view">
      <header className="auth-title-block">
        <span className="auth-product-mark"><img src={appLogo} alt="" /></span>
        <div>
          <p>NekoPapa 账号</p>
          <h1 id="auth-dialog-title">登录 NekoPapa</h1>
          <span>使用已注册的手机号登录你的账号。</span>
        </div>
      </header>

      <div className="auth-mode-switch" role="tablist" aria-label="手机号登录方式">
        <button
          type="button"
          role="tab"
          aria-selected={mode === "code"}
          className={mode === "code" ? "is-active" : ""}
          onClick={() => onModeChange("code")}
          disabled={busy}
        >
          验证码登录
        </button>
        <button
          type="button"
          role="tab"
          aria-selected={mode === "password"}
          className={mode === "password" ? "is-active" : ""}
          onClick={() => onModeChange("password")}
          disabled={busy}
        >
          密码登录
        </button>
      </div>

      <form
        className="auth-form auth-form--login"
        onSubmit={mode === "code" ? onCodeLogin : onPasswordLogin}
        noValidate
      >
        <label className="auth-field" htmlFor="auth-mobile">
          <span>手机号</span>
          <span className="auth-input auth-input--mobile">
            <Phone size={17} aria-hidden="true" />
            <b>+86</b>
            <i aria-hidden="true" />
            <input
              id="auth-mobile"
              name="mobile"
              type="tel"
              inputMode="numeric"
              autoComplete="tel"
              value={mobile}
              onChange={(event) => onMobileChange(event.target.value.replace(/[^\d+\s-]/g, ""))}
              placeholder="请输入手机号"
              disabled={busy}
              maxLength={17}
              required
            />
          </span>
        </label>

        {mode === "code" ? (
          <CodeField
            id="auth-code"
            label="短信验证码"
            value={code}
            busy={busy}
            resendSeconds={resendSeconds}
            sending={pendingAction === "send-login-code"}
            onChange={onCodeChange}
            onSendCode={onSendCode}
          />
        ) : (
          <PasswordField
            id="auth-password"
            label="密码"
            value={password}
            showPassword={showPassword}
            busy={busy}
            autoComplete="current-password"
            placeholder="请输入登录密码"
            onChange={onPasswordChange}
            onToggle={onTogglePassword}
          />
        )}

        <div className="auth-feedback-slot">
          <Feedback error={error} notice={notice} />
        </div>

        <button type="submit" className="auth-primary-button" disabled={busy}>
          {pendingAction === "login-code" || pendingAction === "login-password" ? (
            <><LoaderCircle className="auth-spinner" size={16} aria-hidden="true" />正在登录</>
          ) : "登录"}
        </button>
      </form>

      <p className="auth-account-switch">还没有账号？<button type="button" onClick={onRegister} disabled={busy}>注册账号</button></p>

      <div className="auth-divider"><span>其他登录方式</span></div>
      <div className="auth-provider-grid" aria-label="其他登录方式">
        <button type="button" onClick={onHuawei} disabled={busy} title="华为桌面授权待接入">
          <BrandIcon icon={siHuawei} color="#cf0a2c" />
          <span>华为</span>
          <small>待接入</small>
        </button>
        <button type="button" onClick={onApple} disabled={busy} title="Apple 桌面授权待接入">
          <BrandIcon icon={siApple} color="#202124" />
          <span>Apple</span>
          <small>待接入</small>
        </button>
        <button type="button" onClick={onQrLogin} disabled={busy}>
          <QrCode size={20} aria-hidden="true" />
          <span>扫码</span>
          <small>手机确认</small>
        </button>
      </div>

      <p className="auth-security-note"><ShieldCheck size={13} aria-hidden="true" />登录凭据保存在 macOS 系统钥匙串</p>
    </div>
  );
}

function RegistrationView({
  step,
  mobile,
  code,
  passwordCode,
  password,
  passwordConfirm,
  showPassword,
  busy,
  pendingAction,
  resendSeconds,
  passwordCodeResendSeconds,
  error,
  notice,
  onMobileChange,
  onCodeChange,
  onPasswordCodeChange,
  onPasswordChange,
  onPasswordConfirmChange,
  onTogglePassword,
  onSendCode,
  onVerifyMobile,
  onSendPasswordCode,
  onComplete,
  onBack,
}: {
  step: RegistrationStep;
  mobile: string;
  code: string;
  passwordCode: string;
  password: string;
  passwordConfirm: string;
  showPassword: boolean;
  busy: boolean;
  pendingAction: PendingAction | null;
  resendSeconds: number;
  passwordCodeResendSeconds: number;
  error: string;
  notice: string;
  onMobileChange: (value: string) => void;
  onCodeChange: (value: string) => void;
  onPasswordCodeChange: (value: string) => void;
  onPasswordChange: (value: string) => void;
  onPasswordConfirmChange: (value: string) => void;
  onTogglePassword: () => void;
  onSendCode: () => void;
  onVerifyMobile: (event: FormEvent<HTMLFormElement>) => void;
  onSendPasswordCode: () => void;
  onComplete: (event: FormEvent<HTMLFormElement>) => void;
  onBack: () => void;
}) {
  return (
    <div className="auth-register-view">
      <button type="button" className="auth-back-button" onClick={onBack} disabled={busy} autoFocus>
        <ArrowLeft size={17} aria-hidden="true" />{step === 1 ? "返回登录" : "上一步"}
      </button>
      <header className="auth-title-block auth-title-block--register">
        <span className="auth-product-mark"><img src={appLogo} alt="" /></span>
        <div>
          <p>注册 NekoPapa 账号</p>
          <h1 id="auth-dialog-title">{step === 1 ? "验证手机号" : "设置登录密码"}</h1>
          <span>{step === 1 ? "先验证手机号，再为账号设置密码。" : "完成后可直接使用手机号和密码登录。"}</span>
        </div>
      </header>

      <ol className="auth-registration-progress" aria-label="注册进度">
        <li className="is-active"><span>{step === 2 ? <CheckCircle2 size={13} aria-hidden="true" /> : "1"}</span>验证手机号</li>
        <li className={step === 2 ? "is-active" : ""}><span>2</span>设置密码</li>
      </ol>

      {step === 1 ? (
        <form className="auth-form auth-form--register" onSubmit={onVerifyMobile} noValidate>
          <MobileField id="auth-register-mobile" value={mobile} busy={busy} onChange={onMobileChange} />
          <CodeField
            id="auth-register-code"
            label="短信验证码"
            value={code}
            busy={busy}
            resendSeconds={resendSeconds}
            sending={pendingAction === "send-register-code"}
            onChange={onCodeChange}
            onSendCode={onSendCode}
          />
          <div className="auth-feedback-slot"><Feedback error={error} notice={notice} /></div>
          <button type="submit" className="auth-primary-button" disabled={busy}>
            {pendingAction === "verify-register-mobile"
              ? <><LoaderCircle className="auth-spinner" size={16} aria-hidden="true" />正在验证</>
              : "下一步"}
          </button>
        </form>
      ) : (
        <form className="auth-form auth-form--register" onSubmit={onComplete} noValidate>
          <div className="auth-verified-mobile"><CheckCircle2 size={15} aria-hidden="true" /><span>已验证</span><strong>+86 {normalizeMainlandMobile(mobile)}</strong></div>
          <CodeField
            id="auth-register-password-code"
            label="设置密码验证码"
            value={passwordCode}
            busy={busy}
            resendSeconds={passwordCodeResendSeconds}
            sending={pendingAction === "send-register-password-code"}
            onChange={onPasswordCodeChange}
            onSendCode={onSendPasswordCode}
          />
          <PasswordField
            id="auth-register-password"
            label="设置密码"
            value={password}
            showPassword={showPassword}
            busy={busy}
            autoComplete="new-password"
            placeholder="6 至 32 个字符"
            onChange={onPasswordChange}
            onToggle={onTogglePassword}
          />
          <PasswordField
            id="auth-register-password-confirm"
            label="确认密码"
            value={passwordConfirm}
            showPassword={showPassword}
            busy={busy}
            autoComplete="new-password"
            placeholder="再次输入密码"
            onChange={onPasswordConfirmChange}
            onToggle={onTogglePassword}
          />
          <div className="auth-feedback-slot"><Feedback error={error} notice={notice} /></div>
          <button type="submit" className="auth-primary-button" disabled={busy}>
            {pendingAction === "complete-register"
              ? <><LoaderCircle className="auth-spinner" size={16} aria-hidden="true" />正在注册</>
              : "注册并登录"}
          </button>
        </form>
      )}
      <p className="auth-security-note"><ShieldCheck size={13} aria-hidden="true" />登录凭据保存在 macOS 系统钥匙串</p>
    </div>
  );
}

function MobileField({
  id,
  value,
  busy,
  onChange,
}: {
  id: string;
  value: string;
  busy: boolean;
  onChange: (value: string) => void;
}) {
  return (
    <label className="auth-field" htmlFor={id}>
      <span>手机号</span>
      <span className="auth-input auth-input--mobile">
        <Phone size={17} aria-hidden="true" />
        <b>+86</b>
        <i aria-hidden="true" />
        <input
          id={id}
          name="mobile"
          type="tel"
          inputMode="numeric"
          autoComplete="tel"
          value={value}
          onChange={(event) => onChange(event.target.value.replace(/[^\d+\s-]/g, ""))}
          placeholder="请输入手机号"
          disabled={busy}
          maxLength={17}
          required
        />
      </span>
    </label>
  );
}

function CodeField({
  id,
  label,
  value,
  busy,
  resendSeconds,
  sending,
  onChange,
  onSendCode,
}: {
  id: string;
  label: string;
  value: string;
  busy: boolean;
  resendSeconds: number;
  sending: boolean;
  onChange: (value: string) => void;
  onSendCode: () => void;
}) {
  return (
    <label className="auth-field" htmlFor={id}>
      <span>{label}</span>
      <span className="auth-code-row">
        <span className="auth-input">
          <KeyRound size={17} aria-hidden="true" />
          <input
            id={id}
            name="code"
            type="text"
            inputMode="numeric"
            autoComplete="one-time-code"
            value={value}
            onChange={(event) => onChange(event.target.value.replace(/\D/g, "").slice(0, 6))}
            placeholder="6 位验证码"
            disabled={busy}
            maxLength={6}
            required
          />
        </span>
        <button
          type="button"
          className="auth-send-code"
          onClick={onSendCode}
          disabled={busy || resendSeconds > 0}
        >
          {sending
            ? <LoaderCircle className="auth-spinner" size={15} aria-label="正在发送" />
            : resendSeconds > 0 ? `${resendSeconds}s` : "获取验证码"}
        </button>
      </span>
    </label>
  );
}

function PasswordField({
  id,
  label,
  value,
  showPassword,
  busy,
  autoComplete,
  placeholder,
  onChange,
  onToggle,
}: {
  id: string;
  label: string;
  value: string;
  showPassword: boolean;
  busy: boolean;
  autoComplete: "current-password" | "new-password";
  placeholder: string;
  onChange: (value: string) => void;
  onToggle: () => void;
}) {
  return (
    <label className="auth-field" htmlFor={id}>
      <span>{label}</span>
      <span className="auth-input auth-input--password">
        <LockKeyhole size={17} aria-hidden="true" />
        <input
          id={id}
          name={id}
          type={showPassword ? "text" : "password"}
          autoComplete={autoComplete}
          value={value}
          onChange={(event) => onChange(event.target.value)}
          placeholder={placeholder}
          disabled={busy}
          minLength={6}
          maxLength={32}
          required
        />
        <button
          type="button"
          className="auth-password-toggle"
          onClick={onToggle}
          disabled={busy}
          aria-label={showPassword ? "隐藏密码" : "显示密码"}
          title={showPassword ? "隐藏密码" : "显示密码"}
        >
          {showPassword ? <EyeOff size={17} aria-hidden="true" /> : <Eye size={17} aria-hidden="true" />}
        </button>
      </span>
    </label>
  );
}

function QrLogin({
  challenge,
  status,
  seconds,
  loading,
  error,
  onBack,
  onRefresh,
  onRetry,
}: {
  challenge: DeviceLoginChallenge | null;
  status: DeviceLoginStatus;
  seconds: number;
  loading: boolean;
  error: string;
  onBack: () => void;
  onRefresh: () => void;
  onRetry: () => void;
}) {
  const terminal = ["EXPIRED", "CANCELED", "CONSUMED"].includes(status);
  return (
    <div className="auth-qr-view">
      <button type="button" className="auth-back-button" onClick={onBack} autoFocus>
        <ArrowLeft size={17} aria-hidden="true" />手机号登录
      </button>
      <header className="auth-title-block auth-title-block--qr">
        <span className="auth-product-mark"><img src={appLogo} alt="" /></span>
        <div>
          <p>NekoBuddy 手机 App</p>
          <h1 id="auth-dialog-title">扫码登录</h1>
          <span>扫描二维码后，在手机上确认登录。</span>
        </div>
      </header>

      <div className={`auth-qr-code ${terminal ? "is-expired" : ""}`}>
        {challenge && !loading ? (
          <QRCodeSVG
            value={challenge.qrText}
            size={190}
            level="M"
            marginSize={4}
            bgColor="#ffffff"
            fgColor="#26231f"
            title="NekoBuddy 扫码登录二维码"
          />
        ) : loading ? (
          <LoaderCircle className="auth-spinner" size={28} aria-label="正在生成二维码" />
        ) : (
          <QrCode size={42} aria-hidden="true" />
        )}
        {terminal && challenge ? <span>已失效</span> : null}
      </div>

      <div className="auth-qr-state" role="status" aria-live="polite">
        <i className={status === "SCANNED" ? "is-scanned" : ""} />
        <strong>
          {loading
            ? "正在生成二维码"
            : error && !challenge
              ? "无法生成二维码"
              : qrStatusCopy[status]}
        </strong>
        {challenge && !terminal ? <small>{seconds}s 后过期</small> : null}
      </div>

      <Feedback error={error} />
      {error && challenge && !terminal ? (
        <button type="button" className="auth-secondary-button" onClick={onRetry} disabled={loading}>
          <RefreshCw size={15} aria-hidden="true" />重试当前二维码
        </button>
      ) : null}
      {terminal || (error && !challenge) ? (
        <button type="button" className="auth-secondary-button" onClick={onRefresh} disabled={loading}>
          <RefreshCw size={15} aria-hidden="true" />刷新二维码
        </button>
      ) : null}
      <p className="auth-security-note"><ShieldCheck size={13} aria-hidden="true" />只会在你确认后登录这台 Mac</p>
    </div>
  );
}

function CompanionPanel({
  view,
  status,
  hasError,
}: {
  view: AuthView;
  status: DeviceLoginStatus;
  hasError: boolean;
}) {
  const terminal = ["EXPIRED", "CANCELED", "CONSUMED"].includes(status);
  const state = view !== "qr"
    ? { label: view === "register" ? "创建账号" : "准备登录", className: "" }
    : hasError || terminal
      ? { label: hasError ? "连接失败" : qrStatusCopy[status], className: "is-error" }
      : status === "SCANNED"
        ? { label: "等待手机确认", className: "is-online" }
        : { label: "等待手机扫描", className: "" };
  return (
    <aside className="auth-companion" aria-label="NekoPapa 同伴 Lumia">
      <div className="auth-companion__copy">
        <span>LUMIA</span>
        <strong>{view === "qr"
          ? "在手机上确认后，\n我们就继续吧。"
          : view === "register"
            ? "注册完成后，\n一起开始吧。"
            : "欢迎回来，\n我一直在这里。"}</strong>
      </div>
      <img src={lumiaCutout} alt="Lumia" />
      <div className="auth-companion__status"><i className={state.className} />{state.label}</div>
    </aside>
  );
}

function AccountView({
  session,
  busy,
  error,
  onSignOut,
}: {
  session: AuthSessionSnapshot;
  busy: boolean;
  error: string;
  onSignOut: () => void;
}) {
  const [failedAvatarUrl, setFailedAvatarUrl] = useState("");
  const profile = session.profile;
  if (!profile) return null;
  const visibleAvatarUrl = profile.avatarUrl && profile.avatarUrl !== failedAvatarUrl
    ? profile.avatarUrl
    : undefined;
  const offline = session.verification === "offline";
  return (
    <div className="auth-account-view">
      <span className="auth-account-avatar" aria-hidden="true">
        {visibleAvatarUrl
          ? <img src={visibleAvatarUrl} alt="" onError={() => setFailedAvatarUrl(visibleAvatarUrl)} />
          : <UserRound size={42} strokeWidth={1.5} />}
      </span>
      <span className={`auth-account-state ${offline ? "is-offline" : ""}`}>
        {offline ? <WifiOff size={14} aria-hidden="true" /> : <CheckCircle2 size={14} aria-hidden="true" />}
        {offline ? "账号离线" : "账号已验证"}
      </span>
      <h1 id="auth-dialog-title">{profile.displayName}</h1>
      <p>{profile.phone || "已通过手机确认登录"}</p>
      <dl className="auth-account-details">
        <div><dt>登录方式</dt><dd>{loginChannelLabel(session.loginChannel)}</dd></div>
        <div><dt>账号方案</dt><dd>{accountPlanLabel(profile)}</dd></div>
        {profile.nekoId ? <div><dt>Neko ID</dt><dd>{profile.nekoId}</dd></div> : null}
      </dl>
      <Feedback error={error} />
      <button type="button" className="auth-danger-button" onClick={onSignOut} disabled={busy}>
        {busy ? <><LoaderCircle className="auth-spinner" size={16} aria-hidden="true" />正在退出</> : <><LogOut size={16} aria-hidden="true" />退出登录</>}
      </button>
      <p className="auth-security-note"><ShieldCheck size={13} aria-hidden="true" />账号凭据由 macOS 系统钥匙串保护</p>
    </div>
  );
}

function Feedback({ error, notice }: { error?: string; notice?: string }) {
  if (error) return <p className="auth-feedback auth-feedback--error" role="alert">{error}</p>;
  if (notice) return <p className="auth-feedback auth-feedback--notice" role="status"><CheckCircle2 size={14} aria-hidden="true" />{notice}</p>;
  return null;
}

function BrandIcon({ icon, color }: { icon: SimpleIcon; color: string }) {
  return (
    <svg viewBox="0 0 24 24" width="20" height="20" fill={color} aria-hidden="true">
      <path d={icon.path} />
    </svg>
  );
}

function loginChannelLabel(channel?: string) {
  if (channel === "PHONE_CODE") return "短信验证码";
  if (channel === "PASSWORD") return "手机号密码";
  if (channel === "PASSWORD_BIND") return "手机号密码";
  if (channel === "DESKTOP_DEVICE") return "手机扫码";
  return channel || "NekoBuddy 账号";
}

function accountPlanLabel(profile: AuthSessionSnapshot["profile"]) {
  if (!profile) return "免费体验";
  const cloudPlanCode = profile.cloudPlanCode?.trim().toUpperCase() || "FREE";
  const localLicenseCode = profile.localLicenseCode?.trim().toUpperCase() || "";
  const labels: string[] = [];
  if (["STARPORT_MONTH", "STATION_STARPORT_MONTH"].includes(cloudPlanCode)) labels.push("星港月卡");
  if (["STARPORT_YEAR", "STATION_STARPORT_YEAR"].includes(cloudPlanCode)) labels.push("星港年卡");
  if (profile.isBuyout || [
    "BUYOUT",
    "STATION_BUYOUT",
    "STATION_BUYOUT_LAUNCH",
    "STATION_BUYOUT_OFFICIAL",
  ].includes(localLicenseCode)) labels.push("本地许可");
  return labels.length > 0 ? labels.join(" + ") : "免费体验";
}
