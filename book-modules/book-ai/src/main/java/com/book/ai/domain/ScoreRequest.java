package com.book.ai.domain;

/**
 * Rule-based scoring request for chapter candidates.
 *
 * @author book
 */
public class ScoreRequest
{
    /** Generated chapter content */
    private String content;

    /** Architecture / outline text used as keyword source */
    private String architectureContent;

    /** Target word count (Chinese chars), default 2500 */
    private Integer targetLength;

    public String getContent()
    {
        return content;
    }

    public void setContent(String content)
    {
        this.content = content;
    }

    public String getArchitectureContent()
    {
        return architectureContent;
    }

    public void setArchitectureContent(String architectureContent)
    {
        this.architectureContent = architectureContent;
    }

    public Integer getTargetLength()
    {
        return targetLength;
    }

    public void setTargetLength(Integer targetLength)
    {
        this.targetLength = targetLength;
    }
}
