package com.book.ai.domain;

/**
 * 模型调用返回结果
 *
 * @author book
 */
public class ModelResponse
{
    /** 生成内容 */
    private String content;

    /** 输入 token 数 */
    private Integer promptTokens;

    /** 输出 token 数 */
    private Integer completionTokens;

    /** 结束原因（stop/length/content_filter 等） */
    private String finishReason;

    /** 原始响应 JSON，便于排查问题 */
    private String raw;

    public String getContent()
    {
        return content;
    }

    public void setContent(String content)
    {
        this.content = content;
    }

    public Integer getPromptTokens()
    {
        return promptTokens;
    }

    public void setPromptTokens(Integer promptTokens)
    {
        this.promptTokens = promptTokens;
    }

    public Integer getCompletionTokens()
    {
        return completionTokens;
    }

    public void setCompletionTokens(Integer completionTokens)
    {
        this.completionTokens = completionTokens;
    }

    public String getFinishReason()
    {
        return finishReason;
    }

    public void setFinishReason(String finishReason)
    {
        this.finishReason = finishReason;
    }

    public String getRaw()
    {
        return raw;
    }

    public void setRaw(String raw)
    {
        this.raw = raw;
    }
}
