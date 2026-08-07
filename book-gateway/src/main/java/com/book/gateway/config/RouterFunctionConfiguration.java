package com.book.gateway.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.server.RequestPredicates;
import org.springframework.web.reactive.function.server.RouterFunction;
import org.springframework.web.reactive.function.server.RouterFunctions;
import com.book.gateway.handler.ValidateCodeHandler;

/**
 * 路由配置信息
 * 
 * @author book
 */
@Configuration
public class RouterFunctionConfiguration
{
    @Autowired
    private ValidateCodeHandler validateCodeHandler;

    @SuppressWarnings("rawtypes")
    @Bean
    public RouterFunction routerFunction()
    {
        // Do not require Accept: text/plain — browsers/axios often send application/json
        // and would otherwise miss this route ("No static resource code").
        return RouterFunctions.route(
                RequestPredicates.GET("/code"),
                validateCodeHandler);
    }
}
