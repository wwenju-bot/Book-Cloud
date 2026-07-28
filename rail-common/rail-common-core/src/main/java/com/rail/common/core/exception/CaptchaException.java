package com.rail.common.core.exception;

/**
 * 验证码错误异常类
 * 
 * @author rail
 */
public class CaptchaException extends RuntimeException
{
    private static final long serialVersionUID = 1L;

    public CaptchaException(String msg)
    {
        super(msg);
    }
}
