package com.book.novel.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import com.book.common.core.web.controller.BaseController;
import com.book.common.core.web.domain.AjaxResult;
import com.book.common.log.annotation.Log;
import com.book.common.log.enums.BusinessType;
import com.book.common.security.annotation.RequiresPermissions;
import com.book.novel.domain.NovelArchitectureVersion;
import com.book.novel.service.INovelArchitectureService;

/**
 * Reference material upload and architecture (outline) parsing endpoints.
 *
 * @author book
 */
@RestController
public class NovelArchitectureController extends BaseController
{
    @Autowired
    private INovelArchitectureService architectureService;

    /**
     * Upload a reference material / manuscript file into the project's knowledge base.
     */
    @RequiresPermissions("novel:project:edit")
    @Log(title = "novel architecture", businessType = BusinessType.IMPORT)
    @PostMapping("/project/{projectId}/upload")
    public AjaxResult upload(@PathVariable Long projectId, @RequestParam("file") MultipartFile file)
    {
        return success(architectureService.uploadMaterial(projectId, file));
    }

    /**
     * Parse the uploaded reference material into a structured architecture outline via
     * DeepSeek (synchronous call in phase 1).
     */
    @RequiresPermissions("novel:project:edit")
    @Log(title = "novel architecture", businessType = BusinessType.OTHER)
    @PostMapping("/project/{projectId}/architecture/parse")
    public AjaxResult parse(@PathVariable Long projectId)
    {
        return success(architectureService.parseArchitecture(projectId));
    }

    /**
     * List all architecture versions of a project.
     */
    @RequiresPermissions("novel:project:query")
    @GetMapping("/project/{projectId}/architecture/versions")
    public AjaxResult versions(@PathVariable Long projectId)
    {
        List<NovelArchitectureVersion> list = architectureService.selectVersionsByProjectId(projectId);
        return success(list);
    }

    /**
     * Get a single architecture version.
     */
    @RequiresPermissions("novel:project:query")
    @GetMapping("/architecture/version/{versionId}")
    public AjaxResult getVersion(@PathVariable Long versionId)
    {
        return success(architectureService.selectVersionById(versionId));
    }
}
