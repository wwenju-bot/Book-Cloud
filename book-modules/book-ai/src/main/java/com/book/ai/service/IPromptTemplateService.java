package com.book.ai.service;

import java.util.Map;

/**
 * Prompt template service: read the enabled template for a scenario from ai_prompt_template
 * and render it by substituting {{key}} placeholders with the supplied variables.
 *
 * @author book
 */
public interface IPromptTemplateService
{
    /**
     * Render the prompt for a given scenario.
     *
     * @param scenario scenario key, e.g. architecture_parse / chapter_generate
     * @param variables placeholder values, {{key}} in the template is replaced by variables.get("key")
     * @return rendered prompt text
     */
    String renderPrompt(String scenario, Map<String, Object> variables);
}
