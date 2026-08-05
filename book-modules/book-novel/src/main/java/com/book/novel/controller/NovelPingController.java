package com.book.novel.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import com.book.common.core.web.controller.BaseController;
import com.book.common.core.web.domain.AjaxResult;

/**
 * 健康检查接口，用于验证网关 -> book-novel 端到端链路是否打通
 *
 * @author book
 */
@RestController
public class NovelPingController extends BaseController
{
    @GetMapping("/ping")
    public AjaxResult ping()
    {
        return success("pong");
    }
}
