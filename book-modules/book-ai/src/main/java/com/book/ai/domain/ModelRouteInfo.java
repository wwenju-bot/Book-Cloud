package com.book.ai.domain;

/**
 * Enabled model route entry for multi-candidate generation.
 *
 * @author book
 */
public class ModelRouteInfo
{
    private String modelKey;

    private boolean enabled;

    private int priority;

    public ModelRouteInfo()
    {
    }

    public ModelRouteInfo(String modelKey, boolean enabled, int priority)
    {
        this.modelKey = modelKey;
        this.enabled = enabled;
        this.priority = priority;
    }

    public String getModelKey()
    {
        return modelKey;
    }

    public void setModelKey(String modelKey)
    {
        this.modelKey = modelKey;
    }

    public boolean isEnabled()
    {
        return enabled;
    }

    public void setEnabled(boolean enabled)
    {
        this.enabled = enabled;
    }

    public int getPriority()
    {
        return priority;
    }

    public void setPriority(int priority)
    {
        this.priority = priority;
    }
}
