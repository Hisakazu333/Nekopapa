import { invoke, isTauri } from "@tauri-apps/api/core";
import type { AuthProfile } from "./types";

export interface SecureAuthSession {
  token: string;
  profile: AuthProfile;
  loginChannel?: string;
}

let browserSession: SecureAuthSession | null = null;
let browserDeviceId: string | null = null;

const isSecureAuthSession = (value: unknown): value is SecureAuthSession => {
  if (!value || typeof value !== "object") return false;
  const candidate = value as Partial<SecureAuthSession>;
  return typeof candidate.token === "string"
    && candidate.token.length > 0
    && Boolean(candidate.profile)
    && typeof candidate.profile?.id === "string"
    && typeof candidate.profile?.displayName === "string";
};

export async function loadSecureSession(): Promise<SecureAuthSession | null> {
  if (!isTauri()) return browserSession;

  const session = await invoke<unknown>("load_auth_session");
  if (session === null) return null;
  if (isSecureAuthSession(session)) return session;
  await invoke("clear_auth_session");
  throw new Error("Authentication session in macOS Keychain is invalid");
}

export async function saveSecureSession(session: SecureAuthSession): Promise<void> {
  if (!isTauri()) {
    browserSession = session;
    return;
  }
  await invoke("save_auth_session", { session });
}

export async function clearSecureSession(): Promise<void> {
  browserSession = null;
  if (isTauri()) await invoke("clear_auth_session");
}

export async function getStableDeviceId(): Promise<string> {
  if (!isTauri()) {
    browserDeviceId ??= `nekopapa-web-${crypto.randomUUID()}`;
    return browserDeviceId;
  }
  return invoke<string>("get_auth_device_id");
}
