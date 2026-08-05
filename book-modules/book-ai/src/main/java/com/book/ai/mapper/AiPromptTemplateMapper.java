package com.book.ai.mapper;

import com.book.ai.domain.AiPromptTemplate;

/**
 * Prompt template mapper, table ai_prompt_template.
 *
 * @author book
 */
public interface AiPromptTemplateMapper
{
    /**
     * Select the highest-version enabled template for a given scenario.
     *
     * @param scenario scenario key, e.g. architecture_parse
     * @return template, or null if none enabled for this scenario
     */
    AiPromptTemplate selectLatestEnabledByScenario(String scenario);
}
