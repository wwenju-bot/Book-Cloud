package com.book.novel.controller;

import java.io.File;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.List;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.book.common.core.utils.DateUtils;
import com.book.common.core.web.controller.BaseController;
import com.book.common.core.web.domain.AjaxResult;
import com.book.common.core.web.page.TableDataInfo;
import com.book.common.log.annotation.Log;
import com.book.common.log.enums.BusinessType;
import com.book.common.security.annotation.RequiresPermissions;
import com.book.novel.domain.NovelProject;
import com.book.novel.service.INovelProjectService;

/**
 * 创作项目操作处理
 *
 * @author book
 */
@RestController
@RequestMapping("/project")
public class NovelProjectController extends BaseController
{
    @Autowired
    private INovelProjectService projectService;

    /**
     * 查询创作项目列表（非管理员只返回自己的项目）
     */
    @RequiresPermissions("novel:project:list")
    @GetMapping("/list")
    public TableDataInfo list(NovelProject project)
    {
        startPage();
        List<NovelProject> list = projectService.selectProjectList(project);
        return getDataTable(list);
    }

    /**
     * 获取创作项目详细信息
     */
    @RequiresPermissions("novel:project:query")
    @GetMapping("/{projectId}")
    public AjaxResult getInfo(@PathVariable Long projectId)
    {
        return success(projectService.selectProjectById(projectId));
    }

    /**
     * 新增创作项目：落库后自动初始化 00~05 知识库目录模板
     */
    @RequiresPermissions("novel:project:add")
    @Log(title = "创作项目", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@Validated @RequestBody NovelProject project)
    {
        return toAjax(projectService.insertProject(project));
    }

    /**
     * 修改创作项目
     */
    @RequiresPermissions("novel:project:edit")
    @Log(title = "创作项目", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@Validated @RequestBody NovelProject project)
    {
        return toAjax(projectService.updateProject(project));
    }

    /**
     * 批量删除创作项目
     */
    @RequiresPermissions("novel:project:remove")
    @Log(title = "创作项目", businessType = BusinessType.DELETE)
    @DeleteMapping("/{projectIds}")
    public AjaxResult remove(@PathVariable Long[] projectIds)
    {
        return toAjax(projectService.deleteProjectByIds(projectIds));
    }

    /**
     * 导出项目知识库目录为 zip 包下载
     */
    @RequiresPermissions("novel:project:export")
    @Log(title = "创作项目", businessType = BusinessType.EXPORT)
    @GetMapping("/{projectId}/export")
    public void export(HttpServletResponse response, @PathVariable Long projectId,
            @RequestParam(value = "approvedOnly", defaultValue = "false") boolean approvedOnly) throws Exception
    {
        NovelProject project = projectService.selectProjectById(projectId);
        File zipFile = projectService.exportProject(projectId, approvedOnly);
        try
        {
            String fileName = URLEncoder.encode(
                    project.getProjectName() + "-" + DateUtils.dateTime() + ".zip", StandardCharsets.UTF_8);
            response.setContentType("application/octet-stream");
            response.setHeader("Content-Disposition", "attachment; filename=" + fileName);
            response.setContentLengthLong(zipFile.length());
            Files.copy(zipFile.toPath(), response.getOutputStream());
            response.getOutputStream().flush();
        }
        finally
        {
            Files.deleteIfExists(zipFile.toPath());
        }
    }
}
