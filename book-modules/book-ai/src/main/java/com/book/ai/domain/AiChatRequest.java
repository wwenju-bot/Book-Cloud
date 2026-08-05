package com.book.ai.domain;

import jakarta.validation.constraints.NotBlank;

/**
 * /ai/chat 接口入参：在 {@link ModelRequest} 基础上多一个 modelKey 用于选择适配器
 *
 * @author book
 */
public class AiChatRequest extends ModelRequest
{
    /** 模型标识，如 deepseek / doubao */
    @NotBlank(message = "modelKey 不能为空")
    private String modelKey;

    public String getModelKey()
    {
        return modelKey;
    }

    public void setModelKey(String modelKey)
    {
        this.modelKey = modelKey;
    }
}
