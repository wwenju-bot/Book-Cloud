import { request } from '@/utils/request'

export function getCodeImg() {
  return request<{ captchaEnabled?: boolean; img: string; uuid: string }>({
    url: '/code',
    method: 'get',
    headers: {
      isToken: false,
      Accept: 'text/plain, application/json, */*'
    } as any,
    timeout: 20000
  })
}

export function login(data: { username: string; password: string; code?: string; uuid?: string }) {
  return request<{ access_token: string }>({
    url: '/auth/login',
    method: 'post',
    headers: { isToken: false } as any,
    data
  })
}
