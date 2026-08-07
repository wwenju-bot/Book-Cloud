# 创作工作台（book-workstation）

面向写手的独立前端，与 `book-ui`（管理端 Vue2）分离。技术栈：Vue3 + Vite + Pinia + Vue Router + Element Plus。

## 启动

前置：网关 `8089`、`book-auth`、`book-novel`、`book-ai`、Nacos、Redis、MySQL 已启动。

```bash
cd Book-Cloud/book-workstation
npm install
npm run dev
```

浏览器打开：http://localhost:5173

默认可用管理端账号登录（如 `admin` / `admin123`），需填写网关数学验证码。

## 能力（阶段1对接）

- 项目 CRUD
- 参考资料上传
- 架构解析 / 编辑 / 审核
- 章节生成与版本查看
- 知识库 zip 导出

左侧菜单为前端写死，不走后台动态权限。

## 与 book-ui 入口

菜单「小说自动化创作平台」外链指向本工作台（开发环境 `http://localhost:5173`）。
补丁脚本：`Book-Cloud/sql/book_workstation_menu_20260806.sql`。

## 登录与免登

- 若依菜单→官网→「进入创作工作台」：携带 book-ui 的 Admin-Token 跳转 /sso?token=，免登录。
- 直接打开 http://localhost:5173 ：跳转登录页（需验证码；请确保已重启修复后的 book-gateway）。
