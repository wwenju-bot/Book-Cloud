SET NAMES utf8mb4;

-- ----------------------------
-- 说明：以下表均落在业务主库中（不新建独立库，本地开发库名 book_db），供 book-novel / book-ai 两个新服务使用。
-- 表结构设计详见 AGENTS.md "数据模型设计" 一节，本脚本只是落地建表语句。
-- ----------------------------

-- ----------------------------
-- 1、创作项目表
-- ----------------------------
drop table if exists novel_project;
create table novel_project (
  project_id        bigint(20)      not null auto_increment    comment '项目ID',
  user_id           bigint(20)      not null                   comment '归属用户ID（关联 sys_user.user_id）',
  project_name      varchar(100)    not null                   comment '项目名称',
  source_type       varchar(20)     default 'inspiration'      comment '来源类型（upload=上传手稿 inspiration=灵感输入）',
  status            varchar(20)     default 'draft'            comment '项目状态（draft=草稿 in_progress=进行中 completed=已完成 archived=已归档）',
  kb_root_path      varchar(255)    default null               comment '知识库文件系统落盘绝对路径',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(500)    default null               comment '备注',
  primary key (project_id),
  key idx_novel_project_user_id (user_id)
) engine=innodb auto_increment=1 comment = '创作项目表';

-- ----------------------------
-- 2、架构（大纲）版本表
-- ----------------------------
drop table if exists novel_architecture_version;
create table novel_architecture_version (
  version_id        bigint(20)      not null auto_increment    comment '版本ID',
  project_id        bigint(20)      not null                   comment '所属项目ID',
  version_no        int(11)         not null                   comment '版本号，从1递增',
  content           mediumtext                                 comment '架构内容（Markdown）',
  source            varchar(30)     default null               comment '来源（deepseek_parse/doubao_optimize/manual_edit）',
  review_status     varchar(20)     default 'pending'          comment '审核状态（pending=待审核 approved=通过 rejected=驳回）',
  review_comment    varchar(500)    default null               comment '审核意见',
  kb_file_path      varchar(255)    default null               comment '对应知识库文件相对路径',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(500)    default null               comment '备注',
  primary key (version_id),
  key idx_novel_arch_version_project_id (project_id)
) engine=innodb auto_increment=1 comment = '架构（大纲）版本表';

-- ----------------------------
-- 3、章节主表
-- ----------------------------
drop table if exists novel_chapter;
create table novel_chapter (
  chapter_id        bigint(20)      not null auto_increment    comment '章节ID',
  project_id        bigint(20)      not null                   comment '所属项目ID',
  chapter_no        int(11)         not null                   comment '章节序号',
  title             varchar(200)    default null               comment '章节标题',
  status            varchar(20)     default 'pending'          comment '章节状态（pending=待生成 generating=生成中 pending_review=待审核 approved=已通过 rejected=已驳回 published=已发布）',
  latest_version_id bigint(20)      default null               comment '最新版本ID（指向 novel_chapter_version.version_id）',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(500)    default null               comment '备注',
  primary key (chapter_id),
  key idx_novel_chapter_project_id (project_id),
  unique key uk_novel_chapter_project_no (project_id, chapter_no)
) engine=innodb auto_increment=1 comment = '章节主表';

-- ----------------------------
-- 4、章节版本表
-- ----------------------------
drop table if exists novel_chapter_version;
create table novel_chapter_version (
  version_id        bigint(20)      not null auto_increment    comment '版本ID',
  chapter_id        bigint(20)      not null                   comment '所属章节ID',
  version_no        int(11)         not null                   comment '版本号，从1递增',
  content           longtext                                   comment '章节正文',
  model_source      varchar(30)     default null               comment '生成模型（deepseek/doubao）',
  optimize_round    int(11)         default 1                  comment '优化轮次，用于区分同一轮的多个候选',
  review_status     varchar(20)     default 'pending'          comment '审核状态（pending=待审核 approved=通过 rejected=驳回）',
  kb_file_path      varchar(255)    default null               comment '对应知识库文件相对路径',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(500)    default null               comment '备注',
  primary key (version_id),
  key idx_novel_chapter_version_chapter_id (chapter_id)
) engine=innodb auto_increment=1 comment = '章节版本表';

-- ----------------------------
-- 5、审核记录表（架构、章节共用）
-- ----------------------------
drop table if exists novel_review_record;
create table novel_review_record (
  record_id         bigint(20)      not null auto_increment    comment '记录ID',
  target_type       varchar(20)     not null                   comment '审核对象类型（architecture=架构 chapter=章节）',
  target_id         bigint(20)      not null                   comment '审核对象ID（architecture 对应 project_id，chapter 对应 chapter_id）',
  version_id        bigint(20)      default null               comment '具体审核的版本ID',
  reviewer_id       bigint(20)      default null               comment '审核人用户ID',
  review_result     varchar(20)     not null                   comment '审核结果（pass=通过 reject=驳回）',
  review_comment    varchar(500)    default null               comment '审核意见',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time       datetime                                   comment '创建时间',
  primary key (record_id),
  key idx_novel_review_record_target (target_type, target_id)
) engine=innodb auto_increment=1 comment = '审核记录表';

-- ----------------------------
-- 6、异步生成任务表
-- ----------------------------
drop table if exists novel_generation_task;
create table novel_generation_task (
  task_id           bigint(20)      not null auto_increment    comment '任务ID',
  project_id        bigint(20)      not null                   comment '所属项目ID',
  task_type         varchar(30)     not null                   comment '任务类型（architecture_parse/architecture_optimize/chapter_generate/chapter_optimize/export）',
  status            varchar(20)     default 'pending'          comment '任务状态（pending=待处理 running=执行中 success=成功 failed=失败）',
  progress          int(11)         default 0                  comment '进度百分比（0-100）',
  input_params      text                                       comment '任务输入参数（JSON）',
  result_ref        varchar(255)    default null               comment '结果引用（如生成的版本ID、导出文件路径）',
  error_msg         varchar(1000)   default null               comment '失败原因',
  start_time        datetime        default null               comment '开始执行时间',
  finish_time       datetime        default null               comment '完成时间',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time       datetime                                   comment '创建时间',
  primary key (task_id),
  key idx_novel_gen_task_project_id (project_id),
  key idx_novel_gen_task_status (status)
) engine=innodb auto_increment=1 comment = '异步生成任务表';

-- ----------------------------
-- 7、模型接入配置表（阶段2 ModelRouterService 按此表做多模型路由，阶段1代码暂读 Nacos 静态配置）
-- ----------------------------
drop table if exists ai_model_config;
create table ai_model_config (
  config_id         bigint(20)      not null auto_increment    comment '配置ID',
  model_key         varchar(30)     not null                   comment '模型标识（deepseek/doubao）',
  base_url          varchar(255)    default null               comment '接口根地址',
  api_key           varchar(500)    default null               comment 'API Key（应用层加密后存储，禁止明文）',
  enabled           char(1)         default '1'                comment '是否启用（0停用 1启用）',
  priority          int(11)         default 0                  comment '路由优先级，数值越大优先级越高',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(500)    default null               comment '备注',
  primary key (config_id),
  unique key uk_ai_model_config_model_key (model_key)
) engine=innodb auto_increment=1 comment = '模型接入配置表';

-- ----------------------------
-- 8、Prompt模板表
-- ----------------------------
drop table if exists ai_prompt_template;
create table ai_prompt_template (
  template_id       bigint(20)      not null auto_increment    comment '模板ID',
  template_key      varchar(50)     not null                   comment '模板标识',
  scenario          varchar(30)     not null                   comment '使用场景（architecture_parse/architecture_optimize/chapter_generate/chapter_optimize）',
  content           text            not null                   comment '模板内容，含 {{占位符}}',
  version           int(11)         default 1                  comment '模板版本号',
  enabled           char(1)         default '1'                comment '是否启用（0停用 1启用）',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(500)    default null               comment '备注',
  primary key (template_id),
  unique key uk_ai_prompt_template_key (template_key)
) engine=innodb auto_increment=1 comment = 'Prompt模板表';

-- ----------------------------
-- 初始化-Prompt模板种子数据（先给一版简单模板占位，后续迭代直接改数据不用改代码）
-- ----------------------------
insert into ai_prompt_template(template_key, scenario, content, version, enabled, create_by, create_time) values
('architecture_parse_v1', 'architecture_parse',
'你是一名专业的小说编辑。请阅读以下创作素材，提炼并生成结构化的小说架构大纲，包含：世界观设定、主要人物小传（性格/目标/关系）、核心剧情线、关键伏笔清单。请用 Markdown 分级标题输出。\n\n创作素材：\n{{sourceContent}}',
1, '1', 'admin', sysdate()),
('chapter_generate_v1', 'chapter_generate',
'你是一名专业的小说写手。请基于以下小说架构，创作第 {{chapterNo}} 章正文，章节标题为《{{chapterTitle}}》。要求：与已有人设、剧情线保持一致，不遗漏关键伏笔，字数不少于 2000 字。\n\n小说架构：\n{{architectureContent}}\n\n附加要求：\n{{extraInstruction}}',
1, '1', 'admin', sysdate());

-- ----------------------------
-- 9、模型调用用量日志表
-- ----------------------------
drop table if exists ai_usage_log;
create table ai_usage_log (
  log_id             bigint(20)      not null auto_increment    comment '日志ID',
  project_id         bigint(20)      default null               comment '关联项目ID',
  user_id            bigint(20)      default null               comment '关联用户ID',
  model_key          varchar(30)     not null                   comment '模型标识',
  task_id            bigint(20)      default null               comment '关联任务ID',
  prompt_tokens      int(11)         default 0                  comment '输入token数',
  completion_tokens  int(11)         default 0                  comment '输出token数',
  cost               decimal(10,4)   default 0.0000             comment '调用成本（元）',
  create_time        datetime                                   comment '创建时间',
  primary key (log_id),
  key idx_ai_usage_log_project_id (project_id),
  key idx_ai_usage_log_user_id (user_id)
) engine=innodb auto_increment=1 comment = '模型调用用量日志表';
