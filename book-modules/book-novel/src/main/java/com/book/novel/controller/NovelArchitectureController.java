package com.book.novel.controller;

import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import com.book.common.core.web.controller.BaseController;
import com.book.common.core.web.domain.AjaxResult;
import com.book.common.log.annotation.Log;
import com.book.common.log.enums.BusinessType;
import com.book.common.security.annotation.RequiresPermissions;
import com.book.novel.domain.ArchitectureReviewRequest;
import com.book.novel.domain.NovelArchitectureVersion;
import com.book.novel.service.INovelArchitectureService;

/**
 * Reference material upload and architecture (outline) parsing / review endpoints.
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
        // Must use (msg, data): success(String) would put the path into msg and leave data null.
        return AjaxResult.success("操作成功", architectureService.uploadMaterial(projectId, file));
    }

    /**
     * List reference materials already stored in the project's knowledge base.
     */
    @RequiresPermissions("novel:project:query")
    @GetMapping("/project/{projectId}/materials")
    public AjaxResult listMaterials(@PathVariable Long projectId)
    {
        return success(architectureService.listMaterials(projectId));
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
        return AjaxResult.success("操作成功", architectureService.submitParseArchitecture(projectId));
    }

    /**
     * Optimize an architecture version via Doubao (async, returns taskId).
     */
    @RequiresPermissions("novel:project:edit")
    @Log(title = "novel architecture", businessType = BusinessType.OTHER)
    @PostMapping("/architecture/version/{versionId}/optimize")
    public AjaxResult optimize(@PathVariable Long versionId)
    {
        return AjaxResult.success("操作成功", architectureService.submitOptimizeArchitecture(versionId));
    }

    /**
     * Diff two architecture versions: compareTo is the baseline (left).
     */
    @RequiresPermissions("novel:project:query")
    @GetMapping("/architecture/version/{versionId}/diff")
    public AjaxResult diff(@PathVariable Long versionId, @RequestParam("compareTo") Long compareTo)
    {
        return success(architectureService.diffVersions(versionId, compareTo));
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

    /**
     * Manually edit architecture version content.
     */
    @RequiresPermissions("novel:project:edit")
    @Log(title = "novel architecture", businessType = BusinessType.UPDATE)
    @PutMapping("/architecture/version/{versionId}")
    public AjaxResult edit(@PathVariable Long versionId, @RequestBody Map<String, Object> body)
    {
        Object content = body == null ? null : body.get("content");
        return success(architectureService.updateVersionContent(versionId,
                content == null ? null : content.toString()));
    }

    /**
     * Review an architecture version: body { result: pass|reject, comment }.
     */
    @RequiresPermissions("novel:project:edit")
    @Log(title = "novel architecture", businessType = BusinessType.UPDATE)
    @PostMapping("/architecture/version/{versionId}/review")
    public AjaxResult review(@PathVariable Long versionId, @RequestBody ArchitectureReviewRequest request)
    {
        return success(architectureService.reviewVersion(versionId, request));
    }
}
