package com.book.novel.kb;

import java.io.File;
import java.util.List;

/**
 * 知识库文件系统存储抽象。v1 只有 {@link LocalFileSystemStorage} 一个实现，
 * 后续要接 MinIO 存储，只需新增一个实现类并调整 book.novel.kb.storage-type 配置，业务代码不用改。
 *
 * @author book
 */
public interface KnowledgeBaseStorage
{
    /**
     * 初始化项目知识库目录模板（00~05 六大目录 + 00-项目配置/project.json）
     *
     * @param projectId 项目ID
     * @param projectName 项目名称，写入 project.json 元数据
     */
    void initProjectLayout(Long projectId, String projectName);

    /**
     * 写入/覆盖一个 Markdown（或其他文本）文件
     *
     * @param projectId 项目ID
     * @param relativePath 相对项目根目录的路径，如 "01-全局架构/v1-架构.md"
     * @param content 文件内容
     */
    void writeMarkdown(Long projectId, String relativePath, String content);

    /**
     * 读取一个文件内容
     *
     * @param projectId 项目ID
     * @param relativePath 相对项目根目录的路径
     * @return 文件内容
     */
    String readMarkdown(Long projectId, String relativePath);

    /**
     * 列出某个子目录下的文件名（不递归）
     *
     * @param projectId 项目ID
     * @param relativeDir 相对项目根目录的子目录路径，如 "02-章节内容"
     * @return 文件名列表，目录不存在时返回空列表
     */
    List<String> listFiles(Long projectId, String relativeDir);

    /**
     * 将整个项目知识库目录打包为 zip
     *
     * @param projectId 项目ID
     * @return 打包后的临时 zip 文件，调用方负责用完后删除
     */
    File packageAsZip(Long projectId);

    /**
     * 获取项目知识库根目录的绝对路径，用于落库到 novel_project.kb_root_path
     *
     * @param projectId 项目ID
     * @return 绝对路径
     */
    String getProjectRootPath(Long projectId);
}
