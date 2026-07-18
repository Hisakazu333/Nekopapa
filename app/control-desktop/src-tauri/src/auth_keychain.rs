use serde::{Deserialize, Serialize};

const KEYCHAIN_SERVICE: &str = "ai.nekopapa.desktop";
const KEYCHAIN_ACCOUNT: &str = "neko-auth-token";
const DEVICE_ID_ACCOUNT: &str = "neko-device-id";

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct KeychainSession {
    token: String,
    profile: serde_json::Value,
    login_channel: Option<String>,
}

impl KeychainSession {
    fn validate(&self) -> Result<(), String> {
        if self.token.trim().is_empty() {
            return Err("Authentication session token cannot be empty".to_string());
        }

        Ok(())
    }
}

#[cfg(target_os = "macos")]
mod platform {
    use super::{DEVICE_ID_ACCOUNT, KEYCHAIN_ACCOUNT, KEYCHAIN_SERVICE, KeychainSession};
    use security_framework::{base::Error, passwords};

    // macOS Security.framework returns this OSStatus when the item does not exist.
    const ERR_SEC_ITEM_NOT_FOUND: i32 = -25_300;

    fn format_keychain_error(action: &str, error: Error) -> String {
        format!(
            "Failed to {action} authentication session in macOS Keychain (OSStatus {})",
            error.code()
        )
    }

    pub fn save(session: KeychainSession) -> Result<(), String> {
        session.validate()?;
        let payload = serde_json::to_vec(&session)
            .map_err(|error| format!("Failed to encode authentication session: {error}"))?;

        passwords::set_generic_password(KEYCHAIN_SERVICE, KEYCHAIN_ACCOUNT, &payload)
            .map_err(|error| format_keychain_error("save", error))
    }

    pub fn load() -> Result<Option<KeychainSession>, String> {
        let payload = match passwords::get_generic_password(KEYCHAIN_SERVICE, KEYCHAIN_ACCOUNT) {
            Ok(payload) => payload,
            Err(error) if error.code() == ERR_SEC_ITEM_NOT_FOUND => return Ok(None),
            Err(error) => return Err(format_keychain_error("load", error)),
        };

        let session: KeychainSession = serde_json::from_slice(&payload).map_err(|error| {
            format!("Authentication session in macOS Keychain is invalid: {error}")
        })?;
        session.validate()?;

        Ok(Some(session))
    }

    pub fn clear() -> Result<(), String> {
        match passwords::delete_generic_password(KEYCHAIN_SERVICE, KEYCHAIN_ACCOUNT) {
            Ok(()) => Ok(()),
            Err(error) if error.code() == ERR_SEC_ITEM_NOT_FOUND => Ok(()),
            Err(error) => Err(format_keychain_error("delete", error)),
        }
    }

    pub fn device_id() -> Result<String, String> {
        match passwords::get_generic_password(KEYCHAIN_SERVICE, DEVICE_ID_ACCOUNT) {
            Ok(payload) => String::from_utf8(payload)
                .map_err(|_| "Device identifier in macOS Keychain is invalid".to_string()),
            Err(error) if error.code() == ERR_SEC_ITEM_NOT_FOUND => {
                let value = format!("nekopapa-{}", uuid::Uuid::new_v4());
                passwords::set_generic_password(
                    KEYCHAIN_SERVICE,
                    DEVICE_ID_ACCOUNT,
                    value.as_bytes(),
                )
                .map_err(|error| format_keychain_error("save device identifier", error))?;
                Ok(value)
            }
            Err(error) => Err(format_keychain_error("load device identifier", error)),
        }
    }
}

#[cfg(not(target_os = "macos"))]
mod platform {
    use super::KeychainSession;

    const UNSUPPORTED: &str = "Authentication session storage is only supported on macOS";

    pub fn save(_session: KeychainSession) -> Result<(), String> {
        Err(UNSUPPORTED.to_string())
    }

    pub fn load() -> Result<Option<KeychainSession>, String> {
        Err(UNSUPPORTED.to_string())
    }

    pub fn clear() -> Result<(), String> {
        Err(UNSUPPORTED.to_string())
    }

    pub fn device_id() -> Result<String, String> {
        Err(UNSUPPORTED.to_string())
    }
}

#[tauri::command]
pub fn save_auth_session(session: KeychainSession) -> Result<(), String> {
    platform::save(session)
}

#[tauri::command]
pub fn load_auth_session() -> Result<Option<KeychainSession>, String> {
    platform::load()
}

#[tauri::command]
pub fn clear_auth_session() -> Result<(), String> {
    platform::clear()
}

#[tauri::command]
pub fn get_auth_device_id() -> Result<String, String> {
    platform::device_id()
}
