package com.book.novel;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import com.book.common.security.annotation.EnableCustomConfig;
import com.book.common.security.annotation.EnableRyFeignClients;

/**
 * 小说创作核心业务模块
 *
 * @author book
 */
@EnableCustomConfig
@EnableRyFeignClients
@SpringBootApplication
public class BookNovelApplication
{
    public static void main(String[] args)
    {
        SpringApplication.run(BookNovelApplication.class, args);
        System.out.println("(*^_^*)  小说创作模块启动成功  (*^_^*)");
    }
}
