import { request } from '@/utils/request'

export interface ArchitectureVersion {
  versionId?: number
  projectId?: number
  versionNo?: number
  content?: string
  source?: string
  reviewStatus?: string
  reviewComment?: string
  kbFilePath?: string
  createTime?: string
}

export function uploadMaterial(projectId: number | string, file: File) {
  const form = new FormData()
  form.append('file', file)
  return request<string>({
    url: `/novel/project/${projectId}/upload`,
    method: 'post',
    data: form,
    headers: { 'Content-Type': 'multipart/form-data' },
    timeout: 60000
  })
}

export function listMaterials(projectId: number | string) {
  return request<string[]>({
    url: `/novel/project/${projectId}/materials`,
    method: 'get'
  })
}

export function parseArchitecture(projectId: number | string) {
  return request<number>({
    url: `/novel/project/${projectId}/architecture/parse`,
    method: 'post',
    timeout: 30000
  })
}

export function optimizeArchitecture(versionId: number | string) {
  return request<number>({
    url: `/novel/architecture/version/${versionId}/optimize`,
    method: 'post',
    timeout: 30000
  })
}

export interface DiffLine {
  type: string
  left: string
  right: string
}

export interface ArchitectureDiffResult {
  leftVersionId?: number
  rightVersionId?: number
  leftVersionNo?: number
  rightVersionNo?: number
  lines?: DiffLine[]
}

export function diffArchitecture(versionId: number | string, compareTo: number | string) {
  return request<ArchitectureDiffResult>({
    url: `/novel/architecture/version/${versionId}/diff`,
    method: 'get',
    params: { compareTo }
  })
}

export function listArchitectureVersions(projectId: number | string) {
  return request<ArchitectureVersion[]>({
    url: `/novel/project/${projectId}/architecture/versions`,
    method: 'get'
  })
}

export function getArchitectureVersion(versionId: number | string) {
  return request<ArchitectureVersion>({
    url: `/novel/architecture/version/${versionId}`,
    method: 'get'
  })
}

export function updateArchitectureContent(versionId: number | string, content: string) {
  return request<ArchitectureVersion>({
    url: `/novel/architecture/version/${versionId}`,
    method: 'put',
    data: { content }
  })
}

export function reviewArchitecture(versionId: number | string, result: 'pass' | 'reject', comment?: string) {
  return request<ArchitectureVersion>({
    url: `/novel/architecture/version/${versionId}/review`,
    method: 'post',
    data: { result, comment }
  })
}
