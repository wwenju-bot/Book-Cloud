package com.book.novel.service;

import java.util.List;
import org.springframework.web.multipart.MultipartFile;
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
     * Parse all reference material under 04-reference-material/ into a structured
     * architecture outline via DeepSeek, write it to the knowledge base and insert a new
     * novel_architecture_version record (synchronous call in phase 1, see AGENTS.md).
     *
     * @param projectId project id
     * @return the newly created architecture version
     */
    NovelArchitectureVersion parseArchitecture(Long projectId);

    /**
     * Get an architecture version by id (ownership checked against the current user).
     */
    NovelArchitectureVersion selectVersionById(Long versionId);

    /**
     * List all architecture versions of a project, newest first.
     */
    List<NovelArchitectureVersion> selectVersionsByProjectId(Long projectId);
}
