package com.book.novel.service;

import com.book.novel.domain.NovelGenerationTask;

/**
 * Async generation task service.
 *
 * @author book
 */
public interface INovelGenerationTaskService
{
    NovelGenerationTask createPendingTask(Long projectId, String taskType, String inputParamsJson);

    void markRunning(Long taskId, int progress);

    void updateProgress(Long taskId, int progress);

    void markSuccess(Long taskId, String resultRef);

    void markFailed(Long taskId, String errorMsg);

    NovelGenerationTask selectTaskById(Long taskId);

    /**
     * Submit runnable to novelTaskExecutor after creating a pending task.
     *
     * @return taskId
     */
    Long submit(Long projectId, String taskType, String inputParamsJson, Runnable work);
}
