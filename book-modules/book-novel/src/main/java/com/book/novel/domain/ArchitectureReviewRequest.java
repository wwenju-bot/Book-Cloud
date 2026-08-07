package com.book.novel.domain;

/**
 * Architecture version review request body: result = pass | reject.
 *
 * @author book
 */
public class ArchitectureReviewRequest
{
    /** Review result: pass / reject */
    private String result;

    /** Optional review comment */
    private String comment;

    public String getResult()
    {
        return result;
    }

    public void setResult(String result)
    {
        this.result = result;
    }

    public String getComment()
    {
        return comment;
    }

    public void setComment(String comment)
    {
        this.comment = comment;
    }
}
