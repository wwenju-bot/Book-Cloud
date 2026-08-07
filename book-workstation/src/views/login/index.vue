<template>
  <div class="login-page">
    <div class="grain"></div>
    <div class="seal">{{ seal }}</div>
    <div class="login-card">
      <div class="brush-line"></div>
      <h1>{{ zh.brand }}</h1>
      <p class="sub">{{ zh.subtitle }}</p>
      <el-form ref="formRef" :model="form" :rules="rules" label-position="top" @keyup.enter="onSubmit">
        <el-form-item :label="zh.account" prop="username">
          <el-input v-model="form.username" :placeholder="zh.needAccount" />
        </el-form-item>
        <el-form-item :label="zh.password" prop="password">
          <el-input v-model="form.password" type="password" show-password :placeholder="zh.needPassword" />
        </el-form-item>
        <el-form-item v-if="captchaEnabled" :label="zh.captcha" prop="code">
          <div class="captcha-row">
            <el-input v-model="form.code" :placeholder="zh.captcha" />
            <img
              v-if="captchaImg"
              class="captcha-img"
              :src="'data:image/jpg;base64,' + captchaImg"
              @click="refreshCaptcha"
              :alt="zh.captcha"
            />
            <el-button v-else link type="primary" @click="refreshCaptcha">{{ reloadLabel }}</el-button>
          </div>
        </el-form-item>
        <el-button type="primary" class="submit" :loading="loading" @click="onSubmit">{{ zh.login }}</el-button>
      </el-form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import type { FormInstance, FormRules } from 'element-plus'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { zh } from '@/locales/zh'
import { getToken } from '@/utils/auth'

const userStore = useUserStore()
const router = useRouter()
const route = useRoute()
const formRef = ref<FormInstance>()
const loading = ref(false)
const captchaEnabled = ref(true)
const captchaImg = ref('')
const seal = '\u58a8'
const reloadLabel = '\u70b9\u51fb\u5237\u65b0'
const form = reactive({
  username: 'admin',
  password: 'admin123',
  code: '',
  uuid: ''
})

const rules = computed<FormRules>(() => {
  const base: FormRules = {
    username: [{ required: true, message: zh.needAccount, trigger: 'blur' }],
    password: [{ required: true, message: zh.needPassword, trigger: 'blur' }]
  }
  if (captchaEnabled.value) {
    base.code = [{ required: true, message: zh.needCaptcha, trigger: 'blur' }]
  }
  return base
})

async function refreshCaptcha() {
  try {
    const res: any = await userStore.fetchCaptcha()
    const payload = res?.data && (res.data.img || res.data.uuid) ? res.data : res
    captchaEnabled.value = payload.captchaEnabled !== false
    captchaImg.value = payload.img || ''
    form.uuid = payload.uuid || ''
    form.code = ''
    if (captchaEnabled.value && !captchaImg.value) {
      ElMessage.warning('\u9a8c\u8bc1\u7801\u672a\u8fd4\u56de\u56fe\u7247\uff0c\u8bf7\u786e\u8ba4\u5df2\u91cd\u542f book-gateway')
    }
  } catch (e) {
    captchaImg.value = ''
    ElMessage.warning('\u9a8c\u8bc1\u7801\u670d\u52a1\u4e0d\u53ef\u7528\uff0c\u8bf7\u91cd\u542f book-gateway \u540e\u70b9\u51fb\u5237\u65b0')
  }
}

async function onSubmit() {
  await formRef.value?.validate()
  loading.value = true
  try {
    await userStore.login({
      username: form.username,
      password: form.password,
      code: form.code,
      uuid: form.uuid
    })
    ElMessage.success(zh.loginOk)
    const redirect = (route.query.redirect as string) || '/projects'
    router.replace(redirect)
  } catch (e) {
    await refreshCaptcha()
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  if (getToken()) {
    try {
      await userStore.fetchProfile()
      router.replace((route.query.redirect as string) || '/projects')
      return
    } catch {
      userStore.logout()
    }
  }
  refreshCaptcha()
})
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}
.grain {
  position: fixed;
  inset: 0;
  pointer-events: none;
  opacity: 0.45;
  mix-blend-mode: multiply;
  background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='120' height='120'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='2' stitchTiles='stitch'/><feColorMatrix type='matrix' values='0 0 0 0 0.16  0 0 0 0 0.14  0 0 0 0 0.11  0 0 0 0.05 0'/></filter><rect width='100%25' height='100%25' filter='url(%23n)'/></svg>");
}
.seal {
  position: fixed;
  top: 36px;
  right: 36px;
  width: 64px;
  height: 64px;
  background: linear-gradient(155deg, var(--seal), var(--seal-deep));
  color: #f5e9d6;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: var(--brush);
  font-size: 20px;
  border-radius: 6px;
  transform: rotate(-6deg);
  box-shadow: 0 6px 18px rgba(138, 38, 34, 0.35);
  z-index: 2;
}
.login-card {
  width: 400px;
  background: var(--card-bg);
  border: 1px solid var(--line);
  border-radius: 6px;
  padding: 36px 32px 28px;
  box-shadow: 0 16px 40px rgba(43, 38, 32, 0.1);
  position: relative;
  z-index: 1;
}
.brush-line {
  width: 140px;
  height: 10px;
  margin: 0 auto 18px;
  background: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 220 14'><path d='M4 8 C 40 2, 90 12, 130 6 S 200 2, 216 8' stroke='%23a8322d' stroke-width='3' fill='none' stroke-linecap='round'/></svg>")
    no-repeat center / contain;
}
h1 {
  margin: 0;
  font-size: 28px;
  text-align: center;
  letter-spacing: 0.12em;
  font-weight: 900;
}
.sub {
  margin: 10px 0 24px;
  text-align: center;
  color: var(--ink-soft);
  font-size: 13px;
  letter-spacing: 0.06em;
}
.captcha-row {
  display: flex;
  gap: 10px;
  width: 100%;
  align-items: center;
}
.captcha-img {
  height: 36px;
  border-radius: 4px;
  cursor: pointer;
  border: 1px solid var(--line);
}
.submit {
  width: 100%;
  margin-top: 8px;
  letter-spacing: 0.2em;
}
</style>
