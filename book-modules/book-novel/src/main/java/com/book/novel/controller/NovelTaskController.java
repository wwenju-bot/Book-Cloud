package com.book.novel.controller;

import java.io.IOException;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;
import com.book.common.core.web.controller.BaseController;
import com.book.common.core.web.domain.AjaxResult;
import com.book.common.log.annotation.Log;
import com.book.common.log.enums.BusinessType;
import com.book.common.security.annotation.RequiresPermissions;
import com.book.novel.domain.NovelGenerationTask;
import com.book.novel.service.INovelGenerationTaskService;
import com.book.novel.service.NovelTaskRetryService;

/**
 * Async generation task query and SSE progress stream.
 *
 * @author book
 */
@RestController
public class NovelTaskController extends BaseController
{
    private static final ScheduledExecutorService SSE_SCHEDULER = Executors.newScheduledThreadPool(2);

    @Autowired
    private INovelGenerationTaskService generationTaskService;

    @Autowired
    private NovelTaskRetryService taskRetryService;

    @RequiresPermissions("novel:project:query")
    @GetMapping("/task/{taskId}")
    public AjaxResult getTask(@PathVariable Long taskId)
    {
        return success(generationTaskService.selectTaskById(taskId));
    }

    /**
     * Retry a failed task using original input_params; returns new taskId.
     */
    @RequiresPermissions("novel:project:edit")
    @Log(title = "novel task", businessType = BusinessType.OTHER)
    @PostMapping("/task/{taskId}/retry")
    public AjaxResult retry(@PathVariable Long taskId)
    {
        return AjaxResult.success("ok", taskRetryService.retry(taskId));
    }

    @RequiresPermissions("novel:project:query")
    @GetMapping(value = "/task/{taskId}/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter stream(@PathVariable Long taskId)
    {
        generationTaskService.selectTaskById(taskId);
        SseEmitter emitter = new SseEmitter(30 * 60 * 1000L);
        AtomicReference<ScheduledFuture<?>> futureRef = new AtomicReference<>();
        ScheduledFuture<?> future = SSE_SCHEDULER.scheduleAtFixedRate(() -> {
            try
            {
                NovelGenerationTask task = generationTaskService.selectTaskById(taskId);
                emitter.send(SseEmitter.event().name("progress").data(task));
                if (NovelGenerationTask.STATUS_SUCCESS.equals(task.getStatus())
                        || NovelGenerationTask.STATUS_FAILED.equals(task.getStatus()))
                {
                    ScheduledFuture<?> f = futureRef.get();
                    if (f != null)
                    {
                        f.cancel(false);
                    }
                    emitter.complete();
                }
            }
            catch (IOException | IllegalStateException e)
            {
                ScheduledFuture<?> f = futureRef.get();
                if (f != null)
                {
                    f.cancel(false);
                }
                try
                {
                    emitter.completeWithError(e);
                }
                catch (Exception ignored)
                {
                }
            }
            catch (Exception e)
            {
                ScheduledFuture<?> f = futureRef.get();
                if (f != null)
                {
                    f.cancel(false);
                }
                try
                {
                    emitter.completeWithError(e);
                }
                catch (Exception ignored)
                {
                }
            }
        }, 0, 1, TimeUnit.SECONDS);
        futureRef.set(future);
        emitter.onCompletion(() -> future.cancel(false));
        emitter.onTimeout(() -> {
            future.cancel(false);
            emitter.complete();
        });
        return emitter;
    }
}
