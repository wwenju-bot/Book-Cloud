package com.book.ai.service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import org.springframework.stereotype.Component;
import com.book.common.core.exception.ServiceException;

/**
 * 按 modelKey 查找对应的 {@link ModelAdapter}，新增模型只需新增一个 ModelAdapter 实现类，
 * Spring 会自动注入进来，无需改动本类。阶段2的 ModelRouterService 会在此基础上扩展路由/降级策略。
 *
 * @author book
 */
@Component
public class ModelAdapterRegistry
{
    private final Map<String, ModelAdapter> adapters;

    public ModelAdapterRegistry(List<ModelAdapter> adapterList)
    {
        this.adapters = adapterList.stream()
                .collect(Collectors.toMap(ModelAdapter::getModelKey, adapter -> adapter));
    }

    public ModelAdapter getAdapter(String modelKey)
    {
        ModelAdapter adapter = adapters.get(modelKey);
        if (adapter == null)
        {
            throw new ServiceException("不支持的模型：" + modelKey);
        }
        return adapter;
    }
}
