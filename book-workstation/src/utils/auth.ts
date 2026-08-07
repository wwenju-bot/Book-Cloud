const TokenKey = 'Book-Workstation-Token'
const UsernameKey = 'Book-Workstation-Username'

export function getToken(): string {
  return localStorage.getItem(TokenKey) || ''
}

export function setToken(token: string) {
  localStorage.setItem(TokenKey, token)
}

export function removeToken() {
  localStorage.removeItem(TokenKey)
}

export function getUsername(): string {
  return localStorage.getItem(UsernameKey) || ''
}

export function setUsername(username: string) {
  localStorage.setItem(UsernameKey, username)
}

export function removeUsername() {
  localStorage.removeItem(UsernameKey)
}

/** Accept book-ui JWT (same auth center) for SSO entry. */
export function applySsoToken(token: string, username?: string) {
  const cleaned = (token || '').replace(/^Bearer\s+/i, '').trim()
  if (!cleaned) {
    return false
  }
  setToken(cleaned)
  // Do not placeholder as "user"; fetchProfile will fill real userName/nickName.
  if (username) {
    setUsername(username)
  }
  return true
}
