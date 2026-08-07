package com.book.novel.service.impl;

import java.util.Date;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.stereotype.Service;
import com.book.common.core.exception.ServiceException;
import com.book.common.security.utils.SecurityUtils;
import com.book.novel.domain.NovelGenerationTask;
import com.book.novel.mapper.NovelGenerationTaskMapper;
import com.book.novel.service.INovelGenerationTaskService;
import com.book.novel.service.INovelProjectService;

/**
 * Async generation task service implementation.
 *
 * @author book
 */
@Service
public class NovelGenerationTaskServiceImpl implements INovelGenerationTaskService
{
    private static final Logger log = LoggerFactory.getLogger(NovelGenerationTaskServiceImpl.class);

    @Autowired
    private NovelGenerationTaskMapper taskMapper;

    @Autowired
    private INovelProjectService projectService;

    @Autowired
    @Qualifier("novelTaskExecutor")
    private ThreadPoolTaskExecutor novelTaskExecutor;

    @Override
    public NovelGenerationTask createPendingTask(Long projectId, String taskType, String inputParamsJson)
    {
        projectService.selectProjectById(projectId);
        NovelGenerationTask task = new NovelGenerationTask();
        task.setProjectId(projectId);
        task.setTaskType(taskType);
        task.setStatus(NovelGenerationTask.STATUS_PENDING);
        task.setProgress(0);
        task.setInputParams(inputParamsJson);
        task.setCreateBy(SecurityUtils.getUsername());
        taskMapper.insertTask(task);
        return task;
    }

    @Override
    public void markRunning(Long taskId, int progress)
    {
        NovelGenerationTask update = new NovelGenerationTask();
        update.setTaskId(taskId);
        update.setStatus(NovelGenerationTask.STATUS_RUNNING);
        update.setProgress(progress);
        update.setStartTime(new Date());
        taskMapper.updateTask(update);
    }

    @Override
    public void updateProgress(Long taskId, int progress)
    {
        NovelGenerationTask update = new NovelGenerationTask();
        update.setTaskId(taskId);
        update.setProgress(progress);
        taskMapper.updateTask(update);
    }

    @Override
    public void markSuccess(Long taskId, String resultRef)
    {
        NovelGenerationTask update = new NovelGenerationTask();
        update.setTaskId(taskId);
        update.setStatus(NovelGenerationTask.STATUS_SUCCESS);
        update.setProgress(100);
        update.setResultRef(resultRef);
        update.setFinishTime(new Date());
        taskMapper.updateTask(update);
    }

    @Override
    public void markFailed(Long taskId, String errorMsg)
    {
        NovelGenerationTask update = new NovelGenerationTask();
        update.setTaskId(taskId);
        update.setStatus(NovelGenerationTask.STATUS_FAILED);
        update.setErrorMsg(errorMsg == null ? "" : (errorMsg.length() > 900 ? errorMsg.substring(0, 900) : errorMsg));
        update.setFinishTime(new Date());
        taskMapper.updateTask(update);
    }

    @Override
    public NovelGenerationTask selectTaskById(Long taskId)
    {
        NovelGenerationTask task = taskMapper.selectTaskById(taskId);
        if (task == null)
        {
            throw new ServiceException("task not found, taskId=" + taskId);
        }
        projectService.selectProjectById(task.getProjectId());
        return task;
    }

    @Override
    public Long submit(Long projectId, String taskType, String inputParamsJson, Runnable work)
    {
        NovelGenerationTask task = createPendingTask(projectId, taskType, inputParamsJson);
        Long taskId = task.getTaskId();
        novelTaskExecutor.execute(() -> {
            try
            {
                com.book.novel.service.impl.NovelArchitectureServiceImpl.CURRENT_TASK_ID.set(taskId);
                com.book.novel.service.impl.NovelChapterServiceImpl.CURRENT_TASK_ID.set(taskId);
                markRunning(taskId, 5);
                work.run();
            }
            catch (Exception e)
            {
                log.error("novel task failed, taskId={}, type={}", taskId, taskType, e);
                NovelGenerationTask existing = taskMapper.selectTaskById(taskId);
                if (existing != null && !NovelGenerationTask.STATUS_FAILED.equals(existing.getStatus())
                        && !NovelGenerationTask.STATUS_SUCCESS.equals(existing.getStatus()))
                {
                    markFailed(taskId, e.getMessage());
                }
            }
            finally
            {
                com.book.novel.service.impl.NovelArchitectureServiceImpl.CURRENT_TASK_ID.remove();
                com.book.novel.service.impl.NovelChapterServiceImpl.CURRENT_TASK_ID.remove();
            }
        });
        return taskId;
    }
}
