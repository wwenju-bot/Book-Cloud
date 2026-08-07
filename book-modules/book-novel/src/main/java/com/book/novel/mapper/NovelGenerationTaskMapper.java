package com.book.novel.mapper;

import com.book.novel.domain.NovelGenerationTask;

/**
 * Generation task mapper, table novel_generation_task.
 *
 * @author book
 */
public interface NovelGenerationTaskMapper
{
    NovelGenerationTask selectTaskById(Long taskId);

    int insertTask(NovelGenerationTask task);

    int updateTask(NovelGenerationTask task);
}
