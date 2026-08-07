package com.book.novel.mapper;

import java.util.List;
import com.book.novel.domain.NovelArchitectureVersion;

/**
 * Architecture version mapper, table novel_architecture_version.
 *
 * @author book
 */
public interface NovelArchitectureVersionMapper
{
    /**
     * Select an architecture version by id.
     */
    NovelArchitectureVersion selectVersionById(Long versionId);

    /**
     * List all versions of a project ordered by version number descending.
     */
    List<NovelArchitectureVersion> selectVersionsByProjectId(Long projectId);

    /**
     * Select the current highest version number for a project, 0 if none exists yet.
     */
    Integer selectMaxVersionNo(Long projectId);

    /**
     * Select the latest approved architecture version of a project, or null if none.
     */
    NovelArchitectureVersion selectLatestApprovedByProjectId(Long projectId);

    /**
     * Insert a new architecture version.
     */
    int insertVersion(NovelArchitectureVersion version);

    /**
     * Update an architecture version (content edit and/or review status change).
     */
    int updateVersion(NovelArchitectureVersion version);
}
