package com.book.novel.config;

import java.util.concurrent.ThreadPoolExecutor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

/**
 * Thread pool for novel generation tasks (architecture parse/optimize, chapter generate).
 *
 * @author book
 */
@Configuration
public class TaskExecutorConfig
{
    @Value("${book.novel.task.core-pool-size:2}")
    private int corePoolSize;

    @Value("${book.novel.task.max-pool-size:8}")
    private int maxPoolSize;

    @Value("${book.novel.task.queue-capacity:100}")
    private int queueCapacity;

    @Bean(name = "novelTaskExecutor")
    public ThreadPoolTaskExecutor novelTaskExecutor()
    {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(corePoolSize);
        executor.setMaxPoolSize(maxPoolSize);
        executor.setQueueCapacity(queueCapacity);
        executor.setThreadNamePrefix("novel-task-");
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        executor.initialize();
        return executor;
    }
}
