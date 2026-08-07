package com.book.novel.client;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;
import com.book.common.core.exception.ServiceException;

/**
 * Thin HTTP client for book-ai (Nacos discovery + LoadBalancer).
 *
 * @author book
 */
@Component
public class AiServiceClient
{
    private static final String AI_SERVICE = "http://book-ai";

    @Autowired
    private RestTemplate aiServiceRestTemplate;

    public String renderPrompt(String scenario, Map<String, Object> variables)
    {
        Map<String, Object> body = new HashMap<>();
        body.put("scenario", scenario);
        body.put("variables", variables);
        Map<?, ?> response = aiServiceRestTemplate.postForObject(AI_SERVICE + "/prompt/render", body, Map.class);
        Object data = extractData(response, "render prompt");
        if (data == null || !StringUtils.hasText(data.toString()))
        {
            throw new ServiceException("render prompt returned empty content, check book-ai /prompt/render");
        }
        return data.toString();
    }

    @SuppressWarnings("unchecked")
    public String chat(String modelKey, String systemPrompt, String userPrompt)
    {
        if (!StringUtils.hasText(userPrompt))
        {
            throw new ServiceException("model chat userPrompt must not be blank");
        }
        Map<String, Object> body = new HashMap<>();
        body.put("modelKey", modelKey);
        if (StringUtils.hasText(systemPrompt))
        {
            body.put("systemPrompt", systemPrompt);
        }
        body.put("userPrompt", userPrompt);
        Map<?, ?> response = aiServiceRestTemplate.postForObject(AI_SERVICE + "/chat", body, Map.class);
        Object data = extractData(response, "model chat");
        if (!(data instanceof Map))
        {
            throw new ServiceException("model chat returned an unexpected response format");
        }
        Object content = ((Map<String, Object>) data).get("content");
        return content == null ? "" : content.toString();
    }

    /**
     * Enabled model keys ordered by priority desc.
     */
    @SuppressWarnings("unchecked")
    public List<String> listEnabledModelKeys()
    {
        Map<?, ?> response = aiServiceRestTemplate.getForObject(AI_SERVICE + "/models/enabled", Map.class);
        Object data = extractData(response, "list enabled models");
        List<String> keys = new ArrayList<>();
        if (data instanceof List<?> list)
        {
            for (Object item : list)
            {
                if (item instanceof Map<?, ?> map)
                {
                    Object key = map.get("modelKey");
                    if (key != null && StringUtils.hasText(key.toString()))
                    {
                        keys.add(key.toString());
                    }
                }
            }
        }
        if (keys.isEmpty())
        {
            keys.add("deepseek");
        }
        return keys;
    }

    /**
     * Rule-based score for a chapter candidate.
     */
    @SuppressWarnings("unchecked")
    public int scoreContent(String content, String architectureContent)
    {
        Map<String, Object> body = new HashMap<>();
        body.put("content", content);
        body.put("architectureContent", architectureContent);
        Map<?, ?> response = aiServiceRestTemplate.postForObject(AI_SERVICE + "/score", body, Map.class);
        Object data = extractData(response, "score content");
        if (data instanceof Map<?, ?> map)
        {
            Object score = map.get("score");
            if (score instanceof Number)
            {
                return ((Number) score).intValue();
            }
        }
        return 0;
    }

    private Object extractData(Map<?, ?> response, String action)
    {
        if (response == null)
        {
            throw new ServiceException("book-ai call failed: " + action + ", empty response");
        }
        Object code = response.get("code");
        if (code == null || ((Number) code).intValue() != 200)
        {
            Object msg = response.get("msg");
            throw new ServiceException("book-ai call failed: " + action + ", " + msg);
        }
        return response.get("data");
    }
}
