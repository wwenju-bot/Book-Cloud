package com.book.ai.domain;

import java.util.HashMap;
import java.util.Map;
import jakarta.validation.constraints.NotBlank;

/**
 * POST /prompt/render request body: render the enabled template for a given scenario with
 * the supplied variables, replacing {{key}} placeholders.
 *
 * @author book
 */
public class PromptRenderRequest
{
    /** Scenario key, e.g. architecture_parse / chapter_generate */
    @NotBlank(message = "scenario must not be blank")
    private String scenario;

    /** Placeholder variables used to render the template */
    private Map<String, Object> variables = new HashMap<>();

    public String getScenario()
    {
        return scenario;
    }

    public void setScenario(String scenario)
    {
        this.scenario = scenario;
    }

    public Map<String, Object> getVariables()
    {
        return variables;
    }

    public void setVariables(Map<String, Object> variables)
    {
        this.variables = variables;
    }
}
