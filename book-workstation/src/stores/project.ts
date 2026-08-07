import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { NovelProject } from '@/api/project'
import { getProject } from '@/api/project'

export const useProjectStore = defineStore('project', () => {
  const current = ref<NovelProject | null>(null)

  async function loadProject(projectId: number | string) {
    const res = await getProject(projectId)
    current.value = res.data
    return res.data
  }

  function clear() {
    current.value = null
  }

  return { current, loadProject, clear }
})
