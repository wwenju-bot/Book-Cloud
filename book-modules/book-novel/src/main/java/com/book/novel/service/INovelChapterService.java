package com.book.novel.service;

import java.util.List;
import com.book.novel.domain.ArchitectureReviewRequest;
import com.book.novel.domain.ChapterGenerateRequest;
import com.book.novel.domain.NovelChapter;
import com.book.novel.domain.NovelChapterVersion;

/**
 * Chapter generation and query service.
 *
 * @author book
 */
public interface INovelChapterService
{
    /**
     * Submit async multi-model chapter generation; returns taskId immediately.
     */
    Long submitGenerateChapter(Long projectId, ChapterGenerateRequest request);

    /**
     * List chapters of a project ordered by chapter number.
     */
    List<NovelChapter> selectChaptersByProjectId(Long projectId);

    /**
     * List all versions of a chapter, newest / highest score first.
     */
    List<NovelChapterVersion> selectVersionsByChapterId(Long chapterId);

    /**
     * Promote a candidate as the chapter's latest (formal) version before/without review pass.
     */
    NovelChapterVersion promoteVersion(Long versionId);

    /**
     * Review a chapter version (pass / reject). On pass, refreshes 02-章节内容 formal file.
     */
    NovelChapterVersion reviewVersion(Long versionId, ArchitectureReviewRequest request);
}
