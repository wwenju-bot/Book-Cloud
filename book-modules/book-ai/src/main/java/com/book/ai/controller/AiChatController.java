package com.book.ai.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import com.book.ai.domain.AiChatRequest;
import com.book.ai.domain.ModelResponse;
import com.book.ai.domain.ModelRouteInfo;
import com.book.ai.domain.ScoreRequest;
import com.book.ai.domain.ScoreResult;
import com.book.ai.service.ModelChatService;
import com.book.ai.service.ModelRouterService;
import com.book.ai.service.ScoringService;
import com.book.common.core.exception.ServiceException;
import com.book.common.core.web.controller.BaseController;
import com.book.common.core.web.domain.AjaxResult;

/**
 * Model chat / route / score endpoints for book-novel and manual debugging.
 *
 * @author book
 */
@RestController
public class AiChatController extends BaseController
{
    @Autowired
    private ModelChatService modelChatService;

    @Autowired
    private ModelRouterService modelRouterService;

    @Autowired
    private ScoringService scoringService;

    /**
     * Unified model chat (Sentinel-wrapped).
     */
    @PostMapping("/chat")
    public AjaxResult chat(@Validated @RequestBody AiChatRequest request)
    {
        if (!StringUtils.hasText(request.getUserPrompt()))
        {
            throw new ServiceException("userPrompt must not be blank");
        }
        if (!StringUtils.hasText(request.getModelKey()))
        {
            request.setModelKey(modelRouterService.selectPrimaryModelKey());
        }
        ModelResponse response = modelChatService.chat(request.getModelKey(), request);
        return success(response);
    }

    /**
     * List enabled models ordered by priority desc.
     */
    @GetMapping("/models/enabled")
    public AjaxResult listEnabledModels()
    {
        List<ModelRouteInfo> list = modelRouterService.listEnabledModels();
        return success(list);
    }

    /**
     * Rule-based scoring for a chapter candidate.
     */
    @PostMapping("/score")
    public AjaxResult score(@RequestBody ScoreRequest request)
    {
        if (request == null || !StringUtils.hasText(request.getContent()))
        {
            throw new ServiceException("content must not be blank");
        }
        ScoreResult result = scoringService.score(request);
        return success(result);
    }
}
