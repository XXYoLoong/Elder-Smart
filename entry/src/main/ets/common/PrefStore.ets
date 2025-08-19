// ==== 本地偏好存储（基于 AppStorage，同步版）====

// —— 用户资料 —— //
export interface Profile {
  nickname: string
  city: string
  avatarUri: string
}
export const defaultProfile: Profile = {
  nickname: '李奶奶',
  city: '上海',
  avatarUri: ''
}

// —— 设置项 —— //
export interface Settings {
  bigText: boolean
  soundOn: boolean
}
export const defaultSettings: Settings = {
  bigText: false,
  soundOn: true
}

// —— AppStorage Key —— //
const KEY_NICK = 'nickname'
const KEY_CITY = 'city'
const KEY_AVATAR = 'avatarUri'
const KEY_BIGTEXT = 'set_big_text'
const KEY_SOUND = 'set_sound_on'

// —— 字符串/布尔类型安全读写工具 —— //
function getStringOrDefault(key: string, def: string): string {
  return AppStorage.Has(key) ? (AppStorage.Get(key) as string) : def
}
function getBoolOrDefault(key: string, def: boolean): boolean {
  return AppStorage.Has(key) ? (AppStorage.Get(key) as boolean) : def
}
function setString(key: string, v: string): void {
  AppStorage.SetOrCreate(key, v)
}
function setBool(key: string, v: boolean): void {
  AppStorage.SetOrCreate(key, v)
}

// —— Profile：同步读/写 —— //
export function loadProfile(): Profile {
  return {
    nickname: getStringOrDefault(KEY_NICK, defaultProfile.nickname),
    city: getStringOrDefault(KEY_CITY, defaultProfile.city),
    avatarUri: getStringOrDefault(KEY_AVATAR, defaultProfile.avatarUri),
  }
}
export function saveProfile(p: Profile): void {
  setString(KEY_NICK, p.nickname)
  setString(KEY_CITY, p.city)
  setString(KEY_AVATAR, p.avatarUri)
}

// —— Settings：同步读/写 —— //
export function loadSettings(): Settings {
  return {
    bigText: getBoolOrDefault(KEY_BIGTEXT, defaultSettings.bigText),
    soundOn: getBoolOrDefault(KEY_SOUND, defaultSettings.soundOn),
  }
}
export function saveSettings(s: Settings): void {
  setBool(KEY_BIGTEXT, s.bigText)
  setBool(KEY_SOUND, s.soundOn)
}
