package com.book.system;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import com.book.common.security.annotation.EnableCustomConfig;
import com.book.common.security.annotation.EnableRyFeignClients;

/**
 * 系统模块
 * 
 * @author book
 */
@EnableCustomConfig
@EnableRyFeignClients
@SpringBootApplication
public class BookSystemApplication
{
    public static void main(String[] args)
    {
        SpringApplication.run(BookSystemApplication.class, args);
        System.out.println("(♥◠‿◠)ﾉﾞ  系统模块启动成功   ლ(´ڡ`ლ)ﾞ  \n" +
                " .-------.       ____     __        \n" +
                " |  _ _   \\      \\   \\   /  /    \n" +
                " | ( ' )  |       \\  _. /  '       \n" +
                " |(_ o _) /        _( )_ .'         \n" +
                " | (_,_).' __  ___(_ o _)'          \n" +
                " |  |\\ \\  |  ||   |(_,_)'         \n" +
                " |  | \\ `'   /|   `-'  /           \n" +
                " |  |  \\    /  \\      /           \n" +
                " ''-'   `'-'    `-..-'              ");
    }
}
