import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { applySsoToken, getToken } from '@/utils/auth'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/login/index.vue'),
    meta: { public: true, title: 'Login' }
  },
  {
    path: '/sso',
    name: 'Sso',
    component: () => import('@/views/sso/index.vue'),
    meta: { public: true, title: 'SSO' }
  },
  {
    path: '/',
    redirect: '/projects'
  },
  {
    path: '/projects',
    name: 'Projects',
    component: () => import('@/views/projects/index.vue'),
    meta: { title: 'Projects', layout: 'simple' }
  },
  {
    path: '/p/:projectId',
    component: () => import('@/layout/WorkbenchLayout.vue'),
    meta: { requiresProject: true },
    children: [
      {
        path: '',
        name: 'Overview',
        component: () => import('@/views/overview/index.vue'),
        meta: { title: 'Overview', menu: 'overview' }
      },
      {
        path: 'materials',
        name: 'Materials',
        component: () => import('@/views/materials/index.vue'),
        meta: { title: 'Materials', menu: 'materials' }
      },
      {
        path: 'architecture',
        name: 'Architecture',
        component: () => import('@/views/architecture/index.vue'),
        meta: { title: 'Architecture', menu: 'architecture' }
      },
      {
        path: 'chapters',
        name: 'Chapters',
        component: () => import('@/views/chapters/index.vue'),
        meta: { title: 'Chapters', menu: 'chapters' }
      },
      {
        path: 'export',
        name: 'Export',
        component: () => import('@/views/export/index.vue'),
        meta: { title: 'Export', menu: 'export' }
      }
    ]
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/projects'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, _from, next) => {
  const title = (to.meta.title as string) || 'Workstation'
  document.title = `${title} | Book Workstation`

  // Support ?token= on any entry URL (landing page SSO)
  const qToken = typeof to.query.token === 'string' ? to.query.token : ''
  if (qToken && applySsoToken(qToken)) {
    const query = { ...to.query }
    delete query.token
    next({ path: to.path === '/login' || to.path === '/sso' ? '/sso' : to.path, query, replace: true })
    return
  }

  if (to.meta.public) {
    next()
    return
  }
  if (!getToken()) {
    next({ path: '/login', query: { redirect: to.fullPath } })
    return
  }
  next()
})

export default router
