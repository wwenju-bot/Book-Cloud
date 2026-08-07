<template>
  <div class="page-card">
    <div class="toolbar">
      <h2 class="page-title">{{ zh.architecture }}</h2>
      <div class="actions">
        <el-button :loading="parsing" type="warning" :disabled="optimizing" @click="onParse">
          {{ parsing ? `${zh.parsing} ${parseProgress}%` : zh.parseBtn }}
        </el-button>
        <el-button :loading="optimizing" type="primary" :disabled="!current || parsing" @click="onOptimize">
          {{ optimizing ? `${zh.optimizing} ${optimizeProgress}%` : zh.optimizeBtn }}
        </el-button>
        <el-button :disabled="!current || parsing || optimizing" @click="onDiff">{{ zh.diffBtn }}</el-button>
        <el-button :disabled="parsing || optimizing" @click="() => load()">{{ zh.refresh }}</el-button>
      </div>
    </div>

    <el-row :gutter="16">
      <el-col :span="8">
        <el-table :data="versions" v-loading="loading" highlight-current-row height="520" @current-change="onSelect">
          <el-table-column prop="versionNo" :label="zh.version" width="70" />
          <el-table-column prop="reviewStatus" :label="zh.review" width="110">
            <template #default="{ row }">
              <el-tag :type="statusType(row.reviewStatus)" size="small">{{ row.reviewStatus }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="source" :label="zh.source" min-width="110" show-overflow-tooltip />
        </el-table>
      </el-col>
      <el-col :span="16">
        <template v-if="current">
          <div class="detail-toolbar">
            <span>v{{ current.versionNo }} / {{ current.source }}</span>
            <div>
              <el-button size="small" @click="editMode = !editMode">{{ editMode ? zh.cancelEdit : zh.edit }}</el-button>
              <el-button size="small" type="success" :loading="reviewing" @click="onReview('pass')">{{ zh.pass }}</el-button>
              <el-button size="small" type="danger" :loading="reviewing" @click="onReview('reject')">{{ zh.reject }}</el-button>
            </div>
          </div>
          <el-input v-if="editMode" v-model="editContent" type="textarea" :rows="20" />
          <div v-else class="markdown-view">{{ current.content }}</div>
          <div v-if="editMode" class="save-row">
            <el-button type="primary" :loading="saving" @click="onSave">{{ zh.save }}</el-button>
          </div>
        </template>
        <el-empty v-else :description="zh.selectVersion" />
      </el-col>
    </el-row>

    <el-dialog v-model="diffVisible" :title="zh.diffTitle" width="80%" append-to-body>
      <div v-if="diffResult" class="diff-meta">
        v{{ diffResult.leftVersionNo }} vs v{{ diffResult.rightVersionNo }}
      </div>
      <div class="diff-box">
        <div
          v-for="(line, idx) in diffResult?.lines || []"
          :key="idx"
          class="diff-line"
          :class="line.type"
        >
          <span class="left">{{ line.left }}</span>
          <span class="right">{{ line.right }}</span>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  diffArchitecture,
  getArchitectureVersion,
  listArchitectureVersions,
  optimizeArchitecture,
  parseArchitecture,
  reviewArchitecture,
  updateArchitectureContent,
  type ArchitectureDiffResult,
  type ArchitectureVersion
} from '@/api/architecture'
import { waitForTask } from '@/composables/useTaskProgress'
import { zh } from '@/locales/zh'

const route = useRoute()
const projectId = route.params.projectId as string
const versions = ref<ArchitectureVersion[]>([])
const current = ref<ArchitectureVersion | null>(null)
const loading = ref(false)
const parsing = ref(false)
const optimizing = ref(false)
const reviewing = ref(false)
const saving = ref(false)
const editMode = ref(false)
const editContent = ref('')
const diffVisible = ref(false)
const diffResult = ref<ArchitectureDiffResult | null>(null)
const parseProgress = ref(0)
const optimizeProgress = ref(0)

function statusType(status?: string) {
  if (status === 'approved') return 'success'
  if (status === 'rejected') return 'danger'
  return 'info'
}

async function load(options?: { selectNewest?: boolean }) {
  loading.value = true
  try {
    const res = await listArchitectureVersions(projectId)
    versions.value = res.data || []
    if (!versions.value.length) {
      current.value = null
      return
    }
    if (options?.selectNewest) {
      await onSelect(versions.value[0])
      return
    }
    if (current.value?.versionId) {
      const still = versions.value.find((v) => v.versionId === current.value?.versionId)
      if (still) {
        await onSelect(still)
        return
      }
    }
    await onSelect(versions.value[0])
  } finally {
    loading.value = false
  }
}

async function onSelect(row: ArchitectureVersion | null) {
  if (!row?.versionId) {
    current.value = null
    return
  }
  const res = await getArchitectureVersion(row.versionId)
  current.value = res.data
  editContent.value = res.data.content || ''
  editMode.value = false
}

async function onParse() {
  await ElMessageBox.confirm(zh.parseConfirm, zh.parseTitle)
  parsing.value = true
  parseProgress.value = 0
  try {
    const res = await parseArchitecture(projectId)
    waitForTask(res.data, (p) => {
      parseProgress.value = p
    })
      .then(async () => {
        ElMessage.success(zh.genOk)
        await load({ selectNewest: true })
      })
      .catch((e: any) => {
        ElMessage.error(String(e?.message || e || zh.taskFailed))
      })
      .finally(() => {
        parsing.value = false
        parseProgress.value = 0
      })
  } catch (e: any) {
    parsing.value = false
    if (e !== 'cancel') {
      ElMessage.error(String(e?.message || e))
    }
  }
}

async function onOptimize() {
  if (!current.value?.versionId) return
  await ElMessageBox.confirm(zh.optimizeConfirm, zh.optimizeBtn)
  optimizing.value = true
  optimizeProgress.value = 0
  try {
    const res = await optimizeArchitecture(current.value.versionId)
    waitForTask(res.data, (p) => {
      optimizeProgress.value = p
    })
      .then(async () => {
        ElMessage.success(zh.genOk)
        await load({ selectNewest: true })
      })
      .catch((e: any) => {
        ElMessage.error(String(e?.message || e || zh.taskFailed))
      })
      .finally(() => {
        optimizing.value = false
        optimizeProgress.value = 0
      })
  } catch (e: any) {
    optimizing.value = false
    if (e !== 'cancel') {
      ElMessage.error(String(e?.message || e))
    }
  }
}

async function onDiff() {
  if (!current.value?.versionId) return
  const idx = versions.value.findIndex((v) => v.versionId === current.value?.versionId)
  const older = versions.value[idx + 1]
  if (!older?.versionId) {
    ElMessage.warning(zh.noVersions)
    return
  }
  const res = await diffArchitecture(current.value.versionId, older.versionId)
  diffResult.value = res.data
  diffVisible.value = true
}

async function onSave() {
  if (!current.value?.versionId) return
  saving.value = true
  try {
    const res = await updateArchitectureContent(current.value.versionId, editContent.value)
    current.value = res.data
    editMode.value = false
    ElMessage.success(zh.savedPending)
    await load()
  } finally {
    saving.value = false
  }
}

async function onReview(result: 'pass' | 'reject') {
  if (!current.value?.versionId) return
  let comment = ''
  if (result === 'reject') {
    const { value } = await ElMessageBox.prompt(zh.rejectComment, zh.reject, {
      confirmButtonText: zh.reject,
      cancelButtonText: zh.cancel,
      inputPlaceholder: zh.optional
    })
    comment = value || ''
  }
  reviewing.value = true
  try {
    const res = await reviewArchitecture(current.value.versionId, result, comment)
    current.value = res.data
    ElMessage.success(result === 'pass' ? zh.approved : zh.rejected)
    await load()
  } finally {
    reviewing.value = false
  }
}

onMounted(() => load())
</script>

<style scoped>
.toolbar { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
.actions { display: flex; flex-wrap: wrap; gap: 8px; }
.detail-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.save-row { margin-top: 12px; }
.diff-meta { margin-bottom: 12px; color: var(--ink-soft); }
.diff-box {
  max-height: 60vh;
  overflow: auto;
  font-family: var(--serif);
  border: 1px solid var(--line);
  background: rgba(255, 251, 240, 0.92);
}
.diff-line {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
  padding: 4px 8px;
  border-bottom: 1px solid rgba(43, 38, 32, 0.06);
  white-space: pre-wrap;
  font-size: 13px;
}
.diff-line.insert .right { background: rgba(46, 125, 50, 0.12); }
.diff-line.delete .left { background: rgba(168, 50, 45, 0.12); }
.diff-line.change .left,
.diff-line.change .right { background: rgba(184, 146, 90, 0.15); }
</style>
