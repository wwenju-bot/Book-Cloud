package com.book.gateway.controller;

import java.io.IOException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import com.book.common.core.exception.CaptchaException;
import com.book.common.core.web.domain.AjaxResult;
import com.book.gateway.service.ValidateCodeService;

/**
 * Captcha endpoint via annotated controller (more reliable than RouterFunction
 * under some Gateway/WebFlux setups that fall through to static resources).
 */
@RestController
public class CaptchaController
{
    @Autowired
    private ValidateCodeService validateCodeService;

    @GetMapping("/code")
    public AjaxResult code() throws IOException, CaptchaException
    {
        return validateCodeService.createCaptcha();
    }
}
