package com.book.novel.domain;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * Chapter generation request body for phase-1 synchronous Doubao generation.
 *
 * @author book
 */
public class ChapterGenerateRequest
{
    /** Chapter number, starting from 1 */
    @NotNull(message = "chapterNo must not be null")
    @Min(value = 1, message = "chapterNo must be >= 1")
    private Integer chapterNo;

    /** Chapter title */
    @NotBlank(message = "chapterTitle must not be blank")
    private String chapterTitle;

    /** Optional extra writing instruction injected into the prompt */
    private String extraInstruction;

    public Integer getChapterNo()
    {
        return chapterNo;
    }

    public void setChapterNo(Integer chapterNo)
    {
        this.chapterNo = chapterNo;
    }

    public String getChapterTitle()
    {
        return chapterTitle;
    }

    public void setChapterTitle(String chapterTitle)
    {
        this.chapterTitle = chapterTitle;
    }

    public String getExtraInstruction()
    {
        return extraInstruction;
    }

    public void setExtraInstruction(String extraInstruction)
    {
        this.extraInstruction = extraInstruction;
    }
}
