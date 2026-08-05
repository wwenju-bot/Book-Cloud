package com.book.ai.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/**
 * 模型接入配置，对应 Nacos 配置 book-ai-dev.yml 中的 book.ai.models.* 节点
 *
 * @author book
 */
@Configuration
@ConfigurationProperties(prefix = "book.ai.models")
public class AiModelProperties
{
    private ModelConfig deepseek = new ModelConfig();

    private ModelConfig doubao = new ModelConfig();

    public ModelConfig getDeepseek()
    {
        return deepseek;
    }

    public void setDeepseek(ModelConfig deepseek)
    {
        this.deepseek = deepseek;
    }

    public ModelConfig getDoubao()
    {
        return doubao;
    }

    public void setDoubao(ModelConfig doubao)
    {
        this.doubao = doubao;
    }

    /**
     * 单个模型的连接配置
     */
    public static class ModelConfig
    {
        /** 接口根地址 */
        private String baseUrl;

        /** API Key（生产环境应通过环境变量/密钥管理注入，不落库不落配置文件明文） */
        private String apiKey;

        /** 默认模型名称/接入点 ID */
        private String model;

        /** 调用超时时间（毫秒） */
        private int timeout = 60000;

        public String getBaseUrl()
        {
            return baseUrl;
        }

        public void setBaseUrl(String baseUrl)
        {
            this.baseUrl = baseUrl;
        }

        public String getApiKey()
        {
            return apiKey;
        }

        public void setApiKey(String apiKey)
        {
            this.apiKey = apiKey;
        }

        public String getModel()
        {
            return model;
        }

        public void setModel(String model)
        {
            this.model = model;
        }

        public int getTimeout()
        {
            return timeout;
        }

        public void setTimeout(int timeout)
        {
            this.timeout = timeout;
        }
    }
}
