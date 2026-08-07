import axios, { type AxiosRequestConfig, type AxiosResponse } from 'axios'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getToken, removeToken, removeUsername } from './auth'
import router from '@/router'

export interface AjaxResult<T = any> {
  code: number
  msg: string
  data: T
  rows?: T[]
  total?: number
}

const service = axios.create({
  baseURL: import.meta.env.VITE_APP_BASE_API || '',
  timeout: 30000
})

service.interceptors.request.use(
  (config) => {
    const headers = (config.headers || {}) as Record<string, any>
    const skipToken = headers.isToken === false
    const token = getToken()
    if (token && !skipToken) {
      config.headers = config.headers || {}
      config.headers.Authorization = 'Bearer ' + token
    }
    return config
  },
  (error) => Promise.reject(error)
)

service.interceptors.response.use(
  (res: AxiosResponse) => {
    if (res.config.responseType === 'blob' || res.config.responseType === 'arraybuffer') {
      return res.data
    }
    const code = res.data?.code
    const msg = res.data?.msg || 'request failed'
    if (code === 401) {
      ElMessageBox.confirm('session expired, please login again', 'tip', {
        confirmButtonText: 're-login',
        cancelButtonText: 'cancel',
        type: 'warning'
      }).then(() => {
        removeToken()
        removeUsername()
        router.push('/login')
      }).catch(() => {})
      return Promise.reject(new Error(msg))
    }
    if (code !== undefined && code !== 200) {
      ElMessage.error(msg)
      return Promise.reject(new Error(msg))
    }
    return res.data
  },
  (error) => {
    const msg = error.response?.data?.msg || error.message || 'network error'
    ElMessage.error(msg)
    return Promise.reject(error)
  }
)

export function request<T = any>(config: AxiosRequestConfig): Promise<AjaxResult<T>> {
  return service(config) as Promise<AjaxResult<T>>
}

export default service
