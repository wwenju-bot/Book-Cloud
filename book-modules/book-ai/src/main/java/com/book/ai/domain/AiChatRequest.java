package com.book.ai.domain;

/**
 * /chat request: {@link ModelRequest} plus modelKey for adapter selection.
 *
 * @author book
 */
public class AiChatRequest extends ModelRequest
{
    /** Model key; blank = primary from ModelRouterService */
    private String modelKey;

    public String getModelKey()
    {
        return modelKey;
    }

    public void setModelKey(String modelKey)
    {
        this.modelKey = modelKey;
    }
}
