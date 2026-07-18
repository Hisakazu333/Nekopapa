import { getVersion } from "@tauri-apps/api/app";
import { isTauri } from "@tauri-apps/api/core";
import {
  clearSecureSession,
  getStableDeviceId,
  loadSecureSession,
  saveSecureSession,
} from "./secureSession";
import {
  AuthAdapterError,
  type AuthAdapter,
  type AuthProfile,
  type AuthSessionSnapshot,
  type DeviceLoginChallenge,
  type DeviceLoginPollResult,
  type DeviceLoginStatus,
} from "./types";

const configuredBaseUrl = import.meta.env.VITE_NEKO_API_BASE_URL?.trim();
export const NEKO_API_BASE_URL = configuredBaseUrl?.replace(/\/+$/, "") ?? "";

const signedOut: AuthSessionSnapshot = { status: "signed-out", profile: null };
const mobilePattern = /^1\d{10}$/;
const codePattern = /^\d{6}$/;
const minPasswordLength = 6;
const maxPasswordLength = 32;
const requestTimeoutMs = 15_000;
const deviceStatuses = new Set<DeviceLoginStatus>([
  "WAITING",
  "SCANNED",
  "CONFIRMED",
  "EXPIRED",
  "CANCELED",
  "CONSUMED",
]);

interface AjaxEnvelope<T> {
  code?: number | string;
  msg?: string;
  reasonCode?: string;
  data?: T;
}

interface BackendUserInfo {
  userId?: number | string;
  userName?: string;
  avatarUrl?: string;
  phoneNumber?: string;
  memberLevel?: string;
  nekoId?: string;
}

interface BackendAccountProfile extends BackendUserInfo {
  cloudPlanCode?: string;
  localLicenseCode?: string;
  isBuyout?: boolean | number | string;
}

interface BackendLoginResult {
  token?: string;
  loginChannel?: string;
  userInfo?: BackendUserInfo;
  cloudPlanCode?: string;
  localLicenseCode?: string;
  isBuyout?: boolean | number | string;
}

interface DeviceStartResult {
  sessionId?: string;
  deviceCode?: string;
  qrText?: string;
  expireSeconds?: number;
  pollIntervalMs?: number;
}

interface DevicePollResponse {
  status?: string;
  login?: BackendLoginResult;
}

interface RequestOptions {
  method?: "GET" | "POST";
  body?: object;
  signal?: AbortSignal;
  token?: string;
}

interface PendingRegistration {
  mobile: string;
  token: string;
}

let pendingRegistration: PendingRegistration | null = null;

export function normalizeMainlandMobile(value: string): string {
  let mobile = value.trim().replace(/[\s-]/g, "");
  if (mobile.startsWith("+86")) mobile = mobile.slice(3);
  else if (mobile.length === 13 && mobile.startsWith("86")) mobile = mobile.slice(2);
  return mobile;
}

const maskMobileForDisplay = (value: string) => {
  const mobile = normalizeMainlandMobile(value);
  return mobilePattern.test(mobile)
    ? mobile.replace(/^(\d{3})\d{4}(\d{4})$/, "$1****$2")
    : mobile;
};

const normalizedText = (value: unknown) => typeof value === "string" ? value.trim() : "";

const normalizedCommerceCode = (value: unknown) => {
  const code = normalizedText(value).toUpperCase();
  return code || undefined;
};

const booleanValue = (value: unknown) => {
  if (typeof value === "boolean") return value;
  if (typeof value === "number") return value === 1;
  return ["true", "1", "yes"].includes(normalizedText(value).toLowerCase());
};

const resolveAvatarUrl = (value: unknown) => {
  const avatarUrl = normalizedText(value);
  if (!avatarUrl) return undefined;
  if (/^https?:\/\//i.test(avatarUrl) || /^(data|blob):/i.test(avatarUrl)) return avatarUrl;
  if (avatarUrl.startsWith("//")) {
    return `${new URL(NEKO_API_BASE_URL).protocol}${avatarUrl}`;
  }
  try {
    return new URL(avatarUrl, `${NEKO_API_BASE_URL}/`).toString();
  } catch {
    return undefined;
  }
};

const request = async <T>(path: string, options: RequestOptions = {}): Promise<T | undefined> => {
  if (!NEKO_API_BASE_URL) {
    throw new AuthAdapterError(
      "unavailable",
      "未配置账号服务地址，请设置 VITE_NEKO_API_BASE_URL 后重新构建。",
    );
  }
  const { method = "POST", body, signal, token } = options;
  const controller = new AbortController();
  let timedOut = false;
  const handleCallerAbort = () => controller.abort();
  if (signal?.aborted) handleCallerAbort();
  else signal?.addEventListener("abort", handleCallerAbort, { once: true });
  const timeout = window.setTimeout(() => {
    timedOut = true;
    controller.abort();
  }, requestTimeoutMs);

  try {
    const headers: Record<string, string> = { Accept: "application/json" };
    if (body) headers["Content-Type"] = "application/json";
    if (token) headers.Authorization = `Bearer ${token}`;

    const response = await fetch(`${NEKO_API_BASE_URL}${path}`, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
      signal: controller.signal,
    });

    let envelope: AjaxEnvelope<T>;
    try {
      envelope = await response.json() as AjaxEnvelope<T>;
    } catch {
      if (!response.ok) {
        throw new AuthAdapterError("unavailable", "账号服务拒绝了本次请求。", response.status);
      }
      throw new AuthAdapterError("invalid-response", "账号服务返回了无法识别的数据。");
    }

    const businessCode = Number(envelope.code);
    if (!response.ok || (businessCode !== 200 && businessCode !== 0)) {
      const featureUnavailable = envelope.reasonCode === "FIRST_REVIEW_FEATURE_NOT_AVAILABLE"
        && path.startsWith("/api/app/auth/device/");
      throw new AuthAdapterError(
        "unavailable",
        featureUnavailable
          ? "当前账号服务未开放扫码登录，请使用手机号登录。"
          : envelope.msg?.trim() || "账号服务暂时不可用。",
        Number.isFinite(businessCode) ? businessCode : response.status,
      );
    }
    return envelope.data;
  } catch (cause) {
    if (cause instanceof AuthAdapterError) throw cause;
    if (signal?.aborted) throw new DOMException("Request aborted", "AbortError");
    if (timedOut) throw new AuthAdapterError("network", "连接账号服务超时，请稍后重试。");
    if (cause instanceof DOMException && cause.name === "AbortError") throw cause;
    throw new AuthAdapterError("network", "无法连接账号服务，请检查网络或服务地址。");
  } finally {
    window.clearTimeout(timeout);
    signal?.removeEventListener("abort", handleCallerAbort);
  }
};

const buildProfile = (
  info: BackendAccountProfile,
  login?: BackendLoginResult,
  mobileFallback = "",
): AuthProfile => {
  if (!info.userId) throw new AuthAdapterError("invalid-response", "账号资料响应缺少用户信息。");
  const phone = maskMobileForDisplay(normalizedText(info.phoneNumber) || mobileFallback);
  const displayName = normalizedText(info.userName)
    || (phone ? `手机用户 ${phone.slice(-4)}` : `NekoBuddy 用户 ${String(info.userId)}`);
  return {
    id: String(info.userId),
    displayName,
    phone,
    avatarUrl: resolveAvatarUrl(info.avatarUrl),
    nekoId: normalizedText(info.nekoId) || undefined,
    cloudPlanCode: normalizedCommerceCode(
      info.cloudPlanCode || login?.cloudPlanCode || info.memberLevel,
    ),
    localLicenseCode: normalizedCommerceCode(info.localLicenseCode || login?.localLicenseCode),
    isBuyout: booleanValue(info.isBuyout ?? login?.isBuyout),
  };
};

const revokeTokenBestEffort = async (token: string): Promise<void> => {
  try {
    await request("/logout", { method: "POST", token });
  } catch {
    // The local client must still fail closed when server revocation is unavailable.
  }
};

const loadBackendProfile = async (
  token: string,
  login?: BackendLoginResult,
  mobileFallback = "",
) => {
  const info = await request<BackendAccountProfile>("/api/app/user/profile", {
    method: "GET",
    token,
  });
  if (!info?.userId) {
    throw new AuthAdapterError("invalid-response", "账号资料响应缺少用户信息。");
  }
  const loginUserId = login?.userInfo?.userId;
  if (loginUserId !== undefined && String(loginUserId) !== String(info.userId)) {
    throw new AuthAdapterError("invalid-response", "登录账号与账号资料不一致。");
  }
  const profilePhone = normalizeMainlandMobile(normalizedText(info.phoneNumber));
  const loginPhone = normalizeMainlandMobile(mobileFallback);
  if (mobilePattern.test(loginPhone) && profilePhone !== loginPhone) {
    throw new AuthAdapterError("invalid-response", "登录手机号与账号资料不一致。");
  }
  return buildProfile(info, login, mobileFallback);
};

const persistLogin = async (
  login: BackendLoginResult,
  mobileFallback = "",
): Promise<AuthSessionSnapshot> => {
  const token = normalizedText(login.token);
  if (!token || !login.userInfo?.userId) {
    throw new AuthAdapterError("invalid-response", "登录成功响应缺少账号凭据。");
  }
  let profile: AuthProfile;
  try {
    profile = await loadBackendProfile(token, login, mobileFallback);
  } catch (cause) {
    await revokeTokenBestEffort(token);
    if (cause instanceof AuthAdapterError) {
      throw new AuthAdapterError(
        cause.code,
        `登录成功，但读取真实账号资料失败：${cause.message}`,
        cause.businessCode,
      );
    }
    throw cause;
  }
  try {
    await saveSecureSession({
      token,
      profile,
      loginChannel: login.loginChannel?.trim() || undefined,
    });
  } catch {
    await revokeTokenBestEffort(token);
    throw new AuthAdapterError("storage", "登录成功，但无法将凭据保存到系统钥匙串。");
  }
  return {
    status: "signed-in",
    profile,
    loginChannel: login.loginChannel?.trim() || undefined,
    verification: "verified",
  };
};

const getClientVersion = async () => {
  if (!isTauri()) return "web-preview";
  try {
    return await getVersion();
  } catch {
    return "unknown";
  }
};

export const backendAuthAdapter: AuthAdapter = {
  kind: "backend",

  async getSession() {
    let saved;
    try {
      saved = await loadSecureSession();
    } catch {
      throw new AuthAdapterError("storage", "无法从 macOS 系统钥匙串读取登录凭据。");
    }
    if (!saved) return signedOut;
    try {
      const profile = await loadBackendProfile(saved.token);
      if (JSON.stringify(profile) !== JSON.stringify(saved.profile)) {
        await saveSecureSession({ ...saved, profile });
      }
      return {
        status: "signed-in",
        profile,
        loginChannel: saved.loginChannel,
        verification: "verified",
      };
    } catch (cause) {
      if (cause instanceof AuthAdapterError && [401, 403].includes(cause.businessCode ?? 0)) {
        await clearSecureSession();
        return signedOut;
      }
      if (cause instanceof AuthAdapterError && cause.code === "network") {
        return {
          status: "signed-in",
          profile: saved.profile,
          loginChannel: saved.loginChannel,
          verification: "offline",
        };
      }
      throw cause;
    }
  },

  async sendMobileCode(input, scene = "login") {
    const mobile = normalizeMainlandMobile(input);
    if (!mobilePattern.test(mobile)) {
      throw new AuthAdapterError("invalid-mobile", "请输入正确的 11 位手机号。");
    }
    await request("/api/app/auth/mobile/code", { body: { mobile, scene } });
  },

  async loginWithMobileCode(input, code) {
    const mobile = normalizeMainlandMobile(input);
    if (!mobilePattern.test(mobile)) {
      throw new AuthAdapterError("invalid-mobile", "请输入正确的 11 位手机号。");
    }
    if (!codePattern.test(code)) {
      throw new AuthAdapterError("invalid-code", "请输入 6 位短信验证码。");
    }
    const login = await request<BackendLoginResult>("/api/app/auth/mobile/login", {
      body: {
        mobile,
        code,
        deviceId: await getStableDeviceId(),
      },
    });
    if (!login) throw new AuthAdapterError("invalid-response", "登录响应缺少账号数据。");
    return persistLogin(login, mobile);
  },

  async loginWithPassword(input, password) {
    const mobile = normalizeMainlandMobile(input);
    if (!mobilePattern.test(mobile)) {
      throw new AuthAdapterError("invalid-mobile", "请输入正确的 11 位手机号。");
    }
    if (password.length < minPasswordLength || password.length > maxPasswordLength) {
      throw new AuthAdapterError("invalid-code", "请输入 6 至 32 位密码。");
    }
    if (new TextEncoder().encode(password).length > 72) {
      throw new AuthAdapterError("invalid-code", "密码内容过长，请缩短后重试。");
    }
    const login = await request<BackendLoginResult>("/api/app/auth/password/login", {
      body: {
        mobile,
        password,
        deviceId: await getStableDeviceId(),
      },
    });
    if (!login) throw new AuthAdapterError("invalid-response", "登录响应缺少账号数据。");
    return persistLogin(login, mobile);
  },

  async beginMobileRegistration(input, code) {
    const mobile = normalizeMainlandMobile(input);
    if (!mobilePattern.test(mobile)) {
      throw new AuthAdapterError("invalid-mobile", "请输入正确的 11 位手机号。");
    }
    if (!codePattern.test(code)) {
      throw new AuthAdapterError("invalid-code", "请输入 6 位短信验证码。");
    }
    const login = await request<BackendLoginResult>("/api/app/auth/mobile/login", {
      body: {
        mobile,
        code,
        deviceId: await getStableDeviceId(),
      },
    });
    if (!login?.token || !login.userInfo?.userId) {
      throw new AuthAdapterError("invalid-response", "注册响应缺少账号凭据。");
    }
    pendingRegistration = { mobile, token: login.token };
  },

  async sendRegistrationPasswordCode(input) {
    const mobile = normalizeMainlandMobile(input);
    if (!pendingRegistration) {
      throw new AuthAdapterError("unavailable", "注册验证已失效，请重新验证手机号。");
    }
    if (mobile !== pendingRegistration.mobile) {
      pendingRegistration = null;
      throw new AuthAdapterError("invalid-mobile", "注册手机号已变更，请重新验证手机号。");
    }
    await request("/api/app/user/send-code", {
      token: pendingRegistration.token,
      body: { account: mobile, type: "phone" },
    });
  },

  async completeMobileRegistration(input, password, code) {
    const mobile = normalizeMainlandMobile(input);
    if (!pendingRegistration) {
      throw new AuthAdapterError("unavailable", "注册验证已失效，请重新验证手机号。");
    }
    if (mobile !== pendingRegistration.mobile) {
      pendingRegistration = null;
      throw new AuthAdapterError("invalid-mobile", "注册手机号已变更，请重新验证手机号。");
    }
    if (password.length < minPasswordLength || password.length > maxPasswordLength) {
      throw new AuthAdapterError("invalid-code", "密码长度应为 6 至 32 位。");
    }
    if (new TextEncoder().encode(password).length > 72) {
      throw new AuthAdapterError("invalid-code", "密码内容过长，请缩短后重试。");
    }
    if (!codePattern.test(code)) {
      throw new AuthAdapterError("invalid-code", "请输入 6 位设置密码验证码。");
    }

    const current = pendingRegistration;
    const login = await request<BackendLoginResult>("/api/app/auth/password/bind", {
      token: current.token,
      body: {
        mobile,
        password,
        code,
        deviceId: await getStableDeviceId(),
      },
    });
    if (!login) throw new AuthAdapterError("invalid-response", "注册响应缺少账号凭据。");
    try {
      const session = await persistLogin(login, mobile);
      pendingRegistration = null;
      return session;
    } catch (cause) {
      pendingRegistration = null;
      if (cause instanceof AuthAdapterError && cause.code === "storage") {
        throw new AuthAdapterError(
          "storage",
          "账号已创建，但凭据未能保存到系统钥匙串。请使用密码重新登录。",
        );
      }
      throw cause;
    }
  },

  cancelMobileRegistration() {
    const token = pendingRegistration?.token;
    pendingRegistration = null;
    if (token) void revokeTokenBestEffort(token);
  },

  async startDeviceLogin(signal) {
    const data = await request<DeviceStartResult>("/api/app/auth/device/start", {
      body: {
        clientType: "MACOS",
        deviceId: await getStableDeviceId(),
        deviceName: "NekoPapa for Mac",
        clientVersion: await getClientVersion(),
      },
      signal,
    });
    if (!data?.sessionId || !data.deviceCode || !data.qrText) {
      throw new AuthAdapterError("invalid-response", "扫码登录响应缺少二维码会话。");
    }
    const expireSeconds = Math.max(1, Number(data.expireSeconds) || 300);
    return {
      sessionId: data.sessionId,
      deviceCode: data.deviceCode,
      qrText: data.qrText,
      expiresAt: Date.now() + expireSeconds * 1000,
      pollIntervalMs: Math.max(800, Number(data.pollIntervalMs) || 1500),
    } satisfies DeviceLoginChallenge;
  },

  async pollDeviceLogin(challenge, signal) {
    const data = await request<DevicePollResponse>("/api/app/auth/device/poll", {
      body: {
        sessionId: challenge.sessionId,
        deviceCode: challenge.deviceCode,
      },
      signal,
    });
    if (!data?.status || !deviceStatuses.has(data.status as DeviceLoginStatus)) {
      throw new AuthAdapterError("invalid-response", "扫码登录返回了未知状态。");
    }
    const status = data.status as DeviceLoginStatus;
    if (status === "CONFIRMED") {
      if (!data.login) {
        throw new AuthAdapterError("invalid-response", "扫码已确认，但登录凭据缺失。");
      }
      return { status, session: await persistLogin(data.login) } satisfies DeviceLoginPollResult;
    }
    return { status } satisfies DeviceLoginPollResult;
  },

  async signOut() {
    let warning: string | undefined;
    try {
      const saved = await loadSecureSession();
      if (saved) {
        try {
          await request("/logout", { method: "POST", token: saved.token });
        } catch {
          warning = "本机已退出，但服务端会话未确认撤销。";
        }
      }
    } finally {
      try {
        await clearSecureSession();
      } catch {
        throw new AuthAdapterError("storage", "无法从系统钥匙串清除登录凭据。");
      }
    }
    return { warning };
  },
};
