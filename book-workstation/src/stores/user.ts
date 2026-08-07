import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { getToken, setToken, removeToken, getUsername, setUsername, removeUsername } from '@/utils/auth'
import { getCodeImg, login as loginApi } from '@/api/auth'
import { getUserInfo } from '@/api/user'

const BRAND_PREFIX = '\u5c0f\u8bf4\u81ea\u52a8\u5316\u521b\u4f5c\u5e73\u53f0'

export const useUserStore = defineStore('user', () => {
  const token = ref(getToken())
  const username = ref(getUsername())
  const nickName = ref('')
  const userId = ref<number | null>(null)
  const roles = ref<string[]>([])

  const displayName = computed(() => {
    const name = username.value && username.value !== 'user' ? username.value : ''
    if (name) {
      return `${BRAND_PREFIX}-${name}`
    }
    return nickName.value || BRAND_PREFIX
  })

  async function login(loginForm: { username: string; password: string; code?: string; uuid?: string }) {
    const res = await loginApi(loginForm)
    const accessToken = (res.data as any)?.access_token || (res as any).access_token
    if (!accessToken) {
      throw new Error('login response missing access_token')
    }
    token.value = accessToken
    setToken(accessToken)
    await fetchProfile()
  }

  async function fetchProfile() {
    if (!getToken()) {
      return null
    }
    const res: any = await getUserInfo()
    // RuoYi getInfo returns { code, user, roles, permissions } at top level
    const user = res.user || res.data?.user || {}
    username.value = user.userName || username.value || ''
    nickName.value = user.nickName || ''
    userId.value = user.userId ?? null
    roles.value = res.roles || res.data?.roles || []
    if (username.value) {
      setUsername(username.value)
    }
    // Prefer DB nickName (e.g. ��????????????-ry); fallback to brand-username
    if (!nickName.value && username.value) {
      nickName.value = `${BRAND_PREFIX}-${username.value}`
    }
    return user
  }

  function logout() {
    token.value = ''
    username.value = ''
    nickName.value = ''
    userId.value = null
    roles.value = []
    removeToken()
    removeUsername()
  }

  async function fetchCaptcha() {
    return getCodeImg()
  }

  return {
    token,
    username,
    nickName,
    userId,
    roles,
    displayName,
    login,
    logout,
    fetchCaptcha,
    fetchProfile
  }
})
