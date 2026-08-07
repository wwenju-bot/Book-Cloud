package com.book.novel.kb;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import com.book.common.security.utils.SecurityUtils;

/**
 * Appends key operations to knowledge base daily log under 05-op-log/{yyyyMMdd}.md
 * (directory name uses Chinese via unicode escapes).
 *
 * @author book
 */
@Component
public class KbOperationLogger
{
    private static final Logger log = LoggerFactory.getLogger(KbOperationLogger.class);

    private static final String DIR_LOG = "05-\u64cd\u4f5c\u65e5\u5fd7";

    private static final DateTimeFormatter DAY = DateTimeFormatter.ofPattern("yyyyMMdd");

    private static final DateTimeFormatter TIME = DateTimeFormatter.ofPattern("HH:mm:ss");

    @Autowired
    private KnowledgeBaseStorage knowledgeBaseStorage;

    public void log(Long projectId, String action, String detail)
    {
        if (projectId == null || !StringUtils.hasText(action))
        {
            return;
        }
        try
        {
            String day = LocalDate.now().format(DAY);
            String relativePath = DIR_LOG + "/" + day + ".md";
            String existing = "";
            try
            {
                existing = knowledgeBaseStorage.readMarkdown(projectId, relativePath);
            }
            catch (Exception ignored)
            {
                existing = "# " + day + " \u64cd\u4f5c\u65e5\u5fd7\n\n";
            }
            if (!StringUtils.hasText(existing))
            {
                existing = "# " + day + " \u64cd\u4f5c\u65e5\u5fd7\n\n";
            }
            String operator;
            try
            {
                operator = SecurityUtils.getUsername();
            }
            catch (Exception e)
            {
                operator = "system";
            }
            if (!StringUtils.hasText(operator))
            {
                operator = "system";
            }
            String line = "- " + LocalDateTime.now().format(TIME) + " | " + operator + " | " + action
                    + (StringUtils.hasText(detail) ? " | " + detail.replace('\n', ' ') : "") + "\n";
            knowledgeBaseStorage.writeMarkdown(projectId, relativePath, existing + line);
        }
        catch (Exception e)
        {
            log.warn("append kb operation log failed, projectId={}, action={}: {}", projectId, action, e.getMessage());
        }
    }
}
