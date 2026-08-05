package com.book.novel.client;

import java.util.HashMap;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import com.book.common.core.exception.ServiceException;

/**
 * Thin HTTP client for calling the book-ai service by service name (Nacos discovery +
 * LoadBalancer), used to keep book-novel decoupled from book-ai's Java domain classes -
 * communication only happens through plain REST/JSON.
 *
 * @author book
 */
@Component
public class AiServiceClient
{
    private static final String AI_SERVICE = "http://book-ai";

    @Autowired
    private RestTemplate aiServiceRestTemplate;

    /**
     * Render a prompt template for the given scenario.
     *
     * @param scenario scenario key, e.g. architecture_parse
     * @param variables placeholder variables
     * @return rendered prompt text
     */
    public String renderPrompt(String scenario, Map<String, Object> variables)
    {
        Map<String, Object> body = new HashMap<>();
        body.put("scenario", scenario);
        body.put("variables", variables);
        Map<?, ?> response = aiServiceRestTemplate.postForObject(AI_SERVICE + "/prompt/render", body, Map.class);
        return (String) extractData(response, "render prompt");
    }

    /**
     * Call the unified model chat endpoint.
     *
     * @param modelKey model key, e.g. deepseek / doubao
     * @param systemPrompt optional system prompt
     * @param userPrompt user prompt (already rendered)
     * @return generated text content
     */
    @SuppressWarnings("unchecked")
    public String chat(String modelKey, String systemPrompt, String userPrompt)
    {
        Map<String, Object> body = new HashMap<>();
        body.put("modelKey", modelKey);
        body.put("systemPrompt", systemPrompt);
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
