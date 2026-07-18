export type AuthLoginMethod = "mobile" | "qr";

export interface AuthProfile {
  id: string;
  displayName: string;
  phone: string;
  avatarUrl?: string;
  nekoId?: string;
  cloudPlanCode?: string;
  localLicenseCode?: string;
  isBuyout?: boolean;
}

export interface AuthSessionSnapshot {
  status: "signed-out" | "signed-in";
  profile: AuthProfile | null;
  loginChannel?: string;
  verification?: "verified" | "offline";
}

export type DeviceLoginStatus =
  | "WAITING"
  | "SCANNED"
  | "CONFIRMED"
  | "EXPIRED"
  | "CANCELED"
  | "CONSUMED";

export interface DeviceLoginChallenge {
  sessionId: string;
  deviceCode: string;
  qrText: string;
  expiresAt: number;
  pollIntervalMs: number;
}

export interface DeviceLoginPollResult {
  status: DeviceLoginStatus;
  session?: AuthSessionSnapshot;
}

export interface SignOutResult {
  warning?: string;
}

export interface AuthAdapter {
  readonly kind: "backend";
  getSession(): Promise<AuthSessionSnapshot>;
  sendMobileCode(mobile: string, scene?: "login" | "register"): Promise<void>;
  loginWithMobileCode(mobile: string, code: string): Promise<AuthSessionSnapshot>;
  loginWithPassword(mobile: string, password: string): Promise<AuthSessionSnapshot>;
  beginMobileRegistration(mobile: string, code: string): Promise<void>;
  sendRegistrationPasswordCode(mobile: string): Promise<void>;
  completeMobileRegistration(
    mobile: string,
    password: string,
    code: string,
  ): Promise<AuthSessionSnapshot>;
  cancelMobileRegistration(): void;
  startDeviceLogin(signal?: AbortSignal): Promise<DeviceLoginChallenge>;
  pollDeviceLogin(
    challenge: Pick<DeviceLoginChallenge, "sessionId" | "deviceCode">,
    signal?: AbortSignal,
  ): Promise<DeviceLoginPollResult>;
  signOut(): Promise<SignOutResult>;
}

export type AuthAdapterErrorCode =
  | "invalid-mobile"
  | "invalid-code"
  | "invalid-response"
  | "network"
  | "storage"
  | "expired"
  | "remote-signout"
  | "unavailable";

export class AuthAdapterError extends Error {
  constructor(
    readonly code: AuthAdapterErrorCode,
    message: string,
    readonly businessCode?: number,
  ) {
    super(message);
    this.name = "AuthAdapterError";
  }
}
