package com.book.novel.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import com.book.common.core.exception.ServiceException;
import com.book.common.core.utils.StringUtils;
import com.book.novel.domain.ChapterGenerateRequest;
import com.book.novel.domain.NovelGenerationTask;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * Resubmit a failed generation task using stored input_params.
 *
 * @author book
 */
@Service
public class NovelTaskRetryService
{
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    @Autowired
    private INovelGenerationTaskService generationTaskService;

    @Lazy
    @Autowired
    private INovelArchitectureService architectureService;

    @Lazy
    @Autowired
    private INovelChapterService chapterService;

    public Long retry(Long taskId)
    {
        NovelGenerationTask task = generationTaskService.selectTaskById(taskId);
        if (!NovelGenerationTask.STATUS_FAILED.equals(task.getStatus()))
        {
            throw new ServiceException("only failed tasks can be retried, status=" + task.getStatus());
        }
        String type = task.getTaskType();
        String params = task.getInputParams();
        if (NovelGenerationTask.TYPE_ARCHITECTURE_PARSE.equals(type))
        {
            return architectureService.submitParseArchitecture(task.getProjectId());
        }
        if (NovelGenerationTask.TYPE_ARCHITECTURE_OPTIMIZE.equals(type))
        {
            Long versionId = readLong(params, "versionId");
            if (versionId == null)
            {
                throw new ServiceException("architecture_optimize input_params missing versionId");
            }
            return architectureService.submitOptimizeArchitecture(versionId);
        }
        if (NovelGenerationTask.TYPE_CHAPTER_GENERATE.equals(type))
        {
            ChapterGenerateRequest request = parseChapterRequest(params);
            return chapterService.submitGenerateChapter(task.getProjectId(), request);
        }
        throw new ServiceException("unsupported task type for retry: " + type);
    }

    private ChapterGenerateRequest parseChapterRequest(String params)
    {
        try
        {
            ChapterGenerateRequest request = OBJECT_MAPPER.readValue(
                    StringUtils.hasText(params) ? params : "{}", ChapterGenerateRequest.class);
            if (request.getChapterNo() == null || !StringUtils.hasText(request.getChapterTitle()))
            {
                throw new ServiceException("chapter_generate input_params incomplete");
            }
            return request;
        }
        catch (ServiceException e)
        {
            throw e;
        }
        catch (Exception e)
        {
            throw new ServiceException("invalid chapter_generate input_params: " + e.getMessage());
        }
    }

    private Long readLong(String json, String field)
    {
        try
        {
            if (!StringUtils.hasText(json))
            {
                return null;
            }
            JsonNode node = OBJECT_MAPPER.readTree(json);
            JsonNode value = node.get(field);
            return value == null || value.isNull() ? null : value.asLong();
        }
        catch (Exception e)
        {
            return null;
        }
    }
}
