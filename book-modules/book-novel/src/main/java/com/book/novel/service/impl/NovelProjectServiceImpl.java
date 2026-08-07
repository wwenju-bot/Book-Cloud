package com.book.novel.service.impl;

import java.io.File;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.book.common.core.exception.ServiceException;
import com.book.common.core.utils.DateUtils;
import com.book.common.core.utils.StringUtils;
import com.book.common.security.utils.SecurityUtils;
import com.book.novel.domain.NovelProject;
import com.book.novel.kb.KbOperationLogger;
import com.book.novel.kb.KnowledgeBaseStorage;
import com.book.novel.mapper.NovelProjectMapper;
import com.book.novel.service.INovelProjectService;

/**
 * 创作项目 服务层处理
 *
 * @author book
 */
@Service
public class NovelProjectServiceImpl implements INovelProjectService
{
    @Autowired
    private NovelProjectMapper projectMapper;

    @Autowired
    private KnowledgeBaseStorage knowledgeBaseStorage;

    @Autowired
    private KbOperationLogger kbOperationLogger;

    @Override
    public List<NovelProject> selectProjectList(NovelProject project)
    {
        if (!SecurityUtils.isAdmin())
        {
            project.setUserId(SecurityUtils.getUserId());
        }
        return projectMapper.selectProjectList(project);
    }

    @Override
    public NovelProject selectProjectById(Long projectId)
    {
        NovelProject project = selectExistingById(projectId);
        checkOwnership(project);
        return project;
    }

    /**
     * 新增项目：先落库拿到自增ID，再以该ID为目录名初始化知识库目录模板，
     * 最后把知识库根路径回写到 kb_root_path，全程失败即抛异常回滚（新增+目录初始化视为一个整体操作）
     */
    @Override
    @Transactional
    public int insertProject(NovelProject project)
    {
        project.setUserId(SecurityUtils.getUserId());
        if (!StringUtils.hasText(project.getSourceType()))
        {
            project.setSourceType(NovelProject.SOURCE_TYPE_INSPIRATION);
        }
        project.setStatus(NovelProject.STATUS_DRAFT);
        project.setCreateBy(SecurityUtils.getUsername());
        project.setCreateTime(DateUtils.getNowDate());

        int rows = projectMapper.insertProject(project);
        if (rows > 0 && project.getProjectId() != null)
        {
            knowledgeBaseStorage.initProjectLayout(project.getProjectId(), project.getProjectName());

            NovelProject update = new NovelProject();
            update.setProjectId(project.getProjectId());
            update.setKbRootPath(knowledgeBaseStorage.getProjectRootPath(project.getProjectId()));
            projectMapper.updateProject(update);
            project.setKbRootPath(update.getKbRootPath());
        }
        return rows;
    }

    @Override
    public int updateProject(NovelProject project)
    {
        checkOwnership(selectExistingById(project.getProjectId()));
        project.setUpdateBy(SecurityUtils.getUsername());
        project.setUpdateTime(DateUtils.getNowDate());
        return projectMapper.updateProject(project);
    }

    @Override
    public int deleteProjectByIds(Long[] projectIds)
    {
        for (Long projectId : projectIds)
        {
            checkOwnership(selectExistingById(projectId));
        }
        return projectMapper.deleteProjectByIds(projectIds);
    }

    @Override
    public File exportProject(Long projectId)
    {
        return exportProject(projectId, false);
    }

    @Override
    public File exportProject(Long projectId, boolean approvedOnly)
    {
        checkOwnership(selectExistingById(projectId));
        File zip = knowledgeBaseStorage.packageAsZip(projectId, approvedOnly);
        kbOperationLogger.log(projectId, "export", "approvedOnly=" + approvedOnly);
        return zip;
    }

    private NovelProject selectExistingById(Long projectId)
    {
        NovelProject project = projectMapper.selectProjectById(projectId);
        if (project == null)
        {
            throw new ServiceException("项目不存在，projectId=" + projectId);
        }
        return project;
    }

    private void checkOwnership(NovelProject project)
    {
        if (!SecurityUtils.isAdmin() && !project.getUserId().equals(SecurityUtils.getUserId()))
        {
            throw new ServiceException("无权限操作该项目");
        }
    }
}
