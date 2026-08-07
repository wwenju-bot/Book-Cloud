<template>
  <div class="page-card" v-if="project">
    <h2 class="page-title">{{ project.projectName }}</h2>
    <el-descriptions :column="2" border>
      <el-descriptions-item :label="zh.projectId">{{ project.projectId }}</el-descriptions-item>
      <el-descriptions-item :label="zh.status">{{ project.status }}</el-descriptions-item>
      <el-descriptions-item :label="zh.sourceType">{{ project.sourceType }}</el-descriptions-item>
      <el-descriptions-item :label="zh.createTime">{{ project.createTime || '-' }}</el-descriptions-item>
      <el-descriptions-item :label="zh.kbPath" :span="2">{{ project.kbRootPath || '-' }}</el-descriptions-item>
      <el-descriptions-item :label="zh.remark" :span="2">{{ project.remark || '-' }}</el-descriptions-item>
    </el-descriptions>

    <div class="steps">
      <h3>{{ zh.flowTitle }}</h3>
      <el-steps :active="1" align-center>
        <el-step :title="zh.stepUpload" :description="zh.stepUploadDesc" />
        <el-step :title="zh.stepParse" :description="zh.stepParseDesc" />
        <el-step :title="zh.stepReview" :description="zh.stepReviewDesc" />
        <el-step :title="zh.stepChapter" :description="zh.stepChapterDesc" />
        <el-step :title="zh.stepExport" :description="zh.stepExportDesc" />
      </el-steps>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useProjectStore } from '@/stores/project'
import { zh } from '@/locales/zh'

const projectStore = useProjectStore()
const project = computed(() => projectStore.current)
</script>

<style scoped>
.steps { margin-top: 28px; }
.steps h3 { margin: 0 0 16px; font-size: 15px; }
</style>
