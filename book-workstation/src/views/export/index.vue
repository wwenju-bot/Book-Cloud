<template>
  <div class="page-card">
    <h2 class="page-title">{{ zh.exportTitle }}</h2>
    <p class="desc">{{ zh.exportDesc }}</p>
    <el-checkbox v-model="approvedOnly" class="mb">{{ zh.approvedOnly }}</el-checkbox>
    <div>
      <el-button type="primary" :loading="exporting" @click="onExport">{{ zh.downloadZip }}</el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { exportProject } from '@/api/project'
import { useProjectStore } from '@/stores/project'
import { zh } from '@/locales/zh'

const route = useRoute()
const projectStore = useProjectStore()
const exporting = ref(false)
const approvedOnly = ref(false)

async function onExport() {
  exporting.value = true
  try {
    const blob = await exportProject(route.params.projectId as string, approvedOnly.value)
    const name = projectStore.current?.projectName || 'project'
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `${name}-${Date.now()}.zip`
    a.click()
    window.URL.revokeObjectURL(url)
    ElMessage.success(zh.downloadStarted)
  } finally {
    exporting.value = false
  }
}
</script>

<style scoped>
.desc { color: #6b7280; margin: 0 0 16px; }
.mb { display: block; margin-bottom: 16px; }
</style>
