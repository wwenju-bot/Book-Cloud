package com.book.novel.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import com.book.common.core.web.controller.BaseController;
import com.book.common.core.web.domain.AjaxResult;
import com.book.common.log.annotation.Log;
import com.book.common.log.enums.BusinessType;
import com.book.common.security.annotation.RequiresPermissions;
import com.book.novel.domain.ArchitectureReviewRequest;
import com.book.novel.domain.ChapterGenerateRequest;
import com.book.novel.domain.NovelChapter;
import com.book.novel.domain.NovelChapterVersion;
import com.book.novel.service.INovelChapterService;

/**
 * Chapter generation and query endpoints (phase 1 synchronous Doubao generation).
 *
 * @author book
 */
@RestController
public class NovelChapterController extends BaseController
{
    @Autowired
    private INovelChapterService chapterService;

    /**
     * Generate a chapter via Doubao using the approved current architecture as context.
     */
    @RequiresPermissions("novel:project:edit")
    @Log(title = "novel chapter", businessType = BusinessType.OTHER)
    @PostMapping("/project/{projectId}/chapter/generate")
    public AjaxResult generate(@PathVariable Long projectId, @Validated @RequestBody ChapterGenerateRequest request)
    {
        return AjaxResult.success("操作成功", chapterService.submitGenerateChapter(projectId, request));
    }

    /**
     * List chapters of a project.
     */
    @RequiresPermissions("novel:project:query")
    @GetMapping("/project/{projectId}/chapter/list")
    public AjaxResult list(@PathVariable Long projectId)
    {
        List<NovelChapter> list = chapterService.selectChaptersByProjectId(projectId);
        return success(list);
    }

    /**
     * List all versions of a chapter.
     */
    @RequiresPermissions("novel:project:query")
    @GetMapping("/chapter/{chapterId}/versions")
    public AjaxResult versions(@PathVariable Long chapterId)
    {
        List<NovelChapterVersion> list = chapterService.selectVersionsByChapterId(chapterId);
        return success(list);
    }

    /**
     * Review a chapter version: body { result: pass|reject, comment }.
     */
    @RequiresPermissions("novel:project:edit")
    @Log(title = "novel chapter", businessType = BusinessType.UPDATE)
    @PostMapping("/chapter/version/{versionId}/review")
    public AjaxResult review(@PathVariable Long versionId, @RequestBody ArchitectureReviewRequest request)
    {
        return success(chapterService.reviewVersion(versionId, request));
    }

    /**
     * Promote a multi-model candidate as latest_version_id.
     */
    @RequiresPermissions("novel:project:edit")
    @Log(title = "novel chapter", businessType = BusinessType.UPDATE)
    @PostMapping("/chapter/version/{versionId}/promote")
    public AjaxResult promote(@PathVariable Long versionId)
    {
        return success(chapterService.promoteVersion(versionId));
    }
}
