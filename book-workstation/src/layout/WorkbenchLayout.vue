<template>
  <div class="workbench">
    <aside class="sidebar">
      <div class="brand" @click="goProjects">
        <span class="brand-seal">{{ seal }}</span>
        <span>{{ zh.brand }}</span>
      </div>
      <div class="project-name" v-if="projectStore.current">
        {{ projectStore.current.projectName }}
      </div>
      <el-menu
        :default-active="activeMenu"
        background-color="transparent"
        text-color="#f3ecdb"
        active-text-color="#f5e9d6"
        @select="onSelect"
      >
        <el-menu-item index="overview">
          <el-icon><House /></el-icon>
          <span>{{ zh.overview }}</span>
        </el-menu-item>
        <el-menu-item index="materials">
          <el-icon><FolderOpened /></el-icon>
          <span>{{ zh.materials }}</span>
        </el-menu-item>
        <el-menu-item index="architecture">
          <el-icon><Document /></el-icon>
          <span>{{ zh.architecture }}</span>
        </el-menu-item>
        <el-menu-item index="chapters">
          <el-icon><EditPen /></el-icon>
          <span>{{ zh.chapters }}</span>
        </el-menu-item>
        <el-menu-item index="export">
          <el-icon><Download /></el-icon>
          <span>{{ zh.export }}</span>
        </el-menu-item>
      </el-menu>
      <div class="sidebar-footer">
        <el-button text style="color: #d8b784" @click="goProjects">{{ zh.backProjects }}</el-button>
      </div>
    </aside>
    <section class="main">
      <header class="topbar">
        <div class="topbar-title">{{ pageTitle }}</div>
        <div class="topbar-actions">
          <span class="user">{{ userStore.displayName }}</span>
          <el-button size="small" @click="onLogout">{{ zh.logout }}</el-button>
        </div>
      </header>
      <main class="content" v-loading="loading">
        <router-view v-if="!loading" />
      </main>
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useProjectStore } from '@/stores/project'
import { zh } from '@/locales/zh'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const projectStore = useProjectStore()
const loading = ref(false)
const seal = '\u58a8'

const menuTitleMap: Record<string, string> = {
  overview: zh.overview,
  materials: zh.materials,
  architecture: zh.architecture,
  chapters: zh.chapters,
  export: zh.export
}

const activeMenu = computed(() => (route.meta.menu as string) || 'overview')
const pageTitle = computed(() => menuTitleMap[activeMenu.value] || zh.brand)
const projectId = computed(() => route.params.projectId as string)

async function load() {
  if (!projectId.value) return
  loading.value = true
  try {
    await projectStore.loadProject(projectId.value)
  } finally {
    loading.value = false
  }
}

watch(projectId, load, { immediate: true })

onMounted(async () => {
  if (!userStore.nickName) {
    try {
      await userStore.fetchProfile()
    } catch {
      /* ignore */
    }
  }
})

function onSelect(index: string) {
  const id = projectId.value
  if (index === 'overview') {
    router.push(`/p/${id}`)
  } else {
    router.push(`/p/${id}/${index}`)
  }
}

function goProjects() {
  projectStore.clear()
  router.push('/projects')
}

function onLogout() {
  userStore.logout()
  router.push('/login')
}
</script>

<style scoped>
.workbench {
  display: flex;
  height: 100vh;
}
.sidebar {
  width: 228px;
  background: linear-gradient(180deg, #2b2620 0%, #1c1814 100%);
  color: var(--ws-sidebar-text);
  display: flex;
  flex-direction: column;
  border-right: 1px solid rgba(184, 146, 90, 0.25);
}
.brand {
  padding: 20px 16px 10px;
  font-size: 17px;
  font-weight: 700;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 10px;
  letter-spacing: 0.08em;
}
.brand-seal {
  width: 28px;
  height: 28px;
  border-radius: 4px;
  background: linear-gradient(155deg, var(--seal), var(--seal-deep));
  color: #f5e9d6;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-family: var(--brush);
  font-size: 14px;
}
.project-name {
  padding: 0 16px 14px;
  font-size: 12px;
  opacity: 0.7;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.sidebar :deep(.el-menu) {
  border-right: none;
  flex: 1;
  background: transparent;
}
.sidebar :deep(.el-menu-item.is-active) {
  background: rgba(168, 50, 45, 0.35) !important;
  border-right: 2px solid var(--gold-soft);
}
.sidebar-footer {
  padding: 12px 16px 20px;
}
.main {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
}
.topbar {
  height: 58px;
  background: var(--ws-header);
  border-bottom: 1px solid var(--line);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 22px;
  backdrop-filter: blur(6px);
}
.topbar-title {
  font-size: 16px;
  font-weight: 700;
  letter-spacing: 0.1em;
}
.topbar-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}
.user {
  color: var(--ink-soft);
  font-size: 13px;
  max-width: 280px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.content {
  flex: 1;
  min-height: 0;
  overflow: auto;
  padding: 22px;
  display: flex;
  flex-direction: column;
}
.content > .page-card {
  flex: 1;
}
</style>
