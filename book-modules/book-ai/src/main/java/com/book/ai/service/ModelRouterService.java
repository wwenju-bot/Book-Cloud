package com.book.ai.service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import com.book.ai.config.AiModelProperties;
import com.book.ai.domain.ModelRouteInfo;
import com.book.common.core.exception.ServiceException;

/**
 * Routes to enabled models by priority (Nacos book.ai.models.*.enabled/priority).
 * DB table ai_model_config can replace YAML later without changing callers.
 *
 * @author book
 */
@Service
public class ModelRouterService
{
    @Autowired
    private AiModelProperties modelProperties;

    @Autowired
    private ModelAdapterRegistry modelAdapterRegistry;

    /**
     * Enabled models sorted by priority desc.
     */
    public List<ModelRouteInfo> listEnabledModels()
    {
        List<ModelRouteInfo> all = new ArrayList<>();
        all.add(toInfo("deepseek", modelProperties.getDeepseek()));
        all.add(toInfo("doubao", modelProperties.getDoubao()));
        return all.stream()
                .filter(ModelRouteInfo::isEnabled)
                .filter(info -> {
                    try
                    {
                        modelAdapterRegistry.getAdapter(info.getModelKey());
                        return true;
                    }
                    catch (ServiceException e)
                    {
                        return false;
                    }
                })
                .sorted(Comparator.comparingInt(ModelRouteInfo::getPriority).reversed())
                .toList();
    }

    /**
     * Highest-priority enabled model key.
     */
    public String selectPrimaryModelKey()
    {
        List<ModelRouteInfo> enabled = listEnabledModels();
        if (enabled.isEmpty())
        {
            throw new ServiceException("no enabled AI model; check book.ai.models in Nacos");
        }
        return enabled.get(0).getModelKey();
    }

    private ModelRouteInfo toInfo(String key, AiModelProperties.ModelConfig config)
    {
        boolean enabled = config != null && config.isEnabled()
                && StringUtils.hasText(config.getBaseUrl())
                && StringUtils.hasText(config.getApiKey());
        int priority = config == null ? 0 : config.getPriority();
        return new ModelRouteInfo(key, enabled, priority);
    }
}
