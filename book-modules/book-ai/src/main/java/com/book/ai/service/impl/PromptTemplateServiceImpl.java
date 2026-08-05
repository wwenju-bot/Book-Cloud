package com.book.ai.service.impl;

import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.book.ai.domain.AiPromptTemplate;
import com.book.ai.mapper.AiPromptTemplateMapper;
import com.book.ai.service.IPromptTemplateService;
import com.book.common.core.exception.ServiceException;

/**
 * Renders templates from ai_prompt_template using a simple {{key}} placeholder substitution.
 * No third-party template engine is introduced on purpose, per AGENTS.md design notes.
 *
 * @author book
 */
@Service
public class PromptTemplateServiceImpl implements IPromptTemplateService
{
    private static final Pattern PLACEHOLDER_PATTERN = Pattern.compile("\\{\\{\\s*(\\w+)\\s*\\}\\}");

    @Autowired
    private AiPromptTemplateMapper promptTemplateMapper;

    @Override
    public String renderPrompt(String scenario, Map<String, Object> variables)
    {
        AiPromptTemplate template = promptTemplateMapper.selectLatestEnabledByScenario(scenario);
        if (template == null)
        {
            throw new ServiceException("no enabled prompt template found for scenario: " + scenario);
        }
        return render(template.getContent(), variables);
    }

    private String render(String content, Map<String, Object> variables)
    {
        if (content == null)
        {
            return "";
        }
        Matcher matcher = PLACEHOLDER_PATTERN.matcher(content);
        StringBuilder result = new StringBuilder();
        while (matcher.find())
        {
            String key = matcher.group(1);
            Object value = variables == null ? null : variables.get(key);
            matcher.appendReplacement(result, Matcher.quoteReplacement(value == null ? "" : String.valueOf(value)));
        }
        matcher.appendTail(result);
        return result.toString();
    }
}
