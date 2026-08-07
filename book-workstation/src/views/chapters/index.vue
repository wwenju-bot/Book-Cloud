<template>
  <div class="page-card">
    <div class="toolbar">
      <h2 class="page-title">{{ zh.chapters }}</h2>
      <el-button type="primary" :loading="generating" @click="dialogVisible = true">
        {{ generating ? `${zh.generating} ${genProgress}%` : zh.genChapter }}
      </el-button>
    </div>
    <el-alert :title="zh.chapterTip" type="info" :closable="false" show-icon class="mb" />

    <el-table :data="chapters" v-loading="loading" stripe>
      <el-table-column prop="chapterNo" :label="zh.chapterNo" width="80" />
      <el-table-column prop="title" :label="zh.chapterTitle" min-width="160" />
      <el-table-column prop="status" :label="zh.status" width="140">
        <template #default="{ row }">
          <el-tag :type="chapterStatusType(row.status)" size="small">{{ row.status }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="latestVersionId" label="latestVersionId" width="130" />
      <el-table-column :label="zh.edit" width="140">
        <template #default="{ row }">
          <el-button link type="primary" @click="openVersions(row)">{{ zh.viewVersions }}</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dialogVisible" :title="zh.genChapter" width="520px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item :label="zh.chapterNo" prop="chapterNo">
          <el-input-number v-model="form.chapterNo" :min="1" />
        </el-form-item>
        <el-form-item :label="zh.chapterTitle" prop="chapterTitle">
          <el-input v-model="form.chapterTitle" />
        </el-form-item>
        <el-form-item :label="zh.extra">
          <el-input v-model="form.extraInstruction" type="textarea" :rows="3" :placeholder="zh.optional" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">{{ zh.cancel }}</el-button>
        <el-button type="primary" :loading="generating" @click="onGenerate">{{ zh.startGen }}</el-button>
      </template>
    </el-dialog>

    <el-drawer v-model="drawerVisible" :title="zh.chapterVersions" size="70%">
      <div class="drawer-toolbar" v-if="versions.length">
        <el-button size="small" @click="openCompare">{{ zh.compareCandidates }}</el-button>
      </div>
      <el-timeline v-if="versions.length">
        <el-timeline-item
          v-for="v in versions"
          :key="v.versionId"
          :timestamp="versionStamp(v)"
        >
          <div class="version-actions">
            <el-tag size="small" type="warning" v-if="v.score != null">{{ zh.scoreLabel }} {{ v.score }}</el-tag>
            <el-tag size="small" v-if="v.optimizeRound != null">{{ zh.roundLabel }} {{ v.optimizeRound }}</el-tag>
            <el-button
              v-if="v.reviewStatus === 'pending'"
              size="small"
              @click="onPromote(v)"
              :loading="promotingId === v.versionId"
            >
              {{ zh.promoteBtn }}
            </el-button>
            <el-button
              v-if="v.reviewStatus === 'pending'"
              size="small"
              type="success"
              :loading="reviewingId === v.versionId"
              @click="onReview(v, 'pass')"
            >
              {{ zh.pass }}
            </el-button>
            <el-button
              v-if="v.reviewStatus === 'pending'"
              size="small"
              type="danger"
              :loading="reviewingId === v.versionId"
              @click="onReview(v, 'reject')"
            >
              {{ zh.reject }}
            </el-button>
          </div>
          <div class="markdown-view">{{ v.content }}</div>
        </el-timeline-item>
      </el-timeline>
      <el-empty v-else :description="zh.noVersions" />
    </el-drawer>

    <el-dialog
      v-model="compareVisible"
      :title="zh.compareCandidates"
      width="90%"
      top="4vh"
      append-to-body
      class="compare-dialog"
      destroy-on-close
    >
      <div class="compare-grid" v-if="latestRound.length">
        <div class="compare-col" v-for="v in latestRound" :key="v.versionId">
          <div class="compare-head">
            <strong>{{ v.modelSource }}</strong>
            <span>{{ zh.scoreLabel }} {{ v.score ?? '-' }}</span>
            <el-button size="small" type="primary" @click="onPromote(v)">{{ zh.promoteBtn }}</el-button>
          </div>
          <div class="compare-body markdown-view">{{ v.content }}</div>
        </div>
      </div>
      <el-empty v-else :description="zh.noVersions" />
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute } from 'vue-router'
import type { FormInstance, FormRules } from 'element-plus'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  generateChapter,
  listChapterVersions,
  listChapters,
  promoteChapterVersion,
  reviewChapterVersion,
  type NovelChapter,
  type NovelChapterVersion
} from '@/api/chapter'
import { zh } from '@/locales/zh'
import { waitForTask } from '@/composables/useTaskProgress'

const route = useRoute()
const projectId = route.params.projectId as string
const chapters = ref<NovelChapter[]>([])
const versions = ref<NovelChapterVersion[]>([])
const activeChapterId = ref<number | null>(null)
const loading = ref(false)
const generating = ref(false)
const genProgress = ref(0)
const reviewingId = ref<number | null>(null)
const promotingId = ref<number | null>(null)
const dialogVisible = ref(false)
const drawerVisible = ref(false)
const compareVisible = ref(false)
const formRef = ref<FormInstance>()
const form = reactive({
  chapterNo: 1,
  chapterTitle: '\u7b2c\u4e00\u7ae0',
  extraInstruction: ''
})
const rules: FormRules = {
  chapterNo: [{ required: true, message: zh.chapterNo, trigger: 'change' }],
  chapterTitle: [{ required: true, message: zh.chapterTitle, trigger: 'blur' }]
}

const latestRound = computed(() => {
  if (!versions.value.length) return []
  const maxRound = Math.max(...versions.value.map((v) => v.optimizeRound ?? 0))
  return versions.value
    .filter((v) => (v.optimizeRound ?? 0) === maxRound)
    .sort((a, b) => (b.score ?? 0) - (a.score ?? 0))
})

function chapterStatusType(status?: string) {
  if (status === 'approved' || status === 'published') return 'success'
  if (status === 'rejected') return 'danger'
  if (status === 'generating') return 'warning'
  return 'info'
}

function versionStamp(v: NovelChapterVersion) {
  return `v${v.versionNo} / ${v.modelSource} / ${v.reviewStatus} / ${zh.scoreLabel}:${v.score ?? '-'}`
}

async function load() {
  loading.value = true
  try {
    const res = await listChapters(projectId)
    chapters.value = res.data || []
  } finally {
    loading.value = false
  }
}

async function onGenerate() {
  await formRef.value?.validate()
  generating.value = true
  genProgress.value = 0
  try {
    const res = await generateChapter(projectId, { ...form })
    dialogVisible.value = false
    waitForTask(res.data, (p) => {
      genProgress.value = p
    })
      .then(async () => {
        ElMessage.success(zh.genOk)
        await load()
      })
      .catch((e: any) => {
        ElMessage.error(String(e?.message || e || zh.taskFailed))
      })
      .finally(() => {
        generating.value = false
        genProgress.value = 0
      })
  } catch (e: any) {
    generating.value = false
    ElMessage.error(String(e?.message || e))
  }
}

async function openVersions(row: NovelChapter) {
  activeChapterId.value = row.chapterId || null
  const res = await listChapterVersions(row.chapterId!)
  versions.value = res.data || []
  drawerVisible.value = true
}

function openCompare() {
  compareVisible.value = true
}

async function onPromote(v: NovelChapterVersion) {
  if (!v.versionId) return
  promotingId.value = v.versionId
  try {
    await promoteChapterVersion(v.versionId)
    ElMessage.success(zh.promoted)
    if (activeChapterId.value) {
      const res = await listChapterVersions(activeChapterId.value)
      versions.value = res.data || []
    }
    await load()
  } finally {
    promotingId.value = null
  }
}

async function onReview(v: NovelChapterVersion, result: 'pass' | 'reject') {
  if (!v.versionId) return
  let comment = ''
  if (result === 'reject') {
    const { value } = await ElMessageBox.prompt(zh.rejectComment, zh.reject, {
      confirmButtonText: zh.reject,
      cancelButtonText: zh.cancel,
      inputPlaceholder: zh.optional
    })
    comment = value || ''
  }
  reviewingId.value = v.versionId
  try {
    await reviewChapterVersion(v.versionId, result, comment)
    ElMessage.success(result === 'pass' ? zh.approved : zh.rejected)
    if (activeChapterId.value) {
      const res = await listChapterVersions(activeChapterId.value)
      versions.value = res.data || []
    }
    await load()
  } finally {
    reviewingId.value = null
  }
}

onMounted(load)
</script>

<style scoped>
.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-shrink: 0;
}
.mb {
  margin-bottom: 16px;
  flex-shrink: 0;
}
:deep(.el-table) {
  flex: 1;
}
:deep(.el-dialog__footer) {
  padding-bottom: 16px;
}
.drawer-toolbar {
  margin-bottom: 12px;
}
.version-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 10px;
  align-items: center;
}
.compare-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 12px;
  max-height: 75vh;
}
.compare-col {
  border: 1px solid var(--line);
  border-radius: 4px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  min-height: 0;
  background: var(--card-bg);
}
.compare-head {
  display: flex;
  gap: 10px;
  align-items: center;
  padding: 10px 12px;
  background: rgba(236, 226, 201, 0.9);
  border-bottom: 1px solid var(--line);
  color: var(--ink);
}
.compare-body {
  margin: 0;
  max-height: none;
  flex: 1;
  min-height: 320px;
  border: none;
  border-radius: 0;
}
</style>

<style>
/* dialog teleported to body; need unscoped styles */
.compare-dialog .el-dialog {
  background: var(--card-bg, rgba(255, 251, 240, 0.96));
  border: 1px solid var(--line, rgba(43, 38, 32, 0.14));
}
.compare-dialog .el-dialog__body {
  background: rgba(243, 236, 219, 0.55);
  padding: 16px 18px 20px;
}
.compare-dialog .el-dialog__header {
  background: rgba(255, 251, 240, 0.95);
  margin-right: 0;
  border-bottom: 1px solid var(--line, rgba(43, 38, 32, 0.14));
}
</style>
