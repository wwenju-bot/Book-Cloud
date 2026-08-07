<template>
  <div class="projects-page">
    <header class="bar">
      <div class="left">
        <strong>{{ t.brand }}</strong>
        <span class="sep">/</span>
        <span>{{ t.myProjects }}</span>
      </div>
      <div class="right">
        <span class="user">{{ userStore.displayName }}</span>
        <el-button size="small" @click="onLogout">{{ t.logout }}</el-button>
      </div>
    </header>

    <div class="page-card">
      <div class="toolbar">
        <h2 class="page-title">{{ t.listTitle }}</h2>
        <el-button type="primary" @click="openCreate">{{ t.create }}</el-button>
      </div>

      <el-table :data="list" v-loading="loading" stripe>
        <el-table-column prop="projectId" :label="t.colId" width="80" />
        <el-table-column prop="projectName" :label="t.colName" min-width="180" />
        <el-table-column prop="sourceType" :label="t.colSource" width="120" />
        <el-table-column prop="status" :label="t.colStatus" width="120" />
        <el-table-column prop="createTime" :label="t.colTime" width="180" />
        <el-table-column :label="t.colActions" width="220" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="enter(row)">{{ t.enter }}</el-button>
            <el-button link type="primary" @click="openEdit(row)">{{ t.edit }}</el-button>
            <el-button link type="danger" @click="onDelete(row)">{{ t.remove }}</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <el-dialog v-model="dialogVisible" :title="editing ? t.editTitle : t.createTitle" width="480px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item :label="t.colName" prop="projectName">
          <el-input v-model="form.projectName" maxlength="100" />
        </el-form-item>
        <el-form-item :label="t.colSource" prop="sourceType">
          <el-select v-model="form.sourceType" style="width: 100%">
            <el-option :label="t.sourceInspiration" value="inspiration" />
            <el-option :label="t.sourceUpload" value="upload" />
          </el-select>
        </el-form-item>
        <el-form-item :label="t.remark">
          <el-input v-model="form.remark" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">{{ t.cancel }}</el-button>
        <el-button type="primary" :loading="saving" @click="onSave">{{ t.save }}</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import type { FormInstance, FormRules } from 'element-plus'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { addProject, delProject, listProject, updateProject, type NovelProject } from '@/api/project'

const t = {
  brand: '\u521b\u4f5c\u5de5\u4f5c\u53f0',
  myProjects: '\u6211\u7684\u9879\u76ee',
  logout: '\u9000\u51fa',
  listTitle: '\u9879\u76ee\u5217\u8868',
  create: '\u65b0\u5efa\u9879\u76ee',
  colId: 'ID',
  colName: '\u9879\u76ee\u540d\u79f0',
  colSource: '\u6765\u6e90',
  colStatus: '\u72b6\u6001',
  colTime: '\u521b\u5efa\u65f6\u95f4',
  colActions: '\u64cd\u4f5c',
  enter: '\u8fdb\u5165',
  edit: '\u7f16\u8f91',
  remove: '\u5220\u9664',
  editTitle: '\u7f16\u8f91\u9879\u76ee',
  createTitle: '\u65b0\u5efa\u9879\u76ee',
  sourceInspiration: '\u7075\u611f\u8f93\u5165',
  sourceUpload: '\u4e0a\u4f20\u624b\u7a3f',
  remark: '\u5907\u6ce8',
  cancel: '\u53d6\u6d88',
  save: '\u4fdd\u5b58',
  updated: '\u5df2\u66f4\u65b0',
  created: '\u5df2\u521b\u5efa',
  deleted: '\u5df2\u5220\u9664',
  tip: '\u63d0\u793a',
  confirmDelete: '\u786e\u8ba4\u5220\u9664\u9879\u76ee'
}

const router = useRouter()
const userStore = useUserStore()
const list = ref<NovelProject[]>([])
const loading = ref(false)
const dialogVisible = ref(false)
const editing = ref(false)
const saving = ref(false)
const formRef = ref<FormInstance>()
const form = reactive<NovelProject>({
  projectId: undefined,
  projectName: '',
  sourceType: 'inspiration',
  remark: ''
})
const rules: FormRules = {
  projectName: [{ required: true, message: '\u8bf7\u8f93\u5165\u9879\u76ee\u540d\u79f0', trigger: 'blur' }]
}

async function load() {
  loading.value = true
  try {
    const res = await listProject()
    list.value = (res.rows as NovelProject[]) || (res.data as any) || []
  } finally {
    loading.value = false
  }
}

function openCreate() {
  editing.value = false
  form.projectId = undefined
  form.projectName = ''
  form.sourceType = 'inspiration'
  form.remark = ''
  dialogVisible.value = true
}

function openEdit(row: NovelProject) {
  editing.value = true
  form.projectId = row.projectId
  form.projectName = row.projectName
  form.sourceType = row.sourceType || 'inspiration'
  form.remark = row.remark || ''
  dialogVisible.value = true
}

async function onSave() {
  await formRef.value?.validate()
  saving.value = true
  try {
    if (editing.value) {
      await updateProject({ ...form })
      ElMessage.success(t.updated)
    } else {
      await addProject({ ...form })
      ElMessage.success(t.created)
    }
    dialogVisible.value = false
    await load()
  } finally {
    saving.value = false
  }
}

async function onDelete(row: NovelProject) {
  await ElMessageBox.confirm(`${t.confirmDelete}\u300c${row.projectName}\u300d\uff1f`, t.tip, { type: 'warning' })
  await delProject(row.projectId!)
  ElMessage.success(t.deleted)
  await load()
}

function enter(row: NovelProject) {
  router.push(`/p/${row.projectId}`)
}

function onLogout() {
  userStore.logout()
  router.push('/login')
}

onMounted(async () => {
  try {
    if (!userStore.nickName) {
      await userStore.fetchProfile()
    }
  } catch {
    /* keep page usable */
  }
  await load()
})
</script>

<style scoped>
.projects-page { min-height: 100vh; }
.bar {
  height: 58px;
  background: rgba(255, 251, 240, 0.92);
  border-bottom: 1px solid var(--line);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 22px;
  backdrop-filter: blur(6px);
}
.left {
  display: flex;
  align-items: center;
  gap: 8px;
  letter-spacing: 0.06em;
  font-weight: 600;
}
.sep { color: var(--gold); }
.right { display: flex; align-items: center; gap: 12px; }
.user {
  color: var(--ink-soft);
  font-size: 13px;
  max-width: 280px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.page-card { margin: 22px; }
.toolbar { display: flex; align-items: center; justify-content: space-between; }
</style>