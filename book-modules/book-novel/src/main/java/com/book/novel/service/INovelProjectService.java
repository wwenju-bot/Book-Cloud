package com.book.novel.service;

import java.io.File;
import java.util.List;
import com.book.novel.domain.NovelProject;

/**
 * 创作项目 服务层
 *
 * @author book
 */
public interface INovelProjectService
{
    /**
     * 查询创作项目集合（非管理员只能看到自己的项目）
     *
     * @param project 查询条件
     * @return 项目集合
     */
    List<NovelProject> selectProjectList(NovelProject project);

    /**
     * 通过项目ID查询项目信息（非管理员只能查看自己的项目）
     *
     * @param projectId 项目ID
     * @return 项目信息
     */
    NovelProject selectProjectById(Long projectId);

    /**
     * 新增项目：落库后自动初始化知识库目录模板
     *
     * @param project 项目信息
     * @return 结果
     */
    int insertProject(NovelProject project);

    /**
     * 修改项目（非管理员只能修改自己的项目）
     *
     * @param project 项目信息
     * @return 结果
     */
    int updateProject(NovelProject project);

    /**
     * 批量删除项目（非管理员只能删除自己的项目）
     *
     * @param projectIds 需要删除的项目ID
     * @return 结果
     */
    int deleteProjectByIds(Long[] projectIds);

    /**
     * 打包导出项目知识库目录（非管理员只能导出自己的项目）
     *
     * @param projectId 项目ID
     * @return 打包后的临时 zip 文件
     */
    File exportProject(Long projectId);
}
