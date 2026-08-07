package com.book.ai.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import com.book.ai.domain.PromptRenderRequest;
import com.book.ai.service.IPromptTemplateService;
import com.book.common.core.web.controller.BaseController;
import com.book.common.core.web.domain.AjaxResult;

/**
 * Prompt template rendering endpoint, called by book-novel before invoking /chat.
 *
 * @author book
 */
@RestController
public class PromptTemplateController extends BaseController
{
    @Autowired
    private IPromptTemplateService promptTemplateService;

    /**
     * Render the enabled template for a scenario with the given variables.
     */
    @PostMapping("/prompt/render")
    public AjaxResult render(@Validated @RequestBody PromptRenderRequest request)
    {
        String rendered = promptTemplateService.renderPrompt(request.getScenario(), request.getVariables());
        // Must use (msg, data): success(String) overload treats the prompt as msg and leaves data null.
        return AjaxResult.success("操作成功", rendered);
    }
}
