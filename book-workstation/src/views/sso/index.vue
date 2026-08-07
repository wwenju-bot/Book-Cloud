<template>
  <div class="sso-page">
    <div class="seal">{{ seal }}</div>
    <p>{{ tip }}</p>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { applySsoToken, getToken } from '@/utils/auth'
import { useUserStore } from '@/stores/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const seal = '\u58a8'
const tip = ref('\u6b63\u5728\u8fdb\u5165\u521b\u4f5c\u5de5\u4f5c\u53f0\u2026')

onMounted(async () => {
  const token = typeof route.query.token === 'string' ? route.query.token : ''
  if (token) {
    applySsoToken(token)
    userStore.token = getToken()
  }
  if (!getToken()) {
    tip.value = '\u672a\u767b\u5f55\uff0c\u524d\u5f80\u767b\u5f55\u9875'
    router.replace('/login')
    return
  }
  try {
    userStore.token = getToken()
    await userStore.fetchProfile()
    tip.value = '\u6b22\u8fce\uff0c' + userStore.displayName
    router.replace('/projects')
  } catch (e) {
    tip.value = '\u767b\u5f55\u6001\u5df2\u5931\u6548\uff0c\u8bf7\u91cd\u65b0\u767b\u5f55'
    userStore.logout()
    router.replace('/login')
  }
})
</script>

<style scoped>
.sso-page {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 16px;
  color: var(--ink-soft);
  font-family: var(--serif);
}
.seal {
  width: 56px;
  height: 56px;
  background: linear-gradient(155deg, var(--seal), var(--seal-deep));
  color: #f5e9d6;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: var(--brush);
  font-size: 22px;
  border-radius: 6px;
  transform: rotate(-6deg);
}
</style>
