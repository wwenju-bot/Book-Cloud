import { request } from '@/utils/request'

export interface NovelChapter {
  chapterId?: number
  projectId?: number
  chapterNo?: number
  title?: string
  status?: string
  latestVersionId?: number
  createTime?: string
}

export interface NovelChapterVersion {
  versionId?: number
  chapterId?: number
  versionNo?: number
  content?: string
  modelSource?: string
  optimizeRound?: number
  score?: number
  reviewStatus?: string
  kbFilePath?: string
  remark?: string
  createTime?: string
}

export function generateChapter(
  projectId: number | string,
  data: { chapterNo: number; chapterTitle: string; extraInstruction?: string }
) {
  return request<number>({
    url: `/novel/project/${projectId}/chapter/generate`,
    method: 'post',
    data,
    timeout: 30000
  })
}

export function listChapters(projectId: number | string) {
  return request<NovelChapter[]>({
    url: `/novel/project/${projectId}/chapter/list`,
    method: 'get'
  })
}

export function listChapterVersions(chapterId: number | string) {
  return request<NovelChapterVersion[]>({
    url: `/novel/chapter/${chapterId}/versions`,
    method: 'get'
  })
}

export function reviewChapterVersion(
  versionId: number | string,
  result: 'pass' | 'reject',
  comment?: string
) {
  return request<NovelChapterVersion>({
    url: `/novel/chapter/version/${versionId}/review`,
    method: 'post',
    data: { result, comment }
  })
}

export function promoteChapterVersion(versionId: number | string) {
  return request<NovelChapterVersion>({
    url: `/novel/chapter/version/${versionId}/promote`,
    method: 'post'
  })
}
