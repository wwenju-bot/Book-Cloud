package com.book.ai;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import com.book.common.security.annotation.EnableCustomConfig;
import com.book.common.security.annotation.EnableRyFeignClients;

/**
 * AI模型网关/编排模块
 *
 * @author book
 */
@EnableCustomConfig
@EnableRyFeignClients
@SpringBootApplication
public class BookAiApplication
{
    public static void main(String[] args)
    {
        SpringApplication.run(BookAiApplication.class, args);
        System.out.println("(*^_^*)  AI模块启动成功  (*^_^*)");
    }
}
