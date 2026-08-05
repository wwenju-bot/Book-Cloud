package com.book.ai.domain;

import java.util.HashMap;
import java.util.Map;

/**
 * 模型调用请求参数
 *
 * @author book
 */
public class ModelRequest
{
    /** 系统提示词 */
    private String systemPrompt;

    /** 用户提示词（渲染后的最终 prompt） */
    private String userPrompt;

    /** 采样温度，默认沿用各模型自身默认值 */
    private Double temperature;

    /** 最大生成 token 数 */
    private Integer maxTokens;

    /** 透传的模型特有参数 */
    private Map<String, Object> extraParams = new HashMap<>();

    public String getSystemPrompt()
    {
        return systemPrompt;
    }

    public void setSystemPrompt(String systemPrompt)
    {
        this.systemPrompt = systemPrompt;
    }

    public String getUserPrompt()
    {
        return userPrompt;
    }

    public void setUserPrompt(String userPrompt)
    {
        this.userPrompt = userPrompt;
    }

    public Double getTemperature()
    {
        return temperature;
    }

    public void setTemperature(Double temperature)
    {
        this.temperature = temperature;
    }

    public Integer getMaxTokens()
    {
        return maxTokens;
    }

    public void setMaxTokens(Integer maxTokens)
    {
        this.maxTokens = maxTokens;
    }

    public Map<String, Object> getExtraParams()
    {
        return extraParams;
    }

    public void setExtraParams(Map<String, Object> extraParams)
    {
        this.extraParams = extraParams;
    }
}
