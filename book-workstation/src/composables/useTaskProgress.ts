import { request } from '@/utils/request'

export interface NovelGenerationTask {
  taskId?: number
  projectId?: number
  taskType?: string
  status?: string
  progress?: number
  resultRef?: string
  errorMsg?: string
}

export function getTask(taskId: number | string) {
  return request<NovelGenerationTask>({
    url: `/novel/task/${taskId}`,
    method: 'get'
  })
}

export function retryTask(taskId: number | string) {
  return request<number>({
    url: `/novel/task/${taskId}/retry`,
    method: 'post'
  })
}

/** Poll until success/failed. Throws on failed. */
export async function waitForTask(
  taskId: number | string,
  onProgress?: (progress: number, task: NovelGenerationTask) => void
): Promise<NovelGenerationTask> {
  const maxAttempts = 600
  for (let i = 0; i < maxAttempts; i++) {
    const res = await getTask(taskId)
    const task = res.data
    onProgress?.(task.progress ?? 0, task)
    if (task.status === 'success') {
      return task
    }
    if (task.status === 'failed') {
      throw new Error(task.errorMsg || 'task failed')
    }
    await new Promise((r) => setTimeout(r, 1000))
  }
  throw new Error('task timeout')
}
