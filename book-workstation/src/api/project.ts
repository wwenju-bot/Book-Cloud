import { request } from '@/utils/request'

export interface NovelProject {
  projectId?: number
  projectName: string
  sourceType?: string
  status?: string
  kbRootPath?: string
  remark?: string
  createTime?: string
}

export function listProject(params?: { pageNum?: number; pageSize?: number; projectName?: string }) {
  return request<NovelProject[]>({
    url: '/novel/project/list',
    method: 'get',
    params: { pageNum: 1, pageSize: 50, ...params }
  })
}

export function getProject(projectId: number | string) {
  return request<NovelProject>({
    url: `/novel/project/${projectId}`,
    method: 'get'
  })
}

export function addProject(data: NovelProject) {
  return request({
    url: '/novel/project',
    method: 'post',
    data
  })
}

export function updateProject(data: NovelProject) {
  return request({
    url: '/novel/project',
    method: 'put',
    data
  })
}

export function delProject(projectIds: number | string) {
  return request({
    url: `/novel/project/${projectIds}`,
    method: 'delete'
  })
}

export function exportProject(projectId: number | string, approvedOnly = false) {
  return request({
    url: `/novel/project/${projectId}/export`,
    method: 'get',
    params: { approvedOnly },
    responseType: 'blob',
    timeout: 120000
  }) as unknown as Promise<Blob>
}
