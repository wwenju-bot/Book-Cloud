<template>
  <div class="page-card">
    <div class="toolbar">
      <h2 class="page-title">{{ zh.materials }}</h2>
      <div class="actions">
        <el-button :loading="loading" @click="loadList">{{ zh.refresh }}</el-button>
        <el-upload :show-file-list="false" :http-request="onUpload" accept=".txt,.md,.markdown,text/plain">
          <el-button type="primary" :loading="uploading">{{ zh.uploadBtn }}</el-button>
        </el-upload>
      </div>
    </div>
    <el-alert :title="zh.uploadTip" type="info" :closable="false" show-icon />
    <el-table v-loading="loading" :data="files" class="file-table" empty-text="">
      <el-table-column prop="name" :label="zh.fileName" min-width="220" />
      <el-table-column prop="path" :label="zh.kbPath" min-width="280" />
    </el-table>
    <el-empty v-if="!loading && !files.length" :description="zh.noUpload" />
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import type { UploadRequestOptions } from 'element-plus'
import { ElMessage } from 'element-plus'
import { listMaterials, uploadMaterial } from '@/api/architecture'
import { zh } from '@/locales/zh'

const DIR_REFERENCE = '04-\u521b\u4f5c\u53c2\u8003\u8d44\u6599'

const route = useRoute()
const uploading = ref(false)
const loading = ref(false)
const files = ref<{ name: string; path: string }[]>([])

const projectId = () => route.params.projectId as string

async function loadList() {
  if (!projectId()) {
    return
  }
  loading.value = true
  try {
    const res = await listMaterials(projectId())
    const names = (res.data || []) as string[]
    files.value = names.map((name) => ({
      name,
      path: `${DIR_REFERENCE}/${name}`
    }))
  } finally {
    loading.value = false
  }
}

async function onUpload(options: UploadRequestOptions) {
  const file = options.file as File
  uploading.value = true
  try {
    const res = await uploadMaterial(projectId(), file)
    const path = (res.data as unknown as string) || ''
    ElMessage.success(zh.uploadOk + (path ? `��${path}` : ''))
    options.onSuccess?.(res as any)
    await loadList()
  } catch (e) {
    options.onError?.(e as any)
  } finally {
    uploading.value = false
  }
}

onMounted(loadList)
watch(() => route.params.projectId, loadList)
</script>

<style scoped>
.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}
.actions {
  display: flex;
  align-items: center;
  gap: 8px;
}
.file-table {
  margin-top: 20px;
}
</style>
