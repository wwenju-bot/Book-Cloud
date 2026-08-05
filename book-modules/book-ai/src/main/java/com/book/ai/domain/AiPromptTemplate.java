package com.book.ai.domain;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.book.common.core.web.domain.BaseEntity;

/**
 * Prompt template entity, table ai_prompt_template.
 *
 * @author book
 */
public class AiPromptTemplate extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** Scenario: architecture parse */
    public static final String SCENARIO_ARCHITECTURE_PARSE = "architecture_parse";

    /** Scenario: architecture optimize */
    public static final String SCENARIO_ARCHITECTURE_OPTIMIZE = "architecture_optimize";

    /** Scenario: chapter generate */
    public static final String SCENARIO_CHAPTER_GENERATE = "chapter_generate";

    /** Scenario: chapter optimize */
    public static final String SCENARIO_CHAPTER_OPTIMIZE = "chapter_optimize";

    /** Template id */
    private Long templateId;

    /** Template key, unique */
    private String templateKey;

    /** Scenario this template applies to */
    private String scenario;

    /** Template content, contains {{placeholder}} tokens */
    private String content;

    /** Template version number */
    private Integer version;

    /** Enabled flag: 0=disabled 1=enabled */
    private String enabled;

    public Long getTemplateId()
    {
        return templateId;
    }

    public void setTemplateId(Long templateId)
    {
        this.templateId = templateId;
    }

    public String getTemplateKey()
    {
        return templateKey;
    }

    public void setTemplateKey(String templateKey)
    {
        this.templateKey = templateKey;
    }

    public String getScenario()
    {
        return scenario;
    }

    public void setScenario(String scenario)
    {
        this.scenario = scenario;
    }

    public String getContent()
    {
        return content;
    }

    public void setContent(String content)
    {
        this.content = content;
    }

    public Integer getVersion()
    {
        return version;
    }

    public void setVersion(Integer version)
    {
        this.version = version;
    }

    public String getEnabled()
    {
        return enabled;
    }

    public void setEnabled(String enabled)
    {
        this.enabled = enabled;
    }

    @Override
    public String toString()
    {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
                .append("templateId", getTemplateId())
                .append("templateKey", getTemplateKey())
                .append("scenario", getScenario())
                .append("version", getVersion())
                .append("enabled", getEnabled())
                .append("createTime", getCreateTime())
                .toString();
    }
}
