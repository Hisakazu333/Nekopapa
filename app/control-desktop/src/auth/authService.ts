import { backendAuthAdapter } from "./backendAuthAdapter";

export const authAdapter = backendAuthAdapter;

export { NEKO_API_BASE_URL, normalizeMainlandMobile } from "./backendAuthAdapter";
export type {
  AuthAdapter,
  AuthLoginMethod,
  AuthProfile,
  AuthSessionSnapshot,
  DeviceLoginChallenge,
  DeviceLoginPollResult,
  DeviceLoginStatus,
  SignOutResult,
} from "./types";
export { AuthAdapterError } from "./types";
