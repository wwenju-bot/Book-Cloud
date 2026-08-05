package com.book.novel.kb;

import java.io.File;
import java.util.List;

/**
 * Knowledge base file system storage abstraction. v1 only ships one implementation,
 * {@link LocalFileSystemStorage}. To add MinIO later, just add a new implementation and
 * switch book.novel.kb.storage-type; business code does not need to change.
 *
 * @author book
 */
public interface KnowledgeBaseStorage
{
    /**
     * Initialize a project's knowledge base directory layout (00~05 six top-level dirs +
     * 00-project-config/project.json).
     *
     * @param projectId project id
     * @param projectName project name, written into project.json metadata
     */
    void initProjectLayout(Long projectId, String projectName);

    /**
     * Write (or overwrite) a Markdown (or other text) file.
     *
     * @param projectId project id
     * @param relativePath path relative to the project root, e.g. "01-architecture/v1.md"
     * @param content file content
     */
    void writeMarkdown(Long projectId, String relativePath, String content);

    /**
     * Write an arbitrary binary file (used for user-uploaded raw manuscripts / reference
     * material such as docx/pdf that are not plain text).
     *
     * @param projectId project id
     * @param relativePath path relative to the project root, e.g. "04-reference/material.docx"
     * @param content raw file bytes
     */
    void writeFile(Long projectId, String relativePath, byte[] content);

    /**
     * Read a text file's content.
     *
     * @param projectId project id
     * @param relativePath path relative to the project root
     * @return file content
     */
    String readMarkdown(Long projectId, String relativePath);

    /**
     * List file names directly under a sub-directory (non-recursive).
     *
     * @param projectId project id
     * @param relativeDir sub-directory path relative to the project root, e.g. "02-chapters"
     * @return file name list, empty list if the directory does not exist
     */
    List<String> listFiles(Long projectId, String relativeDir);

    /**
     * Package the whole project knowledge base directory as a zip file.
     *
     * @param projectId project id
     * @return the packaged temp zip file; caller is responsible for deleting it afterwards
     */
    File packageAsZip(Long projectId);

    /**
     * Get the absolute path of the project's knowledge base root directory, used to persist
     * novel_project.kb_root_path.
     *
     * @param projectId project id
     * @return absolute path
     */
    String getProjectRootPath(Long projectId);
}
