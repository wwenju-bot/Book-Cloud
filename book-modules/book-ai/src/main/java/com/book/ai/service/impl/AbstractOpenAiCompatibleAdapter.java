package com.book.ai.service.impl;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import com.book.ai.config.AiModelProperties;
import com.book.ai.domain.ModelRequest;
import com.book.ai.domain.ModelResponse;
import com.book.ai.service.ModelAdapter;
import com.book.common.core.exception.ServiceException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * DeepSeek、豆包（豆包/Ark）等模型均兼容 OpenAI Chat Completions 接口协议，
 * 公共请求组装/响应解析逻辑在此统一实现，具体子类只需提供各自的连接配置。
 *
 * @author book
 */
public abstract class AbstractOpenAiCompatibleAdapter implements ModelAdapter
{
    private static final Logger log = LoggerFactory.getLogger(AbstractOpenAiCompatibleAdapter.class);

    private static final String CHAT_COMPLETIONS_PATH = "/chat/completions";

    protected final RestTemplate restTemplate;

    protected final ObjectMapper objectMapper = new ObjectMapper();

    protected AbstractOpenAiCompatibleAdapter(RestTemplate restTemplate)
    {
        this.restTemplate = restTemplate;
    }

    /**
     * 子类提供各自的模型连接配置
     */
    protected abstract AiModelProperties.ModelConfig getModelConfig();

    @Override
    public ModelResponse chat(ModelRequest request)
    {
        AiModelProperties.ModelConfig config = getModelConfig();
        if (config == null || !StringUtils.hasText(config.getBaseUrl()) || !StringUtils.hasText(config.getApiKey()))
        {
            throw new ServiceException(getModelKey() + " 模型未配置 base-url/api-key，请检查 Nacos 配置 book-ai-dev.yml");
        }

        Map<String, Object> body = buildRequestBody(request, config);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(config.getApiKey());

        String url = config.getBaseUrl() + CHAT_COMPLETIONS_PATH;
        try
        {
            ResponseEntity<String> response = restTemplate.postForEntity(url, new HttpEntity<>(body, headers), String.class);
            if (response.getStatusCode() != HttpStatus.OK || response.getBody() == null)
            {
                throw new ServiceException(getModelKey() + " 调用失败，HTTP状态：" + response.getStatusCode());
            }
            return parseResponse(response.getBody());
        }
        catch (RestClientException e)
        {
            log.error("调用模型[{}]失败，url={}, model={}", getModelKey(), url, config.getModel(), e);
            String detail = e.getMessage() == null ? "" : e.getMessage();
            if (detail.contains("InvalidEndpointOrModel") || detail.contains("ModelNotOpen") || detail.contains("404"))
            {
                throw new ServiceException(getModelKey() + " 调用失败：模型或接入点不可用（当前 model="
                        + config.getModel()
                        + "）。请到火山方舟控制台开通模型，或把 book-ai-dev.yml 的 book.ai.models.doubao.model "
                        + "改成已开通的完整模型 ID / 推理接入点 ep-xxx（也可用环境变量 DOUBAO_MODEL）。原始错误："
                        + detail);
            }
            throw new ServiceException(getModelKey() + " 调用失败：" + detail);
        }
    }

    private Map<String, Object> buildRequestBody(ModelRequest request, AiModelProperties.ModelConfig config)
    {
        if (!StringUtils.hasText(request.getUserPrompt()))
        {
            throw new ServiceException(getModelKey() + " userPrompt 不能为空");
        }

        List<Map<String, String>> messages = new ArrayList<>();
        if (StringUtils.hasText(request.getSystemPrompt()))
        {
            messages.add(buildMessage("system", request.getSystemPrompt()));
        }
        messages.add(buildMessage("user", request.getUserPrompt()));

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("model", config.getModel());
        body.put("messages", messages);
        if (request.getTemperature() != null)
        {
            body.put("temperature", request.getTemperature());
        }
        if (request.getMaxTokens() != null)
        {
            body.put("max_tokens", request.getMaxTokens());
        }
        // Avoid extraParams overwriting messages/model with malformed values
        if (request.getExtraParams() != null && !request.getExtraParams().isEmpty())
        {
            for (Map.Entry<String, Object> entry : request.getExtraParams().entrySet())
            {
                String key = entry.getKey();
                if ("messages".equals(key) || "model".equals(key))
                {
                    continue;
                }
                body.put(key, entry.getValue());
            }
        }
        return body;
    }

    private Map<String, String> buildMessage(String role, String content)
    {
        Map<String, String> message = new LinkedHashMap<>();
        message.put("role", role);
        message.put("content", content == null ? "" : content);
        return message;
    }

    private ModelResponse parseResponse(String rawBody)
    {
        try
        {
            JsonNode root = objectMapper.readTree(rawBody);
            JsonNode choice = root.path("choices").path(0);
            JsonNode usage = root.path("usage");

            ModelResponse response = new ModelResponse();
            response.setContent(choice.path("message").path("content").asText(null));
            response.setFinishReason(choice.path("finish_reason").asText(null));
            response.setPromptTokens(usage.has("prompt_tokens") ? usage.get("prompt_tokens").asInt() : null);
            response.setCompletionTokens(usage.has("completion_tokens") ? usage.get("completion_tokens").asInt() : null);
            response.setRaw(rawBody);
            return response;
        }
        catch (Exception e)
        {
            log.error("解析模型[{}]响应失败，原始响应：{}", getModelKey(), rawBody, e);
            throw new ServiceException(getModelKey() + " 响应解析失败，请检查接口返回格式");
        }
    }
}
