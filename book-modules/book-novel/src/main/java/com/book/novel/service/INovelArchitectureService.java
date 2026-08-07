package com.book.novel.service;

import java.util.List;
import org.springframework.web.multipart.MultipartFile;
import com.book.novel.domain.ArchitectureDiffResult;
import com.book.novel.domain.ArchitectureReviewRequest;
import com.book.novel.domain.NovelArchitectureVersion;

/**
 * Architecture (outline) service: reference material upload + DeepSeek parsing into a
 * structured architecture outline, versioned and stored in the knowledge base.
 *
 * @author book
 */
public interface INovelArchitectureService
{
    /**
     * Upload a reference material / manuscript file into 04-reference-material/ of the
     * project's knowledge base (ownership checked against the current user).
     *
     * @param projectId project id
     * @param file uploaded file
     * @return knowledge base relative path the file was stored at
     */
    String uploadMaterial(Long projectId, MultipartFile file);

    /**
     * List reference material file names under 04-创作参考资料/ for the project.
     *
     * @param projectId project id
     * @return file names (not full paths), sorted
     */
    List<String> listMaterials(Long projectId);

    /**
     * Submit async architecture parse; returns taskId immediately.
     */
    Long submitParseArchitecture(Long projectId);

    /**
     * Submit async architecture optimize from a version; returns taskId.
     */
    Long submitOptimizeArchitecture(Long versionId);

    /**
     * Line-level diff between two architecture versions.
     */
    ArchitectureDiffResult diffVersions(Long versionId, Long compareToId);

    /**
     * Get an architecture version by id (ownership checked against the current user).
     */
    NovelArchitectureVersion selectVersionById(Long versionId);

    /**
     * List all architecture versions of a project, newest first.
     */
    List<NovelArchitectureVersion> selectVersionsByProjectId(Long projectId);

    /**
     * Manually edit architecture version content; syncs the knowledge base Markdown file
     * and resets review_status to pending.
     */
    NovelArchitectureVersion updateVersionContent(Long versionId, String content);

    /**
     * Review an architecture version (pass / reject). On pass, refreshes 当前架构.md.
     */
    NovelArchitectureVersion reviewVersion(Long versionId, ArchitectureReviewRequest request);
}
