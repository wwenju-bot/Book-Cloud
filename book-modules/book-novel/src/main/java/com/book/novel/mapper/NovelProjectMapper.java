package com.book.novel.mapper;

import java.util.List;
import com.book.novel.domain.NovelProject;

/**
 * 创作项目 数据层
 *
 * @author book
 */
public interface NovelProjectMapper
{
    /**
     * 查询创作项目集合
     *
     * @param project 查询条件
     * @return 项目集合
     */
    List<NovelProject> selectProjectList(NovelProject project);

    /**
     * 通过项目ID查询项目信息
     *
     * @param projectId 项目ID
     * @return 项目信息
     */
    NovelProject selectProjectById(Long projectId);

    /**
     * 新增项目
     *
     * @param project 项目信息
     * @return 结果
     */
    int insertProject(NovelProject project);

    /**
     * 修改项目
     *
     * @param project 项目信息
     * @return 结果
     */
    int updateProject(NovelProject project);

    /**
     * 删除项目
     *
     * @param projectId 项目ID
     * @return 结果
     */
    int deleteProjectById(Long projectId);

    /**
     * 批量删除项目
     *
     * @param projectIds 需要删除的项目ID
     * @return 结果
     */
    int deleteProjectByIds(Long[] projectIds);
}
