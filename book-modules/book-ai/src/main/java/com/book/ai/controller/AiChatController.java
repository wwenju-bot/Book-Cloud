package com.book.ai.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.book.ai.domain.AiChatRequest;
import com.book.ai.domain.ModelResponse;
import com.book.ai.service.ModelAdapter;
import com.book.ai.service.ModelAdapterRegistry;
import com.book.common.core.web.controller.BaseController;
import com.book.common.core.web.domain.AjaxResult;

/**
 * 模型对话联调接口，供 book-novel 等上游服务或直接联调测试使用
 *
 * @author book
 */
@RestController
@RequestMapping("/ai")
public class AiChatController extends BaseController
{
    @Autowired
    private ModelAdapterRegistry modelAdapterRegistry;

    /**
     * 统一模型对话接口
     *
     * 入参: {modelKey, systemPrompt, userPrompt, temperature, maxTokens}
     */
    @PostMapping("/chat")
    public AjaxResult chat(@Validated @RequestBody AiChatRequest request)
    {
        ModelAdapter adapter = modelAdapterRegistry.getAdapter(request.getModelKey());
        ModelResponse response = adapter.chat(request);
        return success(response);
    }
}
