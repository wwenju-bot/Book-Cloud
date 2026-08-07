package com.book.ai.domain;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Rule-based scoring result.
 *
 * @author book
 */
public class ScoreResult
{
    private int score;

    private int lengthScore;

    private int keywordScore;

    private int sensitiveScore;

    private int contentLength;

    private Map<String, Object> details = new LinkedHashMap<>();

    public int getScore()
    {
        return score;
    }

    public void setScore(int score)
    {
        this.score = score;
    }

    public int getLengthScore()
    {
        return lengthScore;
    }

    public void setLengthScore(int lengthScore)
    {
        this.lengthScore = lengthScore;
    }

    public int getKeywordScore()
    {
        return keywordScore;
    }

    public void setKeywordScore(int keywordScore)
    {
        this.keywordScore = keywordScore;
    }

    public int getSensitiveScore()
    {
        return sensitiveScore;
    }

    public void setSensitiveScore(int sensitiveScore)
    {
        this.sensitiveScore = sensitiveScore;
    }

    public int getContentLength()
    {
        return contentLength;
    }

    public void setContentLength(int contentLength)
    {
        this.contentLength = contentLength;
    }

    public Map<String, Object> getDetails()
    {
        return details;
    }

    public void setDetails(Map<String, Object> details)
    {
        this.details = details;
    }
}
