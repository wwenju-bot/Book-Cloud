import { request } from '@/utils/request'

export interface SysUserInfo {
  userId?: number
  userName?: string
  nickName?: string
  avatar?: string
}

export function getUserInfo() {
  return request<{ user: SysUserInfo; roles?: string[]; permissions?: string[] }>({
    url: '/system/user/getInfo',
    method: 'get'
  })
}
