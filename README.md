<p align="center">
	<img alt="logo" src="https://oscimg.oschina.net/oscnet/up-b99b286755aef70355a7084753f89cdb7c9.png">
</p>
<h1 align="center" style="margin: 30px 0 30px; font-weight: bold;">Book-Cloud</h1>
<h4 align="center">小说自动化创作平台微服务基座 —— 基于 RuoYi-Cloud 二次开发，Vue/Element UI + Spring Boot 3/Spring Cloud & Alibaba 前后端分离微服务架构</h4>

## 平台简介

Book-Cloud 是「小说自动化创作平台」的微服务基座，在开源脚手架 RuoYi-Cloud 的基础上二次开发而来：直接复用其账号权限、网关、文件、定时任务等成熟能力，在此之上新增面向小说创作业务的 `book-novel`（创作业务）与 `book-ai`（AI 编排）等模块。产品需求背景与技术路线详见仓库根目录的 [AGENTS.md](../AGENTS.md)。

* 后端采用 Spring Boot 3、Spring Cloud & Alibaba。
* 注册中心、配置中心选型 Nacos，权限认证使用 Redis。
* 流量控制框架选型 Sentinel，分布式事务选型 Seata。
* 前端管理端沿用 Vue 2 + Element UI；面向写手用户的创作工作台规划采用 Vue 3（见 AGENTS.md 技术路线）。

## 系统模块

~~~
com.book     
├── book-ui              // 前端框架 [80]
├── book-gateway         // 网关模块 [8080]
├── book-auth            // 认证中心 [9200]
├── book-api             // 接口模块
│       └── book-api-system                          // 系统接口
├── book-common          // 通用模块
│       └── book-common-core                         // 核心模块
│       └── book-common-datascope                    // 权限范围
│       └── book-common-datasource                   // 多数据源
│       └── book-common-log                          // 日志记录
│       └── book-common-redis                        // 缓存服务
│       └── book-common-seata                        // 分布式事务
│       └── book-common-security                     // 安全模块
│       └── book-common-sensitive                    // 数据脱敏
│       └── book-common-swagger                      // 系统接口
├── book-modules         // 业务模块
│       └── book-system                              // 系统模块 [9201]
│       └── book-gen                                 // 代码生成 [9202]
│       └── book-job                                 // 定时任务 [9203]
│       └── book-file                                // 文件服务 [9300]
├── book-visual          // 图形化管理模块
│       └── book-visual-monitor                      // 监控中心 [9100]
├──pom.xml                // 公共依赖
~~~

## 架构图

<img src="https://oscimg.oschina.net/oscnet/up-82e9722ecb846786405a904bafcf19f73f3.png"/>

## 内置功能

1.  用户管理：用户是系统操作者，该功能主要完成系统用户配置。
2.  部门管理：配置系统组织机构（公司、部门、小组），树结构展现支持数据权限。
3.  岗位管理：配置系统用户所属担任职务。
4.  菜单管理：配置系统菜单，操作权限，按钮权限标识等。
5.  角色管理：角色菜单权限分配、设置角色按机构进行数据范围权限划分。
6.  字典管理：对系统中经常使用的一些较为固定的数据进行维护。
7.  参数管理：对系统动态配置常用参数。
8.  通知公告：系统通知公告信息发布维护。
9.  操作日志：系统正常操作日志记录和查询；系统异常信息日志记录和查询。
10. 登录日志：系统登录日志记录查询包含登录异常。
11. 在线用户：当前系统中活跃用户状态监控。
12. 定时任务：在线（添加、修改、删除)任务调度包含执行结果日志。
13. 代码生成：前后端代码的生成（java、html、xml、sql）支持CRUD下载 。
14. 系统接口：根据业务代码自动生成相关的api接口文档。
15. 服务监控：监视当前系统CPU、内存、磁盘、堆栈等相关信息。
16. 在线构建器：拖动表单元素生成相应的HTML代码。
17. 连接池监视：监视当前系统数据库连接池状态，可进行分析SQL找出系统性能瓶颈。

## 本地默认账号

- 管理后台默认账号：admin/admin123（首次部署后请及时修改）

## 界面截图

<table>
    <tr>
        <td><img src="https://oscimg.oschina.net/oscnet/cd1f90be5f2684f4560c9519c0f2a232ee8.jpg"/></td>
        <td><img src="https://oscimg.oschina.net/oscnet/1cbcf0e6f257c7d3a063c0e3f2ff989e4b3.jpg"/></td>
    </tr>
    <tr>
        <td><img src="https://oscimg.oschina.net/oscnet/up-8074972883b5ba0622e13246738ebba237a.png"/></td>
        <td><img src="https://oscimg.oschina.net/oscnet/up-9f88719cdfca9af2e58b352a20e23d43b12.png"/></td>
    </tr>
    <tr>
        <td><img src="https://oscimg.oschina.net/oscnet/up-39bf2584ec3a529b0d5a3b70d15c9b37646.png"/></td>
        <td><img src="https://oscimg.oschina.net/oscnet/up-4148b24f58660a9dc347761e4cf6162f28f.png"/></td>
    </tr>
	<tr>
        <td><img src="https://oscimg.oschina.net/oscnet/up-b2d62ceb95d2dd9b3fbe157bb70d26001e9.png"/></td>
        <td><img src="https://oscimg.oschina.net/oscnet/up-d67451d308b7a79ad6819723396f7c3d77a.png"/></td>
    </tr>	 
    <tr>
        <td><img src="https://oscimg.oschina.net/oscnet/5e8c387724954459291aafd5eb52b456f53.jpg"/></td>
        <td><img src="https://oscimg.oschina.net/oscnet/644e78da53c2e92a95dfda4f76e6d117c4b.jpg"/></td>
    </tr>
	<tr>
        <td><img src="https://oscimg.oschina.net/oscnet/up-8370a0d02977eebf6dbf854c8450293c937.png"/></td>
        <td><img src="https://oscimg.oschina.net/oscnet/up-49003ed83f60f633e7153609a53a2b644f7.png"/></td>
    </tr>
	<tr>
        <td><img src="https://oscimg.oschina.net/oscnet/up-d4fe726319ece268d4746602c39cffc0621.png"/></td>
        <td><img src="https://oscimg.oschina.net/oscnet/up-c195234bbcd30be6927f037a6755e6ab69c.png"/></td>
    </tr>
	<tr>
        <td><img src="https://oscimg.oschina.net/oscnet/up-ece3fd37a3d4bb75a3926e905a3c5629055.png"/></td>
        <td><img src="https://oscimg.oschina.net/oscnet/up-92ffb7f3835855cff100fa0f754a6be0d99.png"/></td>
    </tr>
    <tr>
        <td><img src="https://oscimg.oschina.net/oscnet/up-ff9e3066561574aca73005c5730c6a41f15.png"/></td>
        <td><img src="https://oscimg.oschina.net/oscnet/up-5e4daac0bb59612c5038448acbcef235e3a.png"/></td>
    </tr>
</table>


## 致谢

本项目基于开源脚手架 [RuoYi-Cloud](https://gitee.com/y_project/RuoYi-Cloud) 二次开发，感谢原作者及社区贡献者。