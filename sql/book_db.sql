/*
 Navicat Premium Data Transfer

 Source Server         : 自己-腾讯云82.157.95.26
 Source Server Type    : MySQL
 Source Server Version : 80046
 Source Host           : 82.157.95.26:3306
 Source Schema         : book_db

 Target Server Type    : MySQL
 Target Server Version : 80046
 File Encoding         : 65001

 Date: 07/08/2026 01:56:25
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for ai_model_config
-- ----------------------------
DROP TABLE IF EXISTS `ai_model_config`;
CREATE TABLE `ai_model_config`  (
  `config_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `model_key` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模型标识（deepseek/doubao）',
  `base_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '接口根地址',
  `api_key` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'API Key（应用层加密后存储，禁止明文）',
  `enabled` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '是否启用（0停用 1启用）',
  `priority` int(0) NULL DEFAULT 0 COMMENT '路由优先级，数值越大优先级越高',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`) USING BTREE,
  UNIQUE INDEX `uk_ai_model_config_model_key`(`model_key`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '模型接入配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ai_model_config
-- ----------------------------

-- ----------------------------
-- Table structure for ai_prompt_template
-- ----------------------------
DROP TABLE IF EXISTS `ai_prompt_template`;
CREATE TABLE `ai_prompt_template`  (
  `template_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '模板ID',
  `template_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模板标识',
  `scenario` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '使用场景（architecture_parse/architecture_optimize/chapter_generate/chapter_optimize）',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模板内容，含 {{占位符}}',
  `version` int(0) NULL DEFAULT 1 COMMENT '模板版本号',
  `enabled` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '是否启用（0停用 1启用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`template_id`) USING BTREE,
  UNIQUE INDEX `uk_ai_prompt_template_key`(`template_key`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Prompt模板表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ai_prompt_template
-- ----------------------------
INSERT INTO `ai_prompt_template` VALUES (1, 'architecture_parse_v1', 'architecture_parse', '你是一名专业的小说编辑。请阅读以下创作素材，提炼并生成结构化的小说架构大纲，包含：世界观设定、主要人物小传（性格/目标/关系）、核心剧情线、关键伏笔清单。请用 Markdown 分级标题输出。\n\n创作素材：\n{{sourceContent}}', 1, '1', 'admin', '2026-08-05 22:36:41', '', NULL, NULL);
INSERT INTO `ai_prompt_template` VALUES (2, 'chapter_generate_v1', 'chapter_generate', '你是一名专业的小说写手。请基于以下小说架构，创作第 {{chapterNo}} 章正文，章节标题为《{{chapterTitle}}》。要求：与已有人设、剧情线保持一致，不遗漏关键伏笔，字数不少于 2000 字。\n\n小说架构：\n{{architectureContent}}\n\n附加要求：\n{{extraInstruction}}', 1, '1', 'admin', '2026-08-05 22:36:41', '', NULL, NULL);
INSERT INTO `ai_prompt_template` VALUES (4, 'architecture_optimize_v1', 'architecture_optimize', '你是一名资深小说主编。请在不改变核心设定的前提下，优化以下小说架构大纲：补全人物动机与关系、理顺剧情线、明确伏笔回收点，输出完整 Markdown 架构。\n\n当前架构：\n{{architectureContent}}\n\n附加要求：\n{{extraInstruction}}', 1, '1', 'admin', '2026-08-07 01:32:22', '', NULL, NULL);

-- ----------------------------
-- Table structure for ai_usage_log
-- ----------------------------
DROP TABLE IF EXISTS `ai_usage_log`;
CREATE TABLE `ai_usage_log`  (
  `log_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `project_id` bigint(0) NULL DEFAULT NULL COMMENT '关联项目ID',
  `user_id` bigint(0) NULL DEFAULT NULL COMMENT '关联用户ID',
  `model_key` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模型标识',
  `task_id` bigint(0) NULL DEFAULT NULL COMMENT '关联任务ID',
  `prompt_tokens` int(0) NULL DEFAULT 0 COMMENT '输入token数',
  `completion_tokens` int(0) NULL DEFAULT 0 COMMENT '输出token数',
  `cost` decimal(10, 4) NULL COMMENT '调用成本（元）',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`log_id`) USING BTREE,
  INDEX `idx_ai_usage_log_project_id`(`project_id`) USING BTREE,
  INDEX `idx_ai_usage_log_user_id`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '模型调用用量日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ai_usage_log
-- ----------------------------

-- ----------------------------
-- Table structure for gen_table
-- ----------------------------
DROP TABLE IF EXISTS `gen_table`;
CREATE TABLE `gen_table`  (
  `table_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '表名称',
  `table_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '表描述',
  `sub_table_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联子表的表名',
  `sub_table_fk_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '子表关联的外键名',
  `class_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '实体类名称',
  `tpl_category` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'crud' COMMENT '使用的模板（crud单表操作 tree树表操作）',
  `tpl_web_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '前端模板类型（element-ui模版 element-plus模版）',
  `package_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成包路径',
  `module_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成模块名',
  `business_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成业务名',
  `function_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成功能名',
  `function_author` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成功能作者',
  `form_col_num` int(0) NULL DEFAULT 1 COMMENT '表单布局（单列 双列 三列）',
  `gen_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '生成代码方式（0zip压缩包 1自定义路径）',
  `gen_path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '/' COMMENT '生成路径（不填默认项目路径）',
  `options` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '其它生成选项',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`table_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '代码生成业务表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gen_table
-- ----------------------------

-- ----------------------------
-- Table structure for gen_table_column
-- ----------------------------
DROP TABLE IF EXISTS `gen_table_column`;
CREATE TABLE `gen_table_column`  (
  `column_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_id` bigint(0) NULL DEFAULT NULL COMMENT '归属表编号',
  `column_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '列名称',
  `column_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '列描述',
  `column_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '列类型',
  `java_type` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'JAVA类型',
  `java_field` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'JAVA字段名',
  `is_pk` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否主键（1是）',
  `is_increment` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否自增（1是）',
  `is_required` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否必填（1是）',
  `is_insert` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否为插入字段（1是）',
  `is_edit` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否编辑字段（1是）',
  `is_list` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否列表字段（1是）',
  `is_query` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否查询字段（1是）',
  `query_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'EQ' COMMENT '查询方式（等于、不等于、大于、小于、范围）',
  `html_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）',
  `dict_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `sort` int(0) NULL DEFAULT NULL COMMENT '排序',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`column_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '代码生成业务表字段' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gen_table_column
-- ----------------------------

-- ----------------------------
-- Table structure for novel_architecture_version
-- ----------------------------
DROP TABLE IF EXISTS `novel_architecture_version`;
CREATE TABLE `novel_architecture_version`  (
  `version_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '版本ID',
  `project_id` bigint(0) NOT NULL COMMENT '所属项目ID',
  `version_no` int(0) NOT NULL COMMENT '版本号，从1递增',
  `content` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '架构内容（Markdown）',
  `source` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '来源（deepseek_parse/doubao_optimize/manual_edit）',
  `review_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending' COMMENT '审核状态（pending=待审核 approved=通过 rejected=驳回）',
  `review_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核意见',
  `kb_file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '对应知识库文件相对路径',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`version_id`) USING BTREE,
  INDEX `idx_novel_arch_version_project_id`(`project_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '架构（大纲）版本表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of novel_architecture_version
-- ----------------------------
INSERT INTO `novel_architecture_version` VALUES (1, 1, 1, '# 小说架构大纲：《回响之时》\n\n## 一、世界观设定\n\n### 1. 基础设定\n- **时代背景**：现代都市（架空设定，科技水平与现实相当），灵气复苏初期\n- **核心概念**：城市地下存在远古封印，封印松动导致灵气泄漏，部分人类觉醒异能\n- **异能体系**：觉醒者脑域中形成「灵核」，按属性分为：\n  - 精神系（读心、催眠、记忆操控）\n  - 物质系（控物、元素操控）\n  - 时空系（极稀有，回溯、预知、瞬移）\n  - 强化系（肉体强化、五感提升）\n- **代价设定**：所有异能使用皆有代价，如体力消耗、精神疲劳、记忆损耗等\n\n### 2. 势力格局\n| 势力 | 定位 | 核心诉求 |\n|------|------|----------|\n| 异能管理局 | 官方管控机构 | 维持秩序，研究封印 |\n| 雾行会 | 反派秘密结社 | 打破封印，恢复上古灵气时代 |\n| 普通人类 | 中立民众 | 恐惧与排斥觉醒者 |\n| 散修觉醒者 | 第三方势力 | 追求自由，不愿受管控 |\n\n### 3. 核心场景\n- **临江市**：故事主要发生地，封印位于城市地下的古代祭坛遗迹\n- **异能管理局临江分局**：女主工作场所，表面为生物科技实验室\n- **临江大学**：男主所在学校，取景地\n- **地下封印区**：设有三重防护结界，核心区域需要「钥匙」才能进入\n\n---\n\n## 二、主要人物小传\n\n### 1. 林澈（男主）\n- **身份**：临江大学历史系大二学生，灵气复苏后觉醒异能\n- **性格特征**：\n  - 谨慎细致（作为历史系学生对文献有独特敏感）\n  - 外冷内热，习惯孤身一人\n  - 有轻微强迫症，行为习惯规律化——以避免时间线混乱\n- **异能**：「回溯十秒」\n  - 可将十秒内发生的事情回退重来\n  - 代价：每次使用后丢失最近一小时的部分记忆（随机丢失），反复使用会积累记忆缺口\n  - 限制：无法回溯超越十秒，且同一时刻只能单次回溯\n- **隐藏身份**：封印「钥匙」的现代载体——幼年时曾被劫持进入封印核心区，体内融合了钥匙碎片\n- **核心目标**：\n  - 表层：生存下去，追查自己记忆越来越浑浊的真相\n  - 深层：找出自己体内异常力量的来源\n\n**人物弧光**：从逃避自己能力 → 学会承担代价 → 最后主动使用能力面对命运\n\n### 2. 苏晚（女主）\n- **身份**：异能管理局临江分局调查员，实战经验丰富\n- **性格特征**：\n  - 表面冷淡公事公办，实际极度缺乏安全感\n  - 对线索有极强的执念，一旦锁定目标不会放弃\n  - 心防甚重，不善表达情感\n- **异能**：「记忆感知」——可触摸物品残留的情绪记忆片段（不完整且碎片化）\n- **背景动机**：\n  - 三年期，其兄苏曜（前任管理局精英）调查封印异动时失踪\n  - 官方报告称「因公殉职」，但苏晚坚信哥哥仍活着\n  - 私下一直在调查雾行会与该案的关联\n- **核心目标**：\n  - 表层：完成调查任务，寻找哥哥的下落\n  - 深层：查明当年封印异动的真相\n\n**人物弧光**：从封闭自我 → 学会信任与依赖 → 放下执念找到真正的守护\n\n### 3. 苏曜（重要配角/失踪者）\n- **身份**：苏晚哥哥，原异能管理局高级调查员\n- **性格**：理想主义者，温和但坚定\n- **异能**：「空间感知」（可探测百米内任何异常波动）\n- **隐藏身份**：雾行会曾经的打入者，却在一处封印区接触上古灵兽意识后被「影响」，开始怀疑管理局对封印研究的态度\n- **关键在于**：他没有死，而是被雾行会控制，成为激活封印的引导器\n\n### 4. 雾行会首领·「玄冥」\n- **身份**：未露真面，仅通过幻象和声音对话\n- **动机**：并非单纯反派，他相信封印彻底崩溃是「复原世界」的唯一途径——灵气复苏的最终形态是旧秩序重塑\n- **异能**：不明（隐藏至后期揭示——与林澈能力来自同一力量系，为「回溯」的进阶版「重置」）\n\n---\n\n## 三、核心剧情线\n\n### 第一幕：觉醒·初遇（章1-8）\n- **开场**：林澈在图书馆深夜自习，封印碎片泄露引发小范围灵气波动，他下意识触发「回溯」，却因为意外被困在回溯时间线里，错过最佳逃离时机\n- **曝光**：异能管理局检测到异常能量波动，苏晚前来调查。林澈在危机中显露出不被记录在案的能力\n- **冲突**：林澈被传唤至管理局，苏晚认定他为「目击者」，要求配合调查。林澈因记忆丢失无法提供有效证词\n- **转折**：两人共同调查的第一起连环失踪案，受害者均为封印区附近的「普通市民」。林澈使用回溯救下一名受害者，但使用后完全忘记自己救过人——苏晚从监控画面中看到他刚才「没有做过」的动作\n\n> **核心冲突钩子**：苏晚开始怀疑林澈的记忆缺失与案件有关。\n\n### 第二幕：交织·追索（章9-20）\n- **线索串串**：连环案件中，每个失踪者身上都被刻有古文字符，林澈发现这些字符与历史文献中封印碑文的文字高度相似\n- **联手**：苏晚申请与林澈组成临时拍档（表面为「监控」他，实际是为调查哥哥失踪线索）\n- **重要节点一**：两人潜入一处废弃的古代地宫（可能是封印分支），遇到雾行会外围成员。林澈在战斗中被迫大规模回溯，结果丢失了部分关于自己童年的关键记忆\n- **重要节点二**：苏晚通过哥哥留下的物品使用「记忆感知」，看到模糊画面：苏曜在封印深处发现了一个「被刻了符文的婴儿」——对应着林澈的身份\n- **核心冲突**：苏晚意识到林澈可能就是哥哥失踪的关键，却无法开口——她怀疑自己的哥哥正站在「错误的一方」\n\n### 第三幕：真相·交锋（章21-30）\n- **揭示一**：管理局暗部文献记载：二十年前的封印异动，一婴儿被推入封印核心，成为「钥匙容器」\n- **揭示二**：林澈的「回溯」能力实际上是钥匙被激活后的余波——这把钥匙可以真正逆转封印崩溃\n- **本质翻转**：雾行会并非要「用钥匙打开封印」，而是反过来——**要毁掉钥匙，让封印永远无法修复**。他们的最终目标是封印古老灵兽的意志引导世界走向「新秩序」\n- **高潮对峙**：苏晚发现苏曜被控制后，被迫与哥哥正面冲突；林澈使用回溯想救回被刺伤的苏晚，却发现自己只能回溯十秒，救不了这个结果——他在所有尝试后绝望\n- **反转关键**：林澈在极限状态下，回溯的力量觉醒——不再是「十秒」，而是「重置」。他发现自己的能力从来就不是回溯，而是「纠正错误」的可能性\n\n### 第四幕：代价·抉择（章31-40）\n- **终极选择**：林澈发现自己有两种方式终结封印崩溃：A) 释放钥匙力量，永久封锁封印层；B) 接受雾行会的方案——将灵气重新压缩回封印。方案A会耗尽他全部记忆；方案B则会让整个城市所有觉醒者瞬间丧失能力，且可能产生不可逆的副作用\n- **高潮**：苏晚用自己查到的一切帮林澈找到了第三种方案：将钥匙碎片「反转」，令封印转为「半开放」状态——上古灵气与现代科技共存。但苏晚要付出代价（可能永久失去对哥哥的记忆）\n- **结局**：两人成功封印，苏曜获救（但异能全失），雾行会部分瓦解。林澈保留了部分记忆（因为裂缝碎裂导致代价部分解除），苏晚选择接受了失去部分记忆的代价\n- **收尾**：两人在废弃的地宫口再次相遇，她忘记了一些事，却依然记得他。开放式结局\n\n---\n\n## 四、关键伏笔清单\n\n| 编号 | 伏笔内容 | 铺垫位置 | 揭示时机 | 备注 |\n|------|----------|----------|----------|------|\n| V-01 | 林澈幼年被劫持进入封印区的碎片画面 | 第二幕「记忆感知」片段 | 第三幕揭示一 | 串联钥匙容器设定 |\n| V-02 | 苏曜在被控制前留下的加密笔记（藏在日常物品中） | 第二幕苏晚搜寻哥哥遗物 | 第三幕揭示二 | 线索链的关键节点 |\n| V-03 | 管理局地下档案室中留有林澈的出生记录，被加密字段存疑 | 第一幕开场管理局传唤 | 第三幕揭示一 | 早期隐线 |\n| V-04 | 玄冥契约灵兽「烛龙」——上古灵兽的意识通过雾行会做引导 | 第二幕地宫壁画/铭文 | 第三幕高潮 | 引出上古阵营 |\n| V-05 | 林澈回溯的「十秒」上限并非恒定（某些时刻感受到更久的时间） | 第一幕初试时 | 第三幕反转 | 暗示可进阶为「重置」 |\n| V-06 | 苏晚对哥哥的记忆在最后阶段出现「片段空白」 | 第三幕对峙后残留 | 结局揭示 | 暗示她曾用异能接触过自己 |\n| V-07 | 「钥匙」并非物品，而是林澈的「存在」——与封印核心共存的印记 | 第五幕高潮 | 结局核心反转 | 颠覆读者对「钥匙」的认知 |\n| V-08 | 苏曜在失踪前最后通话中说：「不要相信管理局的台账」 | 第二幕初步调查 | 第三幕揭示一 | 埋下管理局内奸疑云 |\n| V-09 | 林澈幼年时曾梦到「烛龙」的轮廓，童年涂鸦中反复出现 | 第一幕梦境片段 | 第三幕玄冥身份揭示 | 最早伏笔，暗示命运纠缠 |\n| V-10 | 「回溯」代价的隐形解谜：唯一能让代价不触发的方式是「在完全相同的时间线上做出不同选择」 | 第二幕多处战斗 | 结局 | 为最终解法提供合理逻辑 |\n\n---\n\n## 五、架构补充说明\n\n- **节奏设计**：全篇约十万字，采用三流一体走势（悬疑/动作/情感），三十场戏分布均匀\n- **叙事视角**：主要以林澈第一人称时间线展开，关键章节穿插苏晚视角，形成双线交错\n- **主题表达**：「时间的逆转从来不是改变过去，而是直面代价的选择」\n- **开放式伏笔**：结局保留雾行会残余势力重组、管理局内部清洗线、灵兽「烛龙」苏醒暗示，为续作留余地\n\n---\n\n> 架构核心逻辑：**所有伏笔的揭示都必须服务于人物成长弧光，而非单纯反转堆砌。** 三个核心真相（钥匙容器、能力进阶、管理局内幕）分别对应林澈的自我认知、能力觉醒与社会关系三重维度。', 'deepseek_parse', 'approved', '', '01-全局架构/v1-架构.md', 'admin', '2026-08-07 00:29:29', 'admin', '2026-08-07 00:30:16', NULL);

-- ----------------------------
-- Table structure for novel_chapter
-- ----------------------------
DROP TABLE IF EXISTS `novel_chapter`;
CREATE TABLE `novel_chapter`  (
  `chapter_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '章节ID',
  `project_id` bigint(0) NOT NULL COMMENT '所属项目ID',
  `chapter_no` int(0) NOT NULL COMMENT '章节序号',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '章节标题',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending' COMMENT '章节状态（pending=待生成 generating=生成中 pending_review=待审核 approved=已通过 rejected=已驳回 published=已发布）',
  `latest_version_id` bigint(0) NULL DEFAULT NULL COMMENT '最新版本ID（指向 novel_chapter_version.version_id）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`chapter_id`) USING BTREE,
  UNIQUE INDEX `uk_novel_chapter_project_no`(`project_id`, `chapter_no`) USING BTREE,
  INDEX `idx_novel_chapter_project_id`(`project_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '章节主表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of novel_chapter
-- ----------------------------
INSERT INTO `novel_chapter` VALUES (1, 1, 1, '第一章', 'pending_review', 1, 'admin', '2026-08-07 00:59:40', 'admin', '2026-08-07 00:59:40', NULL);

-- ----------------------------
-- Table structure for novel_chapter_version
-- ----------------------------
DROP TABLE IF EXISTS `novel_chapter_version`;
CREATE TABLE `novel_chapter_version`  (
  `version_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '版本ID',
  `chapter_id` bigint(0) NOT NULL COMMENT '所属章节ID',
  `version_no` int(0) NOT NULL COMMENT '版本号，从1递增',
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '章节正文',
  `model_source` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成模型（deepseek/doubao）',
  `optimize_round` int(0) NULL DEFAULT 1 COMMENT '优化轮次，用于区分同一轮的多个候选',
  `score` int(0) NULL DEFAULT NULL COMMENT '规则打分 0-100',
  `review_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending' COMMENT '审核状态（pending=待审核 approved=通过 rejected=驳回）',
  `kb_file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '对应知识库文件相对路径',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`version_id`) USING BTREE,
  INDEX `idx_novel_chapter_version_chapter_id`(`chapter_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '章节版本表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of novel_chapter_version
-- ----------------------------
INSERT INTO `novel_chapter_version` VALUES (1, 1, 1, '## 第一章\n\n图书馆的冷光灯管在天花板发出细微的嗡鸣，像某种不知疲倦的节拍器。林澈揉了揉眼角，目光扫过摊开的《临江府志》残卷，在第一百三十七页停住，那里有一段模糊的记载：「……天陨而后地裂，暗河倒涌，城中井水尽数赤红，月余乃止。时人谓之‘回响之时’。」\n\n回响之时。\n\n他提笔在笔记本上写下这四个字，笔迹方正得很，像他做任何事一样规规矩矩。这是历史系二年级才有的选修课作业——地方文献中的灵异志怪与历史编码——教授说那些看似荒诞的记载背后往往藏着再真实不过的史实。但林澈选这门课的真实原因，是近半年来他脑海中那些破碎的、无法归类的声音。\n\n那些声音像回声，仿佛有什么东西曾在此地响起，又被命运的手指抹去了。\n\n他看了一眼手表，晚上十一点十一分，分毫不差。这种精确感带来的安心让他微微舒了口气——他是靠这种规律生活的。早晨七点四十三分出门，八点零六分到教室第三排靠窗的位置，晚上十点整熄灯睡觉。他需要这些锚点来稳住自己，因为记忆深处有些东西，正在以他无法控制的方式缓缓松动。\n\n这半年来，他开始忘记一些事。一周前忘记了自己把伞放在教室后排，昨天忘记了和同班同学约好的聚餐，今天上午，他似乎又忘记了一件……更重要的事，但他已经想不起来了。\n\n林澈用力握了握手中的笔，指节泛白。远处传来有什么破碎的声音，很轻，像玻璃珠落在瓷砖上。他抬起头，图书馆二楼自习区只有他一个人，门窗紧闭，角落里落着灰尘。但他清晰地感觉到地面在微微震颤，一种极低频的、连玻璃水杯里的水面都在颤动的振动。\n\n他的心脏漏跳了一拍。\n\n书页边缘有什么东西在发光——不是灯光的反射，是一种从纸张内部透出来的微光，淡蓝色的、游丝般的荧光。它们从那些古文字间渗出来，像被封存很久的东西正在苏醒。林澈站起来，椅脚刮过地面发出刺耳的响。他看见那些蓝光从书页中缓缓升起，向天花板的方向飘去，穿过书架、穿过来不及反应的他——\n\n在接触到他身体的一瞬间，蓝光像是遇到了什么磁石一样，猛然加速涌入他的胸腔。\n\n同时，他听到了一声低沉的、苍老的咆哮。那声音不是从耳朵进入的，而是直接从骨骼深处、从心脏最中央迸发出来的。巨大的痛楚让林澈膝盖一软，眼前的景象像玻璃碎裂般出现裂痕——\n\n他看见了另一幅画面：一座幽暗的地下祭坛，刻满符文的地面中央躺着一个婴儿，婴儿的胸口嵌着一枚发光的东西，像琉璃、又像琥珀。祭坛边缘站着穿黑衣的人，他们高举双手，口中念着听不懂的音节——\n\n然后画面扭曲，消融，回归图书馆的冷白灯光下。\n\n林澈大口喘着气，发现自己仍站在原地。不对，他刚才动了——他明明站起来朝书架方向走了两步，他看到蓝光向窗边涌去，而现在，他还站在原地，一步未迈。\n\n一股寒意沿着脊椎爬升。\n\n他想起一件事。就在蓝光接触他身体的那一瞬间，他做了一个决定——准确地说，他正确地做出了一次判断：蓝光涌来的方向危险。他应该退后，应该跑向门口。\n\n但他没有动。他感到自己像一个观看者的躯体傀儡，做出了后退的姿势，却没有实际行动的余地。\n\n不。不对。\n\n他的目光骤然锐利起来，紧紧盯着自己的手——桌上的笔记本，笔迹没有变形，笔帽还保持着原先的角度。他抬手摸了摸自己的领口，他记得刚才蓝光涌入时他下意识扯了一把衣领，而现在，衣领平整如初。\n\n空气的流动告诉他，时间，刚刚被某个人、或者某股力量，强行回拨了。\n\n他不知道那是多久前的事——几秒，还是更久——但他知道发生了一件不应该发生的事：他的处境被重来了一次，而这一次，他正站在蓝光涌来的必经之路上。\n\n同时，他发现自己的脑海中少了一段记忆。他不知道他在这次“重来”之前究竟做了什么，但他隐约感觉，那时他曾经有过一个动作，一个可以让他避开蓝光的动作。\n\n可现在，他不记得了。\n\n眼前的蓝光像是拥有了意志一样，从书页中挣脱出来，以一种仪式感的缓慢姿态旋转。那声音又响了起来——低沉苍老的咆哮——但这次它变成了一种低语，古老得像化石中鼓动的某种生命。林澈盯着那些光，听见一个念头浮现在他的意识里，清晰而冰冷：\n\n“你在这里。”\n\n他说。不，那声音说。\n\n他知道他必须做出选择。要么后退，要么向前。他的直觉在尖叫着让他后退，但另一个声音——一种敏锐的、清醒的自我意识——告诉他，后退已经来不及了。\n\n他向前迈出一步。蓝光猛然炸开，像被惊动的萤火虫群四散飞窜。他感受到地板更加剧烈的震动，远处传来自动扶梯停运的巨大声响，紧接着是一种更刺耳的声音——警报器。仿佛有什么地方检测到了这场异常，正在以某种规则系统回响。\n\n他转身朝门口跑去，但脚踝一痛，他被绊倒了，膝盖磕在桌腿上。他低头，看见自己的鞋带不知何时松开了，黑色的鞋带缠住了另一只脚的鞋扣。他感觉到不对劲——他从进入图书馆到现在就没有系过鞋带，他进门时把它系得很紧。\n\n他想解开鞋带，但手指颤抖得不听使唤。身后的蓝光没有追来，却在逐渐凝聚起来，构成一个模糊的、蛇形的轮廓。它的双目部位亮起熔金黄色的光，直直地注视着他。\n\n林澈的瞳孔猛然收缩。\n\n那只蛇形光影微微昂起头，仿佛在审视他。然后它张开了“嘴”——一种无声的啸叫，空气震裂，书架、桌子、书页、灯管——所有东西都在一瞬间被无形的力量抛向四面八方。林澈的身体被冲击波抬起，重重撞在墙上，眼前一片黑暗。\n\n他再次感觉到那种“重来”的错觉。时间线被拉扯、扭曲——他的意识在某个界限处疯狂颤抖，就像有人在翻阅一段录像带，试图找到最后一帧的落点。\n\n然后，一切都静止了。\n\n他睁开眼，发现自己倒在地上，浑身剧痛，但大脑中翻涌着一种深刻的、强烈的、熟悉而陌生的感觉——他刚刚曾看见过一个结尾，而现在他正站在那个结尾之前。他不知道自己何时做出了这个决定，但他发现自己正在做一件从未做过的、违背他所有行为习惯的事：\n\n他没有逃跑。他弯下腰，拾起了那本《临江府志》。\n\n书页上那些古文字正在褪色，仿佛某种力量正在将它们抹去，取而代之的是空白页码，就像这本书刚刚被写出不久。林澈捧着书，膝盖发软，浑身被冷汗浸透。他本能地倒退了几步，拉开与那只蛇形光影之间的距离。\n\n蛇影的身形渐渐变得模糊，像是能量耗尽般逐渐消散。但它消散之前，最后看了他一眼，那双熔金色的“眼睛”里，有一种让林澈心底发毛的情绪。\n\n是怀念。\n\n像是看见久别的故人。\n\n林澈站在一片狼藉的图书馆中央，耳边是余音不绝的警报声和远处传来的脚步。他不知道这些脚步是保安还是别的什么人，但他清楚一件事：这里发生的一切，即将以某种方式被记录在案，而他——一个没有异能检测记录的普通大学生——正站在事件的中心。\n\n他低头，发现自己笔记本的最后一页被什么力量写上了一行字。那不是他的字迹，笔锋凌厉而古老，像用焦炭写就：\n\n“你与那枚钥匙的第一次接触，始于此处。”\n\n他还没来得及细看，脚步声已经停在了门外。林澈将笔记本合上，压进那本《临江府志》的扉页里。他的心跳如鼓，脑海中有个念头顽固地盘旋不去——他丢失的那段时间，他丢失的那段记忆，可能比他想得更重要。\n\n他有种直觉：回响之时，这件事才刚刚开始。\n\n而他，是那面被敲响的钟。', 'deepseek', 1, NULL, 'pending', '03-章节优化记录/第1章/v1-deepseek.md', 'admin', '2026-08-07 00:59:40', '', NULL, NULL);

-- ----------------------------
-- Table structure for novel_generation_task
-- ----------------------------
DROP TABLE IF EXISTS `novel_generation_task`;
CREATE TABLE `novel_generation_task`  (
  `task_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `project_id` bigint(0) NOT NULL COMMENT '所属项目ID',
  `task_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务类型（architecture_parse/architecture_optimize/chapter_generate/chapter_optimize/export）',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending' COMMENT '任务状态（pending=待处理 running=执行中 success=成功 failed=失败）',
  `progress` int(0) NULL DEFAULT 0 COMMENT '进度百分比（0-100）',
  `input_params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '任务输入参数（JSON）',
  `result_ref` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '结果引用（如生成的版本ID、导出文件路径）',
  `error_msg` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '失败原因',
  `start_time` datetime(0) NULL DEFAULT NULL COMMENT '开始执行时间',
  `finish_time` datetime(0) NULL DEFAULT NULL COMMENT '完成时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`task_id`) USING BTREE,
  INDEX `idx_novel_gen_task_project_id`(`project_id`) USING BTREE,
  INDEX `idx_novel_gen_task_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '异步生成任务表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of novel_generation_task
-- ----------------------------

-- ----------------------------
-- Table structure for novel_project
-- ----------------------------
DROP TABLE IF EXISTS `novel_project`;
CREATE TABLE `novel_project`  (
  `project_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `user_id` bigint(0) NOT NULL COMMENT '归属用户ID（关联 sys_user.user_id）',
  `project_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '项目名称',
  `source_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'inspiration' COMMENT '来源类型（upload=上传手稿 inspiration=灵感输入）',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'draft' COMMENT '项目状态（draft=草稿 in_progress=进行中 completed=已完成 archived=已归档）',
  `kb_root_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '知识库文件系统落盘绝对路径',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`project_id`) USING BTREE,
  INDEX `idx_novel_project_user_id`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '创作项目表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of novel_project
-- ----------------------------
INSERT INTO `novel_project` VALUES (1, 1, '短篇灵感示例', 'upload', 'in_progress', 'D:\\book-kb-data\\1', 'admin', '2026-08-07 00:17:24', 'admin', '2026-08-07 00:59:40', NULL);

-- ----------------------------
-- Table structure for novel_review_record
-- ----------------------------
DROP TABLE IF EXISTS `novel_review_record`;
CREATE TABLE `novel_review_record`  (
  `record_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `target_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '审核对象类型（architecture=架构 chapter=章节）',
  `target_id` bigint(0) NOT NULL COMMENT '审核对象ID（architecture 对应 project_id，chapter 对应 chapter_id）',
  `version_id` bigint(0) NULL DEFAULT NULL COMMENT '具体审核的版本ID',
  `reviewer_id` bigint(0) NULL DEFAULT NULL COMMENT '审核人用户ID',
  `review_result` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '审核结果（pass=通过 reject=驳回）',
  `review_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核意见',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`record_id`) USING BTREE,
  INDEX `idx_novel_review_record_target`(`target_type`, `target_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '审核记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of novel_review_record
-- ----------------------------

-- ----------------------------
-- Table structure for QRTZ_BLOB_TRIGGERS
-- ----------------------------
DROP TABLE IF EXISTS `QRTZ_BLOB_TRIGGERS`;
CREATE TABLE `QRTZ_BLOB_TRIGGERS`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `blob_data` blob NULL COMMENT '存放持久化Trigger对象',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `QRTZ_BLOB_TRIGGERS_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `QRTZ_TRIGGERS` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Blob类型的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of QRTZ_BLOB_TRIGGERS
-- ----------------------------

-- ----------------------------
-- Table structure for QRTZ_CALENDARS
-- ----------------------------
DROP TABLE IF EXISTS `QRTZ_CALENDARS`;
CREATE TABLE `QRTZ_CALENDARS`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `calendar_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '日历名称',
  `calendar` blob NOT NULL COMMENT '存放持久化calendar对象',
  PRIMARY KEY (`sched_name`, `calendar_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '日历信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of QRTZ_CALENDARS
-- ----------------------------

-- ----------------------------
-- Table structure for QRTZ_CRON_TRIGGERS
-- ----------------------------
DROP TABLE IF EXISTS `QRTZ_CRON_TRIGGERS`;
CREATE TABLE `QRTZ_CRON_TRIGGERS`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `cron_expression` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'cron表达式',
  `time_zone_id` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '时区',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `QRTZ_CRON_TRIGGERS_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `QRTZ_TRIGGERS` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Cron类型的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of QRTZ_CRON_TRIGGERS
-- ----------------------------

-- ----------------------------
-- Table structure for QRTZ_FIRED_TRIGGERS
-- ----------------------------
DROP TABLE IF EXISTS `QRTZ_FIRED_TRIGGERS`;
CREATE TABLE `QRTZ_FIRED_TRIGGERS`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `entry_id` varchar(95) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度器实例id',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `instance_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度器实例名',
  `fired_time` bigint(0) NOT NULL COMMENT '触发的时间',
  `sched_time` bigint(0) NOT NULL COMMENT '定时器制定的时间',
  `priority` int(0) NOT NULL COMMENT '优先级',
  `state` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '任务名称',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '任务组名',
  `is_nonconcurrent` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否并发',
  `requests_recovery` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否接受恢复执行',
  PRIMARY KEY (`sched_name`, `entry_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '已触发的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of QRTZ_FIRED_TRIGGERS
-- ----------------------------

-- ----------------------------
-- Table structure for QRTZ_JOB_DETAILS
-- ----------------------------
DROP TABLE IF EXISTS `QRTZ_JOB_DETAILS`;
CREATE TABLE `QRTZ_JOB_DETAILS`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务名称',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务组名',
  `description` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '相关介绍',
  `job_class_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '执行任务类名称',
  `is_durable` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否持久化',
  `is_nonconcurrent` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否并发',
  `is_update_data` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否更新数据',
  `requests_recovery` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否接受恢复执行',
  `job_data` blob NULL COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`, `job_name`, `job_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '任务详细信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of QRTZ_JOB_DETAILS
-- ----------------------------

-- ----------------------------
-- Table structure for QRTZ_LOCKS
-- ----------------------------
DROP TABLE IF EXISTS `QRTZ_LOCKS`;
CREATE TABLE `QRTZ_LOCKS`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `lock_name` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '悲观锁名称',
  PRIMARY KEY (`sched_name`, `lock_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '存储的悲观锁信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of QRTZ_LOCKS
-- ----------------------------

-- ----------------------------
-- Table structure for QRTZ_PAUSED_TRIGGER_GRPS
-- ----------------------------
DROP TABLE IF EXISTS `QRTZ_PAUSED_TRIGGER_GRPS`;
CREATE TABLE `QRTZ_PAUSED_TRIGGER_GRPS`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  PRIMARY KEY (`sched_name`, `trigger_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '暂停的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of QRTZ_PAUSED_TRIGGER_GRPS
-- ----------------------------

-- ----------------------------
-- Table structure for QRTZ_SCHEDULER_STATE
-- ----------------------------
DROP TABLE IF EXISTS `QRTZ_SCHEDULER_STATE`;
CREATE TABLE `QRTZ_SCHEDULER_STATE`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `instance_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '实例名称',
  `last_checkin_time` bigint(0) NOT NULL COMMENT '上次检查时间',
  `checkin_interval` bigint(0) NOT NULL COMMENT '检查间隔时间',
  PRIMARY KEY (`sched_name`, `instance_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '调度器状态表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of QRTZ_SCHEDULER_STATE
-- ----------------------------

-- ----------------------------
-- Table structure for QRTZ_SIMPLE_TRIGGERS
-- ----------------------------
DROP TABLE IF EXISTS `QRTZ_SIMPLE_TRIGGERS`;
CREATE TABLE `QRTZ_SIMPLE_TRIGGERS`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `repeat_count` bigint(0) NOT NULL COMMENT '重复的次数统计',
  `repeat_interval` bigint(0) NOT NULL COMMENT '重复的间隔时间',
  `times_triggered` bigint(0) NOT NULL COMMENT '已经触发的次数',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `QRTZ_SIMPLE_TRIGGERS_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `QRTZ_TRIGGERS` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '简单触发器的信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of QRTZ_SIMPLE_TRIGGERS
-- ----------------------------

-- ----------------------------
-- Table structure for QRTZ_SIMPROP_TRIGGERS
-- ----------------------------
DROP TABLE IF EXISTS `QRTZ_SIMPROP_TRIGGERS`;
CREATE TABLE `QRTZ_SIMPROP_TRIGGERS`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `str_prop_1` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第一个参数',
  `str_prop_2` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第二个参数',
  `str_prop_3` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第三个参数',
  `int_prop_1` int(0) NULL DEFAULT NULL COMMENT 'int类型的trigger的第一个参数',
  `int_prop_2` int(0) NULL DEFAULT NULL COMMENT 'int类型的trigger的第二个参数',
  `long_prop_1` bigint(0) NULL DEFAULT NULL COMMENT 'long类型的trigger的第一个参数',
  `long_prop_2` bigint(0) NULL DEFAULT NULL COMMENT 'long类型的trigger的第二个参数',
  `dec_prop_1` decimal(13, 4) NULL DEFAULT NULL COMMENT 'decimal类型的trigger的第一个参数',
  `dec_prop_2` decimal(13, 4) NULL DEFAULT NULL COMMENT 'decimal类型的trigger的第二个参数',
  `bool_prop_1` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Boolean类型的trigger的第一个参数',
  `bool_prop_2` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Boolean类型的trigger的第二个参数',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `QRTZ_SIMPROP_TRIGGERS_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `QRTZ_TRIGGERS` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '同步机制的行锁表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of QRTZ_SIMPROP_TRIGGERS
-- ----------------------------

-- ----------------------------
-- Table structure for QRTZ_TRIGGERS
-- ----------------------------
DROP TABLE IF EXISTS `QRTZ_TRIGGERS`;
CREATE TABLE `QRTZ_TRIGGERS`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器的名字',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器所属组的名字',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_job_details表job_name的外键',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_job_details表job_group的外键',
  `description` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '相关介绍',
  `next_fire_time` bigint(0) NULL DEFAULT NULL COMMENT '上一次触发时间（毫秒）',
  `prev_fire_time` bigint(0) NULL DEFAULT NULL COMMENT '下一次触发时间（默认为-1表示不触发）',
  `priority` int(0) NULL DEFAULT NULL COMMENT '优先级',
  `trigger_state` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器状态',
  `trigger_type` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器的类型',
  `start_time` bigint(0) NOT NULL COMMENT '开始时间',
  `end_time` bigint(0) NULL DEFAULT NULL COMMENT '结束时间',
  `calendar_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '日程表名称',
  `misfire_instr` smallint(0) NULL DEFAULT NULL COMMENT '补偿执行的策略',
  `job_data` blob NULL COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  INDEX `sched_name`(`sched_name`, `job_name`, `job_group`) USING BTREE,
  CONSTRAINT `QRTZ_TRIGGERS_ibfk_1` FOREIGN KEY (`sched_name`, `job_name`, `job_group`) REFERENCES `QRTZ_JOB_DETAILS` (`sched_name`, `job_name`, `job_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '触发器详细信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of QRTZ_TRIGGERS
-- ----------------------------

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
  `config_id` int(0) NOT NULL AUTO_INCREMENT COMMENT '参数主键',
  `config_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数名称',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数键名',
  `config_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数键值',
  `config_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '参数配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES (1, '主框架页-默认皮肤样式名称', 'sys.index.skinName', 'skin-blue', 'Y', 'admin', '2026-08-05 22:36:24', '', NULL, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow');
INSERT INTO `sys_config` VALUES (2, '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', 'admin', '2026-08-05 22:36:24', '', NULL, '初始化密码 123456');
INSERT INTO `sys_config` VALUES (3, '主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', 'Y', 'admin', '2026-08-05 22:36:24', '', NULL, '深色主题theme-dark，浅色主题theme-light');
INSERT INTO `sys_config` VALUES (4, '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'false', 'Y', 'admin', '2026-08-05 22:36:24', '', NULL, '是否开启注册用户功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES (5, '用户登录-黑名单列表', 'sys.login.blackIPList', '', 'Y', 'admin', '2026-08-05 22:36:24', '', NULL, '设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）');
INSERT INTO `sys_config` VALUES (6, '用户管理-初始密码修改策略', 'sys.account.initPasswordModify', '1', 'Y', 'admin', '2026-08-05 22:36:24', '', NULL, '0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框');
INSERT INTO `sys_config` VALUES (7, '用户管理-账号密码更新周期', 'sys.account.passwordValidateDays', '0', 'Y', 'admin', '2026-08-05 22:36:24', '', NULL, '密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框');
INSERT INTO `sys_config` VALUES (8, '用户管理-密码字符范围', 'sys.account.chrtype', '0', 'Y', 'admin', '2026-08-05 22:36:24', '', NULL, '默认任意字符范围，0任意（密码可以输入任意字符），1数字（密码只能为0-9数字），2英文字母（密码只能为a-z和A-Z字母），3字母和数字（密码必须包含字母，数字）,4字母数字和特殊字符（目前支持的特殊字符包括：~!@#$%^&*()-=_+）');

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept`  (
  `dept_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '部门id',
  `parent_id` bigint(0) NULL DEFAULT 0 COMMENT '父部门id',
  `ancestors` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '祖级列表',
  `dept_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '部门名称',
  `order_num` int(0) NULL DEFAULT 0 COMMENT '显示顺序',
  `leader` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '负责人',
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '部门状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`dept_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 200 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '部门表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dept
-- ----------------------------
INSERT INTO `sys_dept` VALUES (100, 0, '0', '小说自动化创作平台科技', 0, '小说自动化创作平台', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-08-05 22:36:23', '', NULL);
INSERT INTO `sys_dept` VALUES (101, 100, '0,100', '深圳总公司', 1, '小说自动化创作平台', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-08-05 22:36:23', '', NULL);
INSERT INTO `sys_dept` VALUES (102, 100, '0,100', '长沙分公司', 2, '小说自动化创作平台', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-08-05 22:36:23', '', NULL);
INSERT INTO `sys_dept` VALUES (103, 101, '0,100,101', '研发部门', 1, '小说自动化创作平台', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-08-05 22:36:23', '', NULL);
INSERT INTO `sys_dept` VALUES (104, 101, '0,100,101', '市场部门', 2, '小说自动化创作平台', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-08-05 22:36:23', '', NULL);
INSERT INTO `sys_dept` VALUES (105, 101, '0,100,101', '测试部门', 3, '小说自动化创作平台', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-08-05 22:36:23', '', NULL);
INSERT INTO `sys_dept` VALUES (106, 101, '0,100,101', '财务部门', 4, '小说自动化创作平台', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-08-05 22:36:23', '', NULL);
INSERT INTO `sys_dept` VALUES (107, 101, '0,100,101', '运维部门', 5, '小说自动化创作平台', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-08-05 22:36:23', '', NULL);
INSERT INTO `sys_dept` VALUES (108, 102, '0,100,102', '市场部门', 1, '小说自动化创作平台', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-08-05 22:36:23', '', NULL);
INSERT INTO `sys_dept` VALUES (109, 102, '0,100,102', '财务部门', 2, '小说自动化创作平台', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-08-05 22:36:23', '', NULL);

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data`  (
  `dict_code` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '字典编码',
  `dict_sort` int(0) NULL DEFAULT 0 COMMENT '字典排序',
  `dict_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典标签',
  `dict_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典键值',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `css_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '表格回显样式',
  `is_default` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典数据表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------
INSERT INTO `sys_dict_data` VALUES (1, 1, '男', '0', 'sys_user_sex', '', '', 'Y', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '性别男');
INSERT INTO `sys_dict_data` VALUES (2, 2, '女', '1', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '性别女');
INSERT INTO `sys_dict_data` VALUES (3, 3, '未知', '2', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '性别未知');
INSERT INTO `sys_dict_data` VALUES (4, 1, '显示', '0', 'sys_show_hide', '', 'primary', 'Y', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '显示菜单');
INSERT INTO `sys_dict_data` VALUES (5, 2, '隐藏', '1', 'sys_show_hide', '', 'danger', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '隐藏菜单');
INSERT INTO `sys_dict_data` VALUES (6, 1, '正常', '0', 'sys_normal_disable', '', 'primary', 'Y', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (7, 2, '停用', '1', 'sys_normal_disable', '', 'danger', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (8, 1, '正常', '0', 'sys_job_status', '', 'primary', 'Y', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (9, 2, '暂停', '1', 'sys_job_status', '', 'danger', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (10, 1, '默认', 'DEFAULT', 'sys_job_group', '', '', 'Y', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '默认分组');
INSERT INTO `sys_dict_data` VALUES (11, 2, '系统', 'SYSTEM', 'sys_job_group', '', '', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '系统分组');
INSERT INTO `sys_dict_data` VALUES (12, 1, '是', 'Y', 'sys_yes_no', '', 'primary', 'Y', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '系统默认是');
INSERT INTO `sys_dict_data` VALUES (13, 2, '否', 'N', 'sys_yes_no', '', 'danger', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '系统默认否');
INSERT INTO `sys_dict_data` VALUES (14, 1, '通知', '1', 'sys_notice_type', '', 'warning', 'Y', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '通知');
INSERT INTO `sys_dict_data` VALUES (15, 2, '公告', '2', 'sys_notice_type', '', 'success', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '公告');
INSERT INTO `sys_dict_data` VALUES (16, 1, '正常', '0', 'sys_notice_status', '', 'primary', 'Y', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (17, 2, '关闭', '1', 'sys_notice_status', '', 'danger', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '关闭状态');
INSERT INTO `sys_dict_data` VALUES (18, 99, '其他', '0', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '其他操作');
INSERT INTO `sys_dict_data` VALUES (19, 1, '新增', '1', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '新增操作');
INSERT INTO `sys_dict_data` VALUES (20, 2, '修改', '2', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '修改操作');
INSERT INTO `sys_dict_data` VALUES (21, 3, '删除', '3', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '删除操作');
INSERT INTO `sys_dict_data` VALUES (22, 4, '授权', '4', 'sys_oper_type', '', 'primary', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '授权操作');
INSERT INTO `sys_dict_data` VALUES (23, 5, '导出', '5', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '导出操作');
INSERT INTO `sys_dict_data` VALUES (24, 6, '导入', '6', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '导入操作');
INSERT INTO `sys_dict_data` VALUES (25, 7, '强退', '7', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '强退操作');
INSERT INTO `sys_dict_data` VALUES (26, 8, '生成代码', '8', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '生成操作');
INSERT INTO `sys_dict_data` VALUES (27, 9, '清空数据', '9', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '清空操作');
INSERT INTO `sys_dict_data` VALUES (28, 1, '成功', '0', 'sys_common_status', '', 'primary', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (29, 2, '失败', '1', 'sys_common_status', '', 'danger', 'N', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '停用状态');

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type`  (
  `dict_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '字典主键',
  `dict_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE INDEX `dict_type`(`dict_type`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO `sys_dict_type` VALUES (1, '用户性别', 'sys_user_sex', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '用户性别列表');
INSERT INTO `sys_dict_type` VALUES (2, '菜单状态', 'sys_show_hide', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '菜单状态列表');
INSERT INTO `sys_dict_type` VALUES (3, '系统开关', 'sys_normal_disable', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '系统开关列表');
INSERT INTO `sys_dict_type` VALUES (4, '任务状态', 'sys_job_status', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '任务状态列表');
INSERT INTO `sys_dict_type` VALUES (5, '任务分组', 'sys_job_group', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '任务分组列表');
INSERT INTO `sys_dict_type` VALUES (6, '系统是否', 'sys_yes_no', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '系统是否列表');
INSERT INTO `sys_dict_type` VALUES (7, '通知类型', 'sys_notice_type', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '通知类型列表');
INSERT INTO `sys_dict_type` VALUES (8, '通知状态', 'sys_notice_status', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '通知状态列表');
INSERT INTO `sys_dict_type` VALUES (9, '操作类型', 'sys_oper_type', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '操作类型列表');
INSERT INTO `sys_dict_type` VALUES (10, '系统状态', 'sys_common_status', '0', 'admin', '2026-08-05 22:36:24', '', NULL, '登录状态列表');

-- ----------------------------
-- Table structure for sys_job
-- ----------------------------
DROP TABLE IF EXISTS `sys_job`;
CREATE TABLE `sys_job`  (
  `job_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `job_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '任务名称',
  `job_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'DEFAULT' COMMENT '任务组名',
  `invoke_target` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调用目标字符串',
  `cron_expression` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'cron执行表达式',
  `misfire_policy` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '3' COMMENT '计划执行错误策略（1立即执行 2执行一次 3放弃执行）',
  `concurrent` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '是否并发执行（0允许 1禁止）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1暂停）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注信息',
  PRIMARY KEY (`job_id`, `job_name`, `job_group`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '定时任务调度表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_job
-- ----------------------------
INSERT INTO `sys_job` VALUES (1, '系统默认（无参）', 'DEFAULT', 'bookTask.bookNoParams', '0/10 * * * * ?', '3', '1', '1', 'admin', '2026-08-05 22:36:24', '', NULL, '');
INSERT INTO `sys_job` VALUES (2, '系统默认（有参）', 'DEFAULT', 'bookTask.bookParams(\'book\')', '0/15 * * * * ?', '3', '1', '1', 'admin', '2026-08-05 22:36:24', '', NULL, '');
INSERT INTO `sys_job` VALUES (3, '系统默认（多参）', 'DEFAULT', 'bookTask.bookMultipleParams(\'book\', true, 2000L, 316.50D, 100)', '0/20 * * * * ?', '3', '1', '1', 'admin', '2026-08-05 22:36:24', '', NULL, '');

-- ----------------------------
-- Table structure for sys_job_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_job_log`;
CREATE TABLE `sys_job_log`  (
  `job_log_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '任务日志ID',
  `job_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务名称',
  `job_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务组名',
  `invoke_target` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调用目标字符串',
  `job_message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '日志信息',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '执行状态（0正常 1失败）',
  `exception_info` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '异常信息',
  `start_time` datetime(0) NULL DEFAULT NULL COMMENT '执行开始时间',
  `end_time` datetime(0) NULL DEFAULT NULL COMMENT '执行结束时间',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`job_log_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '定时任务调度日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_job_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_logininfor
-- ----------------------------
DROP TABLE IF EXISTS `sys_logininfor`;
CREATE TABLE `sys_logininfor`  (
  `info_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '访问ID',
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用户账号',
  `ipaddr` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '登录IP地址',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '登录状态（0成功 1失败）',
  `msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '提示信息',
  `access_time` datetime(0) NULL DEFAULT NULL COMMENT '访问时间',
  PRIMARY KEY (`info_id`) USING BTREE,
  INDEX `idx_sys_logininfor_s`(`status`) USING BTREE,
  INDEX `idx_sys_logininfor_lt`(`access_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 103 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统访问记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_logininfor
-- ----------------------------
INSERT INTO `sys_logininfor` VALUES (100, 'admin', '127.0.0.1', '0', '登录成功', '2026-08-06 00:02:12');
INSERT INTO `sys_logininfor` VALUES (101, 'admin', '127.0.0.1', '0', '登录成功', '2026-08-06 00:02:15');
INSERT INTO `sys_logininfor` VALUES (102, 'admin', '127.0.0.1', '0', '登录成功', '2026-08-06 00:02:40');
INSERT INTO `sys_logininfor` VALUES (103, 'admin', '127.0.0.1', '0', '登录成功', '2026-08-06 23:49:29');
INSERT INTO `sys_logininfor` VALUES (104, 'admin', '127.0.0.1', '0', '登录成功', '2026-08-06 23:49:42');
INSERT INTO `sys_logininfor` VALUES (105, 'admin', '192.168.30.1', '0', '登录成功', '2026-08-07 00:16:22');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜单名称',
  `parent_id` bigint(0) NULL DEFAULT 0 COMMENT '父菜单ID',
  `order_num` int(0) NULL DEFAULT 0 COMMENT '显示顺序',
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组件路径',
  `query` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '路由参数',
  `route_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '路由名称',
  `is_frame` int(0) NULL DEFAULT 1 COMMENT '是否为外链（0是 1否）',
  `is_cache` int(0) NULL DEFAULT 0 COMMENT '是否缓存（0缓存 1不缓存）',
  `menu_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '菜单状态（0显示 1隐藏）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '菜单状态（0正常 1停用）',
  `perms` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '#' COMMENT '菜单图标',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2000 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜单权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, '系统管理', 0, 1, 'system', NULL, '', '', 1, 0, 'M', '0', '0', '', 'system', 'admin', '2026-08-05 22:36:23', '', NULL, '系统管理目录');
INSERT INTO `sys_menu` VALUES (2, '系统监控', 0, 2, 'monitor', NULL, '', '', 1, 0, 'M', '0', '0', '', 'monitor', 'admin', '2026-08-05 22:36:23', '', NULL, '系统监控目录');
INSERT INTO `sys_menu` VALUES (3, '系统工具', 0, 3, 'tool', NULL, '', '', 1, 0, 'M', '0', '0', '', 'tool', 'admin', '2026-08-05 22:36:23', '', NULL, '系统工具目录');
INSERT INTO `sys_menu` VALUES (4, '小说自动化创作平台官网', 0, 4, 'http://localhost:81/novel-platform/index.html', NULL, '', '', 0, 0, 'M', '0', '0', '', 'guide', 'admin', '2026-08-05 22:36:23', 'admin', '2026-08-06 23:59:55', '创作工作台（book-workstation，Vue3）。开发默认端口 5173；生产请改为实际部署域名。');
INSERT INTO `sys_menu` VALUES (100, '用户管理', 1, 1, 'user', 'system/user/index', '', '', 1, 0, 'C', '0', '0', 'system:user:list', 'user', 'admin', '2026-08-05 22:36:23', '', NULL, '用户管理菜单');
INSERT INTO `sys_menu` VALUES (101, '角色管理', 1, 2, 'role', 'system/role/index', '', '', 1, 0, 'C', '0', '0', 'system:role:list', 'peoples', 'admin', '2026-08-05 22:36:23', '', NULL, '角色管理菜单');
INSERT INTO `sys_menu` VALUES (102, '菜单管理', 1, 3, 'menu', 'system/menu/index', '', '', 1, 0, 'C', '0', '0', 'system:menu:list', 'tree-table', 'admin', '2026-08-05 22:36:23', '', NULL, '菜单管理菜单');
INSERT INTO `sys_menu` VALUES (103, '部门管理', 1, 4, 'dept', 'system/dept/index', '', '', 1, 0, 'C', '0', '0', 'system:dept:list', 'tree', 'admin', '2026-08-05 22:36:23', '', NULL, '部门管理菜单');
INSERT INTO `sys_menu` VALUES (104, '岗位管理', 1, 5, 'post', 'system/post/index', '', '', 1, 0, 'C', '0', '0', 'system:post:list', 'post', 'admin', '2026-08-05 22:36:23', '', NULL, '岗位管理菜单');
INSERT INTO `sys_menu` VALUES (105, '字典管理', 1, 6, 'dict', 'system/dict/index', '', '', 1, 0, 'C', '0', '0', 'system:dict:list', 'dict', 'admin', '2026-08-05 22:36:23', '', NULL, '字典管理菜单');
INSERT INTO `sys_menu` VALUES (106, '参数设置', 1, 7, 'config', 'system/config/index', '', '', 1, 0, 'C', '0', '0', 'system:config:list', 'edit', 'admin', '2026-08-05 22:36:23', '', NULL, '参数设置菜单');
INSERT INTO `sys_menu` VALUES (107, '通知公告', 1, 8, 'notice', 'system/notice/index', '', '', 1, 0, 'C', '0', '0', 'system:notice:list', 'message', 'admin', '2026-08-05 22:36:23', '', NULL, '通知公告菜单');
INSERT INTO `sys_menu` VALUES (108, '日志管理', 1, 9, 'log', '', '', '', 1, 0, 'M', '0', '0', '', 'log', 'admin', '2026-08-05 22:36:23', '', NULL, '日志管理菜单');
INSERT INTO `sys_menu` VALUES (109, '在线用户', 2, 1, 'online', 'monitor/online/index', '', '', 1, 0, 'C', '0', '0', 'monitor:online:list', 'online', 'admin', '2026-08-05 22:36:23', '', NULL, '在线用户菜单');
INSERT INTO `sys_menu` VALUES (110, '定时任务', 2, 2, 'job', 'monitor/job/index', '', '', 1, 0, 'C', '0', '0', 'monitor:job:list', 'job', 'admin', '2026-08-05 22:36:23', '', NULL, '定时任务菜单');
INSERT INTO `sys_menu` VALUES (111, 'Sentinel控制台', 2, 3, 'http://localhost:8718', '', '', '', 0, 0, 'C', '0', '0', 'monitor:sentinel:list', 'sentinel', 'admin', '2026-08-05 22:36:23', '', NULL, '流量控制菜单');
INSERT INTO `sys_menu` VALUES (112, 'Nacos控制台', 2, 4, 'http://localhost:8848/nacos', '', '', '', 0, 0, 'C', '0', '0', 'monitor:nacos:list', 'nacos', 'admin', '2026-08-05 22:36:23', '', NULL, '服务治理菜单');
INSERT INTO `sys_menu` VALUES (113, 'Admin控制台', 2, 5, 'http://localhost:9100/login', '', '', '', 0, 0, 'C', '0', '0', 'monitor:server:list', 'server', 'admin', '2026-08-05 22:36:23', '', NULL, '服务监控菜单');
INSERT INTO `sys_menu` VALUES (114, '表单构建', 3, 1, 'build', 'tool/build/index', '', '', 1, 0, 'C', '0', '0', 'tool:build:list', 'build', 'admin', '2026-08-05 22:36:23', '', NULL, '表单构建菜单');
INSERT INTO `sys_menu` VALUES (115, '代码生成', 3, 2, 'gen', 'tool/gen/index', '', '', 1, 0, 'C', '0', '0', 'tool:gen:list', 'code', 'admin', '2026-08-05 22:36:23', '', NULL, '代码生成菜单');
INSERT INTO `sys_menu` VALUES (116, '系统接口', 3, 3, 'http://localhost:8080/swagger-ui/index.html', '', '', '', 0, 0, 'C', '0', '0', 'tool:swagger:list', 'swagger', 'admin', '2026-08-05 22:36:23', '', NULL, '系统接口菜单');
INSERT INTO `sys_menu` VALUES (500, '操作日志', 108, 1, 'operlog', 'system/operlog/index', '', '', 1, 0, 'C', '0', '0', 'system:operlog:list', 'form', 'admin', '2026-08-05 22:36:23', '', NULL, '操作日志菜单');
INSERT INTO `sys_menu` VALUES (501, '登录日志', 108, 2, 'logininfor', 'system/logininfor/index', '', '', 1, 0, 'C', '0', '0', 'system:logininfor:list', 'logininfor', 'admin', '2026-08-05 22:36:23', '', NULL, '登录日志菜单');
INSERT INTO `sys_menu` VALUES (1000, '用户查询', 100, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:query', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1001, '用户新增', 100, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:add', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1002, '用户修改', 100, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:edit', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1003, '用户删除', 100, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:remove', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1004, '用户导出', 100, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:export', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1005, '用户导入', 100, 6, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:import', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1006, '重置密码', 100, 7, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:resetPwd', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1007, '角色查询', 101, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:query', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1008, '角色新增', 101, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:add', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1009, '角色修改', 101, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:edit', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1010, '角色删除', 101, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:remove', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1011, '角色导出', 101, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:export', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1012, '菜单查询', 102, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:query', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1013, '菜单新增', 102, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:add', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1014, '菜单修改', 102, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:edit', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1015, '菜单删除', 102, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:remove', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1016, '部门查询', 103, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:query', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1017, '部门新增', 103, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:add', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1018, '部门修改', 103, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:edit', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1019, '部门删除', 103, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:remove', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1020, '岗位查询', 104, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:query', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1021, '岗位新增', 104, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:add', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1022, '岗位修改', 104, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:edit', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1023, '岗位删除', 104, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:remove', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1024, '岗位导出', 104, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:export', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1025, '字典查询', 105, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:query', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1026, '字典新增', 105, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:add', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1027, '字典修改', 105, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:edit', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1028, '字典删除', 105, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:remove', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1029, '字典导出', 105, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:export', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1030, '参数查询', 106, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:query', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1031, '参数新增', 106, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:add', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1032, '参数修改', 106, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:edit', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1033, '参数删除', 106, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:remove', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1034, '参数导出', 106, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:export', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1035, '公告查询', 107, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:query', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1036, '公告新增', 107, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:add', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1037, '公告修改', 107, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:edit', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1038, '公告删除', 107, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:remove', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1039, '操作查询', 500, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:operlog:query', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1040, '操作删除', 500, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:operlog:remove', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1041, '日志导出', 500, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:operlog:export', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1042, '登录查询', 501, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:logininfor:query', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1043, '登录删除', 501, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:logininfor:remove', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1044, '日志导出', 501, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:logininfor:export', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1045, '账户解锁', 501, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:logininfor:unlock', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1046, '在线查询', 109, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:query', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1047, '批量强退', 109, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:batchLogout', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1048, '单条强退', 109, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:forceLogout', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1049, '任务查询', 110, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:query', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1050, '任务新增', 110, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:add', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1051, '任务修改', 110, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:edit', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1052, '任务删除', 110, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:remove', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1053, '状态修改', 110, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:changeStatus', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1054, '任务导出', 110, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:export', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1055, '生成查询', 115, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:query', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1056, '生成修改', 115, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:edit', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1057, '生成删除', 115, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:remove', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1058, '导入代码', 115, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:import', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1059, '预览代码', 115, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:preview', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1060, '生成代码', 115, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:code', '#', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2100, '创作项目', 0, 5, 'novel', NULL, '', '', 1, 0, 'M', '0', '0', '', 'edit', 'admin', '2026-08-07 01:32:09', '', NULL, '小说创作业务目录');
INSERT INTO `sys_menu` VALUES (2101, '项目列表', 2100, 1, 'project', 'novel/project/index', '', '', 1, 0, 'C', '0', '0', 'novel:project:list', 'list', 'admin', '2026-08-07 01:32:09', '', NULL, '创作项目菜单');
INSERT INTO `sys_menu` VALUES (2102, '项目查询', 2101, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'novel:project:query', '#', 'admin', '2026-08-07 01:32:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2103, '项目新增', 2101, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'novel:project:add', '#', 'admin', '2026-08-07 01:32:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2104, '项目修改', 2101, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'novel:project:edit', '#', 'admin', '2026-08-07 01:32:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2105, '项目删除', 2101, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'novel:project:remove', '#', 'admin', '2026-08-07 01:32:09', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2106, '项目导出', 2101, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'novel:project:export', '#', 'admin', '2026-08-07 01:32:09', '', NULL, '');

-- ----------------------------
-- Table structure for sys_notice
-- ----------------------------
DROP TABLE IF EXISTS `sys_notice`;
CREATE TABLE `sys_notice`  (
  `notice_id` int(0) NOT NULL AUTO_INCREMENT COMMENT '公告ID',
  `notice_title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告标题',
  `notice_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告类型（1通知 2公告）',
  `notice_content` longblob NULL COMMENT '公告内容',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '公告状态（0正常 1关闭）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`notice_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通知公告表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_notice
-- ----------------------------
INSERT INTO `sys_notice` VALUES (1, '温馨提醒：2018-07-01 小说自动化创作平台新版本发布啦', '2', 0xE696B0E78988E69CACE58685E5AEB9, '0', 'admin', '2026-08-05 22:36:24', '', NULL, '管理员');
INSERT INTO `sys_notice` VALUES (2, '维护通知：2018-07-01 小说自动化创作平台系统凌晨维护', '1', 0xE7BBB4E68AA4E58685E5AEB9, '0', 'admin', '2026-08-05 22:36:24', '', NULL, '管理员');
INSERT INTO `sys_notice` VALUES (3, '小说自动化创作平台开源框架介绍', '1', 0x3C703E3C7370616E207374796C653D22636F6C6F723A20726762283233302C20302C2030293B223EE9A1B9E79BAEE4BB8BE7BB8D3C2F7370616E3E3C2F703E3C703E3C666F6E7420636F6C6F723D2223333333333333223E426F6F6BE5BC80E6BA90E9A1B9E79BAEE698AFE4B8BAE4BC81E4B89AE794A8E688B7E5AE9AE588B6E79A84E5908EE58FB0E8849AE6898BE69EB6E6A186E69EB6EFBC8CE4B8BAE4BC81E4B89AE68993E980A0E79A84E4B880E7AB99E5BC8FE8A7A3E586B3E696B9E6A188EFBC8CE9998DE4BD8EE4BC81E4B89AE5BC80E58F91E68890E69CACEFBC8CE68F90E58D87E5BC80E58F91E69588E78E87E38082E4B8BBE8A681E58C85E68BACE794A8E688B7E7AEA1E79086E38081E8A792E889B2E7AEA1E79086E38081E983A8E997A8E7AEA1E79086E38081E88F9CE58D95E7AEA1E79086E38081E58F82E695B0E7AEA1E79086E38081E5AD97E585B8E7AEA1E79086E380813C2F666F6E743E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE5B297E4BD8DE7AEA1E790863C2F7370616E3E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE38081E5AE9AE697B6E4BBBBE58AA13C2F7370616E3E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE380813C2F7370616E3E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE69C8DE58AA1E79B91E68EA7E38081E799BBE5BD95E697A5E5BF97E38081E6938DE4BD9CE697A5E5BF97E38081E4BBA3E7A081E7949FE68890E7AD89E58A9FE883BDE38082E585B6E4B8ADEFBC8CE8BF98E694AFE68C81E5A49AE695B0E68DAEE6BA90E38081E695B0E68DAEE69D83E99990E38081E59BBDE99985E58C96E380815265646973E7BC93E5AD98E38081446F636B6572E983A8E7BDB2E38081E6BB91E58AA8E9AA8CE8AF81E7A081E38081E7ACACE4B889E696B9E8AEA4E8AF81E799BBE5BD95E38081E58886E5B883E5BC8FE4BA8BE58AA1E380813C2F7370616E3E3C666F6E7420636F6C6F723D2223333333333333223EE58886E5B883E5BC8FE69687E4BBB6E5AD98E582A83C2F666F6E743E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE38081E58886E5BA93E58886E8A1A8E5A484E79086E7AD89E68A80E69CAFE789B9E782B9E380823C2F7370616E3E3C2F703E3C703E3C696D67207372633D2268747470733A2F2F666F727564612E67697465652E636F6D2F696D616765732F313737333933313834383334323433393033322F61346432323331335F313831353039352E706E6722207374796C653D2277696474683A20363470783B223E3C62723E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A20726762283233302C20302C2030293B223EE5AE98E7BD91E58F8AE6BC94E7A4BA3C2F7370616E3E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE5B08FE8AFB4E887AAE58AA8E58C96E5889BE4BD9CE5B9B3E58FB0E5AE98E7BD91E59CB0E59D80EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F626F6F6B2E76697022207461726765743D225F626C616E6B223E687474703A2F2F626F6F6B2E7669703C2F613E3C6120687265663D22687474703A2F2F626F6F6B2E76697022207461726765743D225F626C616E6B223E3C2F613E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE5B08FE8AFB4E887AAE58AA8E58C96E5889BE4BD9CE5B9B3E58FB0E69687E6A1A3E59CB0E59D80EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F646F632E626F6F6B2E76697022207461726765743D225F626C616E6B223E687474703A2F2F646F632E626F6F6B2E7669703C2F613E3C62723E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE6BC94E7A4BAE59CB0E59D80E38090E4B88DE58886E7A6BBE78988E38091EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F64656D6F2E626F6F6B2E76697022207461726765743D225F626C616E6B223E687474703A2F2F64656D6F2E626F6F6B2E7669703C2F613E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE6BC94E7A4BAE59CB0E59D80E38090E58886E7A6BBE78988E69CACE38091EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F7675652E626F6F6B2E76697022207461726765743D225F626C616E6B223E687474703A2F2F7675652E626F6F6B2E7669703C2F613E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE6BC94E7A4BAE59CB0E59D80E38090E5BEAEE69C8DE58AA1E78988E38091EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F636C6F75642E626F6F6B2E76697022207461726765743D225F626C616E6B223E687474703A2F2F636C6F75642E626F6F6B2E7669703C2F613E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE6BC94E7A4BAE59CB0E59D80E38090E7A7BBE58AA8E7ABAFE78988E38091EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F68352E626F6F6B2E76697022207461726765743D225F626C616E6B223E687474703A2F2F68352E626F6F6B2E7669703C2F613E3C2F703E3C703E3C6272207374796C653D22636F6C6F723A207267622834382C2034392C203531293B20666F6E742D66616D696C793A202671756F743B48656C766574696361204E6575652671756F743B2C2048656C7665746963612C20417269616C2C2073616E732D73657269663B20666F6E742D73697A653A20313270783B223E3C2F703E, '0', 'admin', '2026-08-05 22:36:24', '', NULL, '管理员');

-- ----------------------------
-- Table structure for sys_notice_read
-- ----------------------------
DROP TABLE IF EXISTS `sys_notice_read`;
CREATE TABLE `sys_notice_read`  (
  `read_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '已读主键',
  `notice_id` int(0) NOT NULL COMMENT '公告id',
  `user_id` bigint(0) NOT NULL COMMENT '用户id',
  `read_time` datetime(0) NOT NULL COMMENT '阅读时间',
  PRIMARY KEY (`read_id`) USING BTREE,
  UNIQUE INDEX `uk_user_notice`(`user_id`, `notice_id`) USING BTREE COMMENT '同一用户同一公告只记录一次'
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '公告已读记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_notice_read
-- ----------------------------

-- ----------------------------
-- Table structure for sys_oper_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log`  (
  `oper_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '日志主键',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '模块标题',
  `business_type` int(0) NULL DEFAULT 0 COMMENT '业务类型（0其它 1新增 2修改 3删除）',
  `method` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求方式',
  `operator_type` int(0) NULL DEFAULT 0 COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作人员',
  `dept_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '部门名称',
  `oper_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求URL',
  `oper_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '主机地址',
  `oper_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作地点',
  `oper_param` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求参数',
  `json_result` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '返回参数',
  `status` int(0) NULL DEFAULT 0 COMMENT '操作状态（0正常 1异常）',
  `error_msg` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '错误消息',
  `oper_time` datetime(0) NULL DEFAULT NULL COMMENT '操作时间',
  `cost_time` bigint(0) NULL DEFAULT 0 COMMENT '消耗时间',
  PRIMARY KEY (`oper_id`) USING BTREE,
  INDEX `idx_sys_oper_log_bt`(`business_type`) USING BTREE,
  INDEX `idx_sys_oper_log_s`(`status`) USING BTREE,
  INDEX `idx_sys_oper_log_ot`(`oper_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 101 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '操作日志记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_oper_log
-- ----------------------------
INSERT INTO `sys_oper_log` VALUES (100, '菜单管理', 2, 'com.book.system.controller.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/menu', '127.0.0.1', '', '{\"children\":[],\"createTime\":\"2026-08-05 22:36:23\",\"icon\":\"guide\",\"isCache\":\"0\",\"isFrame\":\"0\",\"menuId\":4,\"menuName\":\"小说自动化创作平台官网\",\"menuType\":\"M\",\"orderNum\":4,\"params\":{},\"parentId\":0,\"path\":\"http://localhost:81/novel-platform/index.html\",\"perms\":\"\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-08-06 00:15:26', 81);
INSERT INTO `sys_oper_log` VALUES (101, '菜单管理', 2, 'com.book.system.controller.SysMenuController.edit()', 'PUT', 1, 'admin', NULL, '/menu', '127.0.0.1', '', '{\"children\":[],\"createTime\":\"2026-08-05 22:36:23\",\"icon\":\"guide\",\"isCache\":\"0\",\"isFrame\":\"0\",\"menuId\":4,\"menuName\":\"小说自动化创作平台官网\",\"menuType\":\"M\",\"orderNum\":4,\"params\":{},\"parentId\":0,\"path\":\"http://localhost:81/novel-platform/index.html\",\"perms\":\"\",\"query\":\"\",\"routeName\":\"\",\"status\":\"0\",\"updateBy\":\"admin\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-08-06 23:59:55', 50);
INSERT INTO `sys_oper_log` VALUES (102, '创作项目', 1, 'com.book.novel.controller.NovelProjectController.add()', 'POST', 1, 'admin', NULL, '/project', '192.168.30.1', '', '{\"createBy\":\"admin\",\"createTime\":\"2026-08-07 00:17:24\",\"kbRootPath\":\"D:\\\\book-kb-data\\\\1\",\"params\":{},\"projectId\":1,\"projectName\":\"短篇灵感示例\",\"remark\":\"# 短篇灵感示例（上传用）\\n\\n我是一名穿越者，落在一个「灵气复苏」刚开始的现代都市。\\n\\n核心设定：\\n- 城市地下封印松动，普通人开始觉醒异能，政府成立「异能管理局」管控。\\n- 主角林澈，普通大学生，觉醒「回溯十秒」能力，代价是每次使用后会短暂失忆。\\n- 女主苏晚，管理局新人调查员，表面冷淡，实际在追查失踪的哥哥。\\n- 反派「雾行会」想彻底撕开封印，放出上古灵兽。\\n\\n主线：林澈误触封印碎片 → 被苏晚盯上 → 两人被迫合作调查连环异能案件 → 发现雾行会真正目标是主角体内的「钥匙」。\\n\\n请按此素材生成结构化小说架构：世界观、人物小传、剧情线、伏笔清单。\\n\",\"sourceType\":\"upload\",\"status\":\"draft\",\"userId\":1} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-08-07 00:17:24', 99);
INSERT INTO `sys_oper_log` VALUES (103, 'novel architecture', 6, 'com.book.novel.controller.NovelArchitectureController.upload()', 'POST', 1, 'admin', NULL, '/project/1/upload', '192.168.30.1', '', '1 ', '{\"msg\":\"04-创作参考资料/灵感素材-示例.txt\",\"code\":200}', 0, NULL, '2026-08-07 00:17:51', 25);
INSERT INTO `sys_oper_log` VALUES (104, 'novel architecture', 0, 'com.book.novel.controller.NovelArchitectureController.parse()', 'POST', 1, 'admin', NULL, '/project/1/architecture/parse', '192.168.30.1', '', '1 ', NULL, 1, 'book-ai call failed: model chat, deepseek 调用失败：400 Bad Request on POST request for \"https://api.deepseek.com/chat/completions\": \"{\"error\":{\"message\":\"Failed to deserialize the JSON body into the target type: messages[0]: content should be a string or a list at line 1 column 68\",\"type\":\"invalid_request_error\",\"param\":null,\"code\":\"invalid_request_error\"}}\"', '2026-08-07 00:17:59', 814);
INSERT INTO `sys_oper_log` VALUES (105, 'novel architecture', 0, 'com.book.novel.controller.NovelArchitectureController.parse()', 'POST', 1, 'admin', NULL, '/project/1/architecture/parse', '192.168.30.1', '', '1 ', '{\"msg\":\"操作成功\",\"code\":200,\"data\":{\"content\":\"# 小说架构大纲：《回响之时》\\n\\n## 一、世界观设定\\n\\n### 1. 基础设定\\n- **时代背景**：现代都市（架空设定，科技水平与现实相当），灵气复苏初期\\n- **核心概念**：城市地下存在远古封印，封印松动导致灵气泄漏，部分人类觉醒异能\\n- **异能体系**：觉醒者脑域中形成「灵核」，按属性分为：\\n  - 精神系（读心、催眠、记忆操控）\\n  - 物质系（控物、元素操控）\\n  - 时空系（极稀有，回溯、预知、瞬移）\\n  - 强化系（肉体强化、五感提升）\\n- **代价设定**：所有异能使用皆有代价，如体力消耗、精神疲劳、记忆损耗等\\n\\n### 2. 势力格局\\n| 势力 | 定位 | 核心诉求 |\\n|------|------|----------|\\n| 异能管理局 | 官方管控机构 | 维持秩序，研究封印 |\\n| 雾行会 | 反派秘密结社 | 打破封印，恢复上古灵气时代 |\\n| 普通人类 | 中立民众 | 恐惧与排斥觉醒者 |\\n| 散修觉醒者 | 第三方势力 | 追求自由，不愿受管控 |\\n\\n### 3. 核心场景\\n- **临江市**：故事主要发生地，封印位于城市地下的古代祭坛遗迹\\n- **异能管理局临江分局**：女主工作场所，表面为生物科技实验室\\n- **临江大学**：男主所在学校，取景地\\n- **地下封印区**：设有三重防护结界，核心区域需要「钥匙」才能进入\\n\\n---\\n\\n## 二、主要人物小传\\n\\n### 1. 林澈（男主）\\n- **身份**：临江大学历史系大二学生，灵气复苏后觉醒异能\\n- **性格特征**：\\n  - 谨慎细致（作为历史系学生对文献有独特敏感）\\n  - 外冷内热，习惯孤身一人\\n  - 有轻微强迫症，行为习惯规律化——以避免时间线混乱\\n- **异能**：「回溯十秒」\\n  - 可将十秒内发生的事情回退重来\\n  - 代价：每次使用后丢失最近一小时的部分记忆（随机丢失），反复使用会积累记忆缺口\\n  - 限制：无法回溯超越十秒，且同一时刻只能单次回溯\\n- **隐藏身份**：封印「钥匙」的现代载体——幼年时曾被劫持进入封印核心区，体内融合了钥匙碎片\\n- **核心目标**：\\n  - 表层：生存下去，追查自己记忆越来越浑浊的真相\\n  - 深层：找出自己体内异常力量的来源\\n\\n**人物弧光**：从逃避自己能力 → 学会承担代价 → 最后主动使用能力面对命运\\n\\n### 2. 苏晚（女主）\\n- **身份**：异能管理局临江分局调查员，实战经验丰富\\n- **性格特征**：\\n  - 表面冷淡公事公办，实际极度缺乏安全感\\n  - 对线索有极强的执念，一旦锁定目标不会放弃\\n  - 心防甚重，不善表达情感\\n- **异能**：「记忆感知」——可触摸物品残留的情绪记忆片段（不完整且碎片化）\\n- **背景动机**：\\n  - 三年期，其兄苏曜（前任管理局精英）调查封印异动时失踪\\n  - 官方报告称「因公殉职」，但苏晚坚信哥哥仍活着\\n  - 私下一直在调查雾行会与该案的关联\\n- **核心目标**：\\n  - 表层：完成调查任务，寻找哥哥的下落\\n  - 深层：查明当年封印异动的真相\\n\\n**人物弧光**：从封闭自我 → 学会信任与依赖 → 放下执念找到真正的守护\\n\\n### 3. 苏曜（重要配角/失踪者）\\n- **身份**：苏晚哥哥，原异能管理局高级调查员\\n- **性格**：理想主义者，温和但坚定\\n- **异能**：「空间感知」（可探测百米内任何异常波动）\\n- **隐藏身份**：雾行会曾经的打入者，却在一处封印区接触上古灵兽意识后被「影响」，开始怀疑管理局对封印研究的态度\\n- **关键在于**：他没有死，而是被雾行会控制，成为激活封印的引导器\\n\\n### 4. 雾行会首领·「玄冥」\\n- **身份**：未露真面，仅通过幻象和声音对话\\n- **动机**：并非单纯反派，他相信封印彻底崩溃是「复原世界」的唯一途径——灵气复苏的最终形态是旧秩序重塑\\n- **异能**：不明（隐藏至后期揭示——与林澈能力来自同一力量系，为「回溯」的进阶版「重置」）\\n\\n---\\n\\n## 三、核心剧情线\\n\\n### 第一幕：觉醒·初遇（章1-8）\\n- **开场**：林澈在图书馆深夜自习，封印碎片泄露引发小范围灵气波动，他下意识触发「回溯」，却因为意外被困在回溯时间线里，错过最佳逃离时机\\n- **曝光**：异能管理局检测到异常能量波动，苏晚前来调查。林澈在危机中显露出不被记录在案的能力\\n- **冲突**：林澈被传唤至管理局，苏晚认定他为「目击者」，要', 0, NULL, '2026-08-07 00:29:30', 33015);
INSERT INTO `sys_oper_log` VALUES (106, 'novel architecture', 2, 'com.book.novel.controller.NovelArchitectureController.review()', 'POST', 1, 'admin', NULL, '/architecture/version/1/review', '192.168.30.1', '', '1 {\"comment\":\"\",\"result\":\"pass\"} ', '{\"msg\":\"操作成功\",\"code\":200,\"data\":{\"content\":\"# 小说架构大纲：《回响之时》\\n\\n## 一、世界观设定\\n\\n### 1. 基础设定\\n- **时代背景**：现代都市（架空设定，科技水平与现实相当），灵气复苏初期\\n- **核心概念**：城市地下存在远古封印，封印松动导致灵气泄漏，部分人类觉醒异能\\n- **异能体系**：觉醒者脑域中形成「灵核」，按属性分为：\\n  - 精神系（读心、催眠、记忆操控）\\n  - 物质系（控物、元素操控）\\n  - 时空系（极稀有，回溯、预知、瞬移）\\n  - 强化系（肉体强化、五感提升）\\n- **代价设定**：所有异能使用皆有代价，如体力消耗、精神疲劳、记忆损耗等\\n\\n### 2. 势力格局\\n| 势力 | 定位 | 核心诉求 |\\n|------|------|----------|\\n| 异能管理局 | 官方管控机构 | 维持秩序，研究封印 |\\n| 雾行会 | 反派秘密结社 | 打破封印，恢复上古灵气时代 |\\n| 普通人类 | 中立民众 | 恐惧与排斥觉醒者 |\\n| 散修觉醒者 | 第三方势力 | 追求自由，不愿受管控 |\\n\\n### 3. 核心场景\\n- **临江市**：故事主要发生地，封印位于城市地下的古代祭坛遗迹\\n- **异能管理局临江分局**：女主工作场所，表面为生物科技实验室\\n- **临江大学**：男主所在学校，取景地\\n- **地下封印区**：设有三重防护结界，核心区域需要「钥匙」才能进入\\n\\n---\\n\\n## 二、主要人物小传\\n\\n### 1. 林澈（男主）\\n- **身份**：临江大学历史系大二学生，灵气复苏后觉醒异能\\n- **性格特征**：\\n  - 谨慎细致（作为历史系学生对文献有独特敏感）\\n  - 外冷内热，习惯孤身一人\\n  - 有轻微强迫症，行为习惯规律化——以避免时间线混乱\\n- **异能**：「回溯十秒」\\n  - 可将十秒内发生的事情回退重来\\n  - 代价：每次使用后丢失最近一小时的部分记忆（随机丢失），反复使用会积累记忆缺口\\n  - 限制：无法回溯超越十秒，且同一时刻只能单次回溯\\n- **隐藏身份**：封印「钥匙」的现代载体——幼年时曾被劫持进入封印核心区，体内融合了钥匙碎片\\n- **核心目标**：\\n  - 表层：生存下去，追查自己记忆越来越浑浊的真相\\n  - 深层：找出自己体内异常力量的来源\\n\\n**人物弧光**：从逃避自己能力 → 学会承担代价 → 最后主动使用能力面对命运\\n\\n### 2. 苏晚（女主）\\n- **身份**：异能管理局临江分局调查员，实战经验丰富\\n- **性格特征**：\\n  - 表面冷淡公事公办，实际极度缺乏安全感\\n  - 对线索有极强的执念，一旦锁定目标不会放弃\\n  - 心防甚重，不善表达情感\\n- **异能**：「记忆感知」——可触摸物品残留的情绪记忆片段（不完整且碎片化）\\n- **背景动机**：\\n  - 三年期，其兄苏曜（前任管理局精英）调查封印异动时失踪\\n  - 官方报告称「因公殉职」，但苏晚坚信哥哥仍活着\\n  - 私下一直在调查雾行会与该案的关联\\n- **核心目标**：\\n  - 表层：完成调查任务，寻找哥哥的下落\\n  - 深层：查明当年封印异动的真相\\n\\n**人物弧光**：从封闭自我 → 学会信任与依赖 → 放下执念找到真正的守护\\n\\n### 3. 苏曜（重要配角/失踪者）\\n- **身份**：苏晚哥哥，原异能管理局高级调查员\\n- **性格**：理想主义者，温和但坚定\\n- **异能**：「空间感知」（可探测百米内任何异常波动）\\n- **隐藏身份**：雾行会曾经的打入者，却在一处封印区接触上古灵兽意识后被「影响」，开始怀疑管理局对封印研究的态度\\n- **关键在于**：他没有死，而是被雾行会控制，成为激活封印的引导器\\n\\n### 4. 雾行会首领·「玄冥」\\n- **身份**：未露真面，仅通过幻象和声音对话\\n- **动机**：并非单纯反派，他相信封印彻底崩溃是「复原世界」的唯一途径——灵气复苏的最终形态是旧秩序重塑\\n- **异能**：不明（隐藏至后期揭示——与林澈能力来自同一力量系，为「回溯」的进阶版「重置」）\\n\\n---\\n\\n## 三、核心剧情线\\n\\n### 第一幕：觉醒·初遇（章1-8）\\n- **开场**：林澈在图书馆深夜自习，封印碎片泄露引发小范围灵气波动，他下意识触发「回溯」，却因为意外被困在回溯时间线里，错过最佳逃离时机\\n- **曝光**：异能管理局检测到异常能量波动，苏晚前来调查。林澈在危机中显露出不被记录在案的能力\\n- **冲突**：林澈被传唤至管理局，苏晚认定他为「目击者」，要', 0, NULL, '2026-08-07 00:30:16', 92);
INSERT INTO `sys_oper_log` VALUES (107, 'novel chapter', 0, 'com.book.novel.controller.NovelChapterController.generate()', 'POST', 1, 'admin', NULL, '/project/1/chapter/generate', '192.168.30.1', '', '1 {\"chapterNo\":1,\"chapterTitle\":\"第一章\",\"extraInstruction\":\"带点钩子\"} ', NULL, 1, 'book-ai call failed: model chat, doubao 调用失败：404 Not Found on POST request for \"https://ark.cn-beijing.volces.com/api/v3/chat/completions\": \"{\"error\":{\"code\":\"InvalidEndpointOrModel.NotFound\",\"message\":\"The model or endpoint doubao-pro-32k does not exist or you do not have access to it. Request id: 021786033866652ab0d945beb4db31a8925a4a25f6e05d9eb4609\",\"param\":\"\",\"type\":\"Not Found\"}}\"', '2026-08-07 00:31:06', 280);
INSERT INTO `sys_oper_log` VALUES (108, 'novel chapter', 0, 'com.book.novel.controller.NovelChapterController.generate()', 'POST', 1, 'admin', NULL, '/project/1/chapter/generate', '192.168.30.1', '', '1 {\"chapterNo\":1,\"chapterTitle\":\"第一章\",\"extraInstruction\":\"添加钩子\"} ', '{\"msg\":\"操作成功\",\"code\":200,\"data\":{\"chapterId\":1,\"content\":\"## 第一章\\n\\n图书馆的冷光灯管在天花板发出细微的嗡鸣，像某种不知疲倦的节拍器。林澈揉了揉眼角，目光扫过摊开的《临江府志》残卷，在第一百三十七页停住，那里有一段模糊的记载：「……天陨而后地裂，暗河倒涌，城中井水尽数赤红，月余乃止。时人谓之‘回响之时’。」\\n\\n回响之时。\\n\\n他提笔在笔记本上写下这四个字，笔迹方正得很，像他做任何事一样规规矩矩。这是历史系二年级才有的选修课作业——地方文献中的灵异志怪与历史编码——教授说那些看似荒诞的记载背后往往藏着再真实不过的史实。但林澈选这门课的真实原因，是近半年来他脑海中那些破碎的、无法归类的声音。\\n\\n那些声音像回声，仿佛有什么东西曾在此地响起，又被命运的手指抹去了。\\n\\n他看了一眼手表，晚上十一点十一分，分毫不差。这种精确感带来的安心让他微微舒了口气——他是靠这种规律生活的。早晨七点四十三分出门，八点零六分到教室第三排靠窗的位置，晚上十点整熄灯睡觉。他需要这些锚点来稳住自己，因为记忆深处有些东西，正在以他无法控制的方式缓缓松动。\\n\\n这半年来，他开始忘记一些事。一周前忘记了自己把伞放在教室后排，昨天忘记了和同班同学约好的聚餐，今天上午，他似乎又忘记了一件……更重要的事，但他已经想不起来了。\\n\\n林澈用力握了握手中的笔，指节泛白。远处传来有什么破碎的声音，很轻，像玻璃珠落在瓷砖上。他抬起头，图书馆二楼自习区只有他一个人，门窗紧闭，角落里落着灰尘。但他清晰地感觉到地面在微微震颤，一种极低频的、连玻璃水杯里的水面都在颤动的振动。\\n\\n他的心脏漏跳了一拍。\\n\\n书页边缘有什么东西在发光——不是灯光的反射，是一种从纸张内部透出来的微光，淡蓝色的、游丝般的荧光。它们从那些古文字间渗出来，像被封存很久的东西正在苏醒。林澈站起来，椅脚刮过地面发出刺耳的响。他看见那些蓝光从书页中缓缓升起，向天花板的方向飘去，穿过书架、穿过来不及反应的他——\\n\\n在接触到他身体的一瞬间，蓝光像是遇到了什么磁石一样，猛然加速涌入他的胸腔。\\n\\n同时，他听到了一声低沉的、苍老的咆哮。那声音不是从耳朵进入的，而是直接从骨骼深处、从心脏最中央迸发出来的。巨大的痛楚让林澈膝盖一软，眼前的景象像玻璃碎裂般出现裂痕——\\n\\n他看见了另一幅画面：一座幽暗的地下祭坛，刻满符文的地面中央躺着一个婴儿，婴儿的胸口嵌着一枚发光的东西，像琉璃、又像琥珀。祭坛边缘站着穿黑衣的人，他们高举双手，口中念着听不懂的音节——\\n\\n然后画面扭曲，消融，回归图书馆的冷白灯光下。\\n\\n林澈大口喘着气，发现自己仍站在原地。不对，他刚才动了——他明明站起来朝书架方向走了两步，他看到蓝光向窗边涌去，而现在，他还站在原地，一步未迈。\\n\\n一股寒意沿着脊椎爬升。\\n\\n他想起一件事。就在蓝光接触他身体的那一瞬间，他做了一个决定——准确地说，他正确地做出了一次判断：蓝光涌来的方向危险。他应该退后，应该跑向门口。\\n\\n但他没有动。他感到自己像一个观看者的躯体傀儡，做出了后退的姿势，却没有实际行动的余地。\\n\\n不。不对。\\n\\n他的目光骤然锐利起来，紧紧盯着自己的手——桌上的笔记本，笔迹没有变形，笔帽还保持着原先的角度。他抬手摸了摸自己的领口，他记得刚才蓝光涌入时他下意识扯了一把衣领，而现在，衣领平整如初。\\n\\n空气的流动告诉他，时间，刚刚被某个人、或者某股力量，强行回拨了。\\n\\n他不知道那是多久前的事——几秒，还是更久——但他知道发生了一件不应该发生的事：他的处境被重来了一次，而这一次，他正站在蓝光涌来的必经之路上。\\n\\n同时，他发现自己的脑海中少了一段记忆。他不知道他在这次“重来”之前究竟做了什么，但他隐约感觉，那时他曾经有过一个动作，一个可以让他避开蓝光的动作。\\n\\n可现在，他不记得了。\\n\\n眼前的蓝光像是拥有了意志一样，从书页中挣脱出来，以一种仪式感的缓慢姿态旋转。那声音又响了起来——低沉苍老的咆哮——但这次它变成了一种低语，古老得像化石中鼓动的某种生命。林澈盯着那些光，听见一个念头浮现在他的意识里，清晰而冰冷：\\n\\n“你在这里。”\\n\\n他说。不，那声音说。\\n\\n他知道他必须做出选择。要么后退，要么向前。他的直觉在尖叫着让他后退，但另一个声音——一种敏锐的、清醒的自我意识——告诉他，后退已经来不及了。\\n\\n他向前迈出一步。蓝光猛然炸开，像被惊动的萤火虫群四散飞窜。他感受到地板更加剧烈的震动，远处传来自动扶梯停运的巨大声响，紧接着是一种更刺耳的声音——警报器。仿佛有什么地方检测到了这场异常，正在以某种规则系统回响。\\n\\n他转身朝门口跑去，但脚踝一痛，他被绊倒了，膝盖磕在桌腿上。他低头，看见自己的鞋带不知', 0, NULL, '2026-08-07 00:59:40', 88008);

-- ----------------------------
-- Table structure for sys_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_post`;
CREATE TABLE `sys_post`  (
  `post_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '岗位ID',
  `post_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '岗位编码',
  `post_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '岗位名称',
  `post_sort` int(0) NOT NULL COMMENT '显示顺序',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`post_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '岗位信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_post
-- ----------------------------
INSERT INTO `sys_post` VALUES (1, 'ceo', '董事长', 1, '0', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_post` VALUES (2, 'se', '项目经理', 2, '0', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_post` VALUES (3, 'hr', '人力资源', 3, '0', 'admin', '2026-08-05 22:36:23', '', NULL, '');
INSERT INTO `sys_post` VALUES (4, 'user', '普通员工', 4, '0', 'admin', '2026-08-05 22:36:23', '', NULL, '');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色权限字符串',
  `role_sort` int(0) NOT NULL COMMENT '显示顺序',
  `data_scope` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
  `menu_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '菜单树选择项是否关联显示',
  `dept_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '部门树选择项是否关联显示',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'admin', 1, '1', 1, 1, '0', '0', 'admin', '2026-08-05 22:36:23', '', NULL, '超级管理员');
INSERT INTO `sys_role` VALUES (2, '普通角色', 'common', 2, '2', 1, 1, '0', '0', 'admin', '2026-08-05 22:36:23', '', NULL, '普通角色');

-- ----------------------------
-- Table structure for sys_role_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_dept`;
CREATE TABLE `sys_role_dept`  (
  `role_id` bigint(0) NOT NULL COMMENT '角色ID',
  `dept_id` bigint(0) NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`, `dept_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色和部门关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_dept
-- ----------------------------
INSERT INTO `sys_role_dept` VALUES (2, 100);
INSERT INTO `sys_role_dept` VALUES (2, 101);
INSERT INTO `sys_role_dept` VALUES (2, 105);

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
  `role_id` bigint(0) NOT NULL COMMENT '角色ID',
  `menu_id` bigint(0) NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色和菜单关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
INSERT INTO `sys_role_menu` VALUES (1, 2100);
INSERT INTO `sys_role_menu` VALUES (1, 2101);
INSERT INTO `sys_role_menu` VALUES (1, 2102);
INSERT INTO `sys_role_menu` VALUES (1, 2103);
INSERT INTO `sys_role_menu` VALUES (1, 2104);
INSERT INTO `sys_role_menu` VALUES (1, 2105);
INSERT INTO `sys_role_menu` VALUES (1, 2106);
INSERT INTO `sys_role_menu` VALUES (2, 1);
INSERT INTO `sys_role_menu` VALUES (2, 2);
INSERT INTO `sys_role_menu` VALUES (2, 3);
INSERT INTO `sys_role_menu` VALUES (2, 4);
INSERT INTO `sys_role_menu` VALUES (2, 100);
INSERT INTO `sys_role_menu` VALUES (2, 101);
INSERT INTO `sys_role_menu` VALUES (2, 102);
INSERT INTO `sys_role_menu` VALUES (2, 103);
INSERT INTO `sys_role_menu` VALUES (2, 104);
INSERT INTO `sys_role_menu` VALUES (2, 105);
INSERT INTO `sys_role_menu` VALUES (2, 106);
INSERT INTO `sys_role_menu` VALUES (2, 107);
INSERT INTO `sys_role_menu` VALUES (2, 108);
INSERT INTO `sys_role_menu` VALUES (2, 109);
INSERT INTO `sys_role_menu` VALUES (2, 110);
INSERT INTO `sys_role_menu` VALUES (2, 111);
INSERT INTO `sys_role_menu` VALUES (2, 112);
INSERT INTO `sys_role_menu` VALUES (2, 113);
INSERT INTO `sys_role_menu` VALUES (2, 114);
INSERT INTO `sys_role_menu` VALUES (2, 115);
INSERT INTO `sys_role_menu` VALUES (2, 116);
INSERT INTO `sys_role_menu` VALUES (2, 500);
INSERT INTO `sys_role_menu` VALUES (2, 501);
INSERT INTO `sys_role_menu` VALUES (2, 1000);
INSERT INTO `sys_role_menu` VALUES (2, 1001);
INSERT INTO `sys_role_menu` VALUES (2, 1002);
INSERT INTO `sys_role_menu` VALUES (2, 1003);
INSERT INTO `sys_role_menu` VALUES (2, 1004);
INSERT INTO `sys_role_menu` VALUES (2, 1005);
INSERT INTO `sys_role_menu` VALUES (2, 1006);
INSERT INTO `sys_role_menu` VALUES (2, 1007);
INSERT INTO `sys_role_menu` VALUES (2, 1008);
INSERT INTO `sys_role_menu` VALUES (2, 1009);
INSERT INTO `sys_role_menu` VALUES (2, 1010);
INSERT INTO `sys_role_menu` VALUES (2, 1011);
INSERT INTO `sys_role_menu` VALUES (2, 1012);
INSERT INTO `sys_role_menu` VALUES (2, 1013);
INSERT INTO `sys_role_menu` VALUES (2, 1014);
INSERT INTO `sys_role_menu` VALUES (2, 1015);
INSERT INTO `sys_role_menu` VALUES (2, 1016);
INSERT INTO `sys_role_menu` VALUES (2, 1017);
INSERT INTO `sys_role_menu` VALUES (2, 1018);
INSERT INTO `sys_role_menu` VALUES (2, 1019);
INSERT INTO `sys_role_menu` VALUES (2, 1020);
INSERT INTO `sys_role_menu` VALUES (2, 1021);
INSERT INTO `sys_role_menu` VALUES (2, 1022);
INSERT INTO `sys_role_menu` VALUES (2, 1023);
INSERT INTO `sys_role_menu` VALUES (2, 1024);
INSERT INTO `sys_role_menu` VALUES (2, 1025);
INSERT INTO `sys_role_menu` VALUES (2, 1026);
INSERT INTO `sys_role_menu` VALUES (2, 1027);
INSERT INTO `sys_role_menu` VALUES (2, 1028);
INSERT INTO `sys_role_menu` VALUES (2, 1029);
INSERT INTO `sys_role_menu` VALUES (2, 1030);
INSERT INTO `sys_role_menu` VALUES (2, 1031);
INSERT INTO `sys_role_menu` VALUES (2, 1032);
INSERT INTO `sys_role_menu` VALUES (2, 1033);
INSERT INTO `sys_role_menu` VALUES (2, 1034);
INSERT INTO `sys_role_menu` VALUES (2, 1035);
INSERT INTO `sys_role_menu` VALUES (2, 1036);
INSERT INTO `sys_role_menu` VALUES (2, 1037);
INSERT INTO `sys_role_menu` VALUES (2, 1038);
INSERT INTO `sys_role_menu` VALUES (2, 1039);
INSERT INTO `sys_role_menu` VALUES (2, 1040);
INSERT INTO `sys_role_menu` VALUES (2, 1041);
INSERT INTO `sys_role_menu` VALUES (2, 1042);
INSERT INTO `sys_role_menu` VALUES (2, 1043);
INSERT INTO `sys_role_menu` VALUES (2, 1044);
INSERT INTO `sys_role_menu` VALUES (2, 1045);
INSERT INTO `sys_role_menu` VALUES (2, 1046);
INSERT INTO `sys_role_menu` VALUES (2, 1047);
INSERT INTO `sys_role_menu` VALUES (2, 1048);
INSERT INTO `sys_role_menu` VALUES (2, 1049);
INSERT INTO `sys_role_menu` VALUES (2, 1050);
INSERT INTO `sys_role_menu` VALUES (2, 1051);
INSERT INTO `sys_role_menu` VALUES (2, 1052);
INSERT INTO `sys_role_menu` VALUES (2, 1053);
INSERT INTO `sys_role_menu` VALUES (2, 1054);
INSERT INTO `sys_role_menu` VALUES (2, 1055);
INSERT INTO `sys_role_menu` VALUES (2, 1056);
INSERT INTO `sys_role_menu` VALUES (2, 1057);
INSERT INTO `sys_role_menu` VALUES (2, 1058);
INSERT INTO `sys_role_menu` VALUES (2, 1059);
INSERT INTO `sys_role_menu` VALUES (2, 1060);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `dept_id` bigint(0) NULL DEFAULT NULL COMMENT '部门ID',
  `user_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户账号',
  `nick_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户昵称',
  `user_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '00' COMMENT '用户类型（00系统用户）',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '手机号码',
  `sex` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
  `avatar` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '头像地址',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '密码',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '账号状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `login_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime(0) NULL DEFAULT NULL COMMENT '最后登录时间',
  `pwd_update_date` datetime(0) NULL DEFAULT NULL COMMENT '密码最后更新时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 103, 'admin', '小说自动化创作平台', '00', 'ry@163.com', '15888888888', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '192.168.30.1', '2026-08-06 16:16:22', '2026-08-05 22:36:23', 'admin', '2026-08-05 22:36:23', '', NULL, '管理员');
INSERT INTO `sys_user` VALUES (2, 105, 'ry', '小说自动化创作平台-ry', '00', 'ry@qq.com', '15666666666', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2026-08-05 22:36:23', '2026-08-05 22:36:23', 'admin', '2026-08-05 22:36:23', '', NULL, '测试员');

-- ----------------------------
-- Table structure for sys_user_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_post`;
CREATE TABLE `sys_user_post`  (
  `user_id` bigint(0) NOT NULL COMMENT '用户ID',
  `post_id` bigint(0) NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`, `post_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户与岗位关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_post
-- ----------------------------
INSERT INTO `sys_user_post` VALUES (1, 1);
INSERT INTO `sys_user_post` VALUES (2, 2);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `user_id` bigint(0) NOT NULL COMMENT '用户ID',
  `role_id` bigint(0) NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户和角色关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1);
INSERT INTO `sys_user_role` VALUES (2, 2);

SET FOREIGN_KEY_CHECKS = 1;
