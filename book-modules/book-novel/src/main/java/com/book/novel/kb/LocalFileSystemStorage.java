package com.book.novel.kb;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import com.book.common.core.exception.ServiceException;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * ZhiShiKu file system storage - local disk implementation.
 *
 * Local debugging and production environments run the same code; the only difference is the disk path
 * pointed to by the book.novel.kb.root-path config (e.g. D:/book-kb-data locally, /data/book/kb in production).
 * Business code never needs to change.
 *
 * @author book
 */
@Service
@ConditionalOnProperty(prefix = "book.novel.kb", name = "storage-type", havingValue = "local", matchIfMissing = true)
public class LocalFileSystemStorage implements KnowledgeBaseStorage
{
    private static final Logger log = LoggerFactory.getLogger(LocalFileSystemStorage.class);

    /** Knowledge base directory template, Obsidian-compatible layout, see AGENTS.md for naming spec */
    private static final String[] LAYOUT_DIRS = {
            "00-\u9879\u76ee\u914d\u7f6e", "01-\u5168\u5c40\u67b6\u6784", "02-\u7ae0\u8282\u5185\u5bb9",
            "03-\u7ae0\u8282\u4f18\u5316\u8bb0\u5f55", "04-\u521b\u4f5c\u53c2\u8003\u8d44\u6599", "05-\u64cd\u4f5c\u65e5\u5fd7"
    };

    private static final String PROJECT_CONFIG_DIR = "00-\u9879\u76ee\u914d\u7f6e";

    private static final String PROJECT_META_FILE = "project.json";

    private static final int KB_TEMPLATE_VERSION = 1;

    @Value("${book.novel.kb.root-path:D:/book-kb-data}")
    private String rootPath;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void initProjectLayout(Long projectId, String projectName)
    {
        Path projectRoot = resolveProjectRoot(projectId);
        try
        {
            Files.createDirectories(projectRoot);
            for (String dir : LAYOUT_DIRS)
            {
                Files.createDirectories(projectRoot.resolve(dir));
            }
            writeProjectMeta(projectRoot, projectId, projectName);
        }
        catch (IOException e)
        {
            log.error("init project [{}] knowledge base directory failed", projectId, e);
            throw new ServiceException("init knowledge base directory failed: " + e.getMessage());
        }
    }

    @Override
    public void writeMarkdown(Long projectId, String relativePath, String content)
    {
        Path target = resolveSafePath(projectId, relativePath);
        try
        {
            Files.createDirectories(target.getParent());
            Files.writeString(target, content == null ? "" : content, StandardCharsets.UTF_8);
        }
        catch (IOException e)
        {
            log.error("write knowledge base file failed, projectId={}, relativePath={}", projectId, relativePath, e);
            throw new ServiceException("write knowledge base file failed: " + e.getMessage());
        }
    }

           @Override
           public void writeFile(Long projectId, String relativePath, byte[] content)
           {
               Path target = resolveSafePath(projectId, relativePath);
               try
               {
                   Files.createDirectories(target.getParent());
                   Files.write(target, content == null ? new byte[0] : content);
               }
               catch (IOException e)
               {
                   log.error("write knowledge base binary file failed, projectId={}, relativePath={}", projectId, relativePath, e);
                   throw new ServiceException("write knowledge base file failed: " + e.getMessage());
               }
           }

           @Override
           public String readMarkdown(Long projectId, String relativePath)
    {
        Path target = resolveSafePath(projectId, relativePath);
        if (!Files.exists(target))
        {
            throw new ServiceException("file not found: " + relativePath);
        }
        try
        {
            return Files.readString(target, StandardCharsets.UTF_8);
        }
        catch (IOException e)
        {
            log.error("read knowledge base file failed, projectId={}, relativePath={}", projectId, relativePath, e);
            throw new ServiceException("read knowledge base file failed: " + e.getMessage());
        }
    }

    @Override
    public List<String> listFiles(Long projectId, String relativeDir)
    {
        Path dir = resolveSafePath(projectId, relativeDir);
        if (!Files.isDirectory(dir))
        {
            return List.of();
        }
        try (Stream<Path> stream = Files.list(dir))
        {
            return stream
                    .map(path -> path.getFileName().toString())
                    .sorted()
                    .collect(Collectors.toList());
        }
        catch (IOException e)
        {
            log.error("list knowledge base directory failed, projectId={}, relativeDir={}", projectId, relativeDir, e);
            throw new ServiceException("list knowledge base directory failed: " + e.getMessage());
        }
    }

    @Override
    public File packageAsZip(Long projectId)
    {
        return packageAsZip(projectId, false);
    }

    @Override
    public File packageAsZip(Long projectId, boolean approvedOnly)
    {
        Path projectRoot = resolveProjectRoot(projectId);
        if (!Files.isDirectory(projectRoot))
        {
            throw new ServiceException("project knowledge base directory not found, projectId=" + projectId);
        }
        try
        {
            File zipFile = File.createTempFile("novel-kb-" + projectId + "-", ".zip");
            zipFile.deleteOnExit();
            try (ZipOutputStream zos = new ZipOutputStream(Files.newOutputStream(zipFile.toPath())))
            {
                try (Stream<Path> stream = Files.walk(projectRoot))
                {
                    List<Path> files = stream.filter(Files::isRegularFile).collect(Collectors.toList());
                    for (Path file : files)
                    {
                        String entryName = projectRoot.relativize(file).toString().replace(File.separatorChar, '/');
                        if (approvedOnly && shouldSkipForApprovedOnly(entryName, file))
                        {
                            continue;
                        }
                        zos.putNextEntry(new ZipEntry(entryName));
                        Files.copy(file, zos);
                        zos.closeEntry();
                    }
                }
            }
            return zipFile;
        }
        catch (IOException e)
        {
            log.error("package project [{}] knowledge base failed", projectId, e);
            throw new ServiceException("package knowledge base failed: " + e.getMessage());
        }
    }

    /**
     * approvedOnly export: drop optimize drafts; keep current architecture + approved chapter files.
     */
    private boolean shouldSkipForApprovedOnly(String entryName, Path file)
    {
        if (entryName.startsWith("03-\u7ae0\u8282\u4f18\u5316\u8bb0\u5f55/"))
        {
            return true;
        }
        if (entryName.startsWith("01-\u5168\u5c40\u67b6\u6784/")
                && !entryName.endsWith("/" + "\u5f53\u524d\u67b6\u6784.md")
                && !entryName.equals("01-\u5168\u5c40\u67b6\u6784/\u5f53\u524d\u67b6\u6784.md"))
        {
            // Keep architecture version files only when frontmatter says approved
            try
            {
                String text = Files.readString(file, StandardCharsets.UTF_8);
                if (text.contains("review_status: approved"))
                {
                    return false;
                }
            }
            catch (IOException e)
            {
                return true;
            }
            return true;
        }
        return false;
    }

    @Override
    public String getProjectRootPath(Long projectId)
    {
        return resolveProjectRoot(projectId).toString();
    }

    private void writeProjectMeta(Path projectRoot, Long projectId, String projectName) throws IOException
    {
        Map<String, Object> meta = new LinkedHashMap<>();
        meta.put("projectId", projectId);
        meta.put("projectName", projectName);
        meta.put("createdTime", LocalDateTime.now().toString());
        meta.put("kbTemplateVersion", KB_TEMPLATE_VERSION);
        String json = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(meta);
        Files.writeString(projectRoot.resolve(PROJECT_CONFIG_DIR).resolve(PROJECT_META_FILE), json, StandardCharsets.UTF_8);
    }

    private Path resolveProjectRoot(Long projectId)
    {
        if (projectId == null || projectId <= 0)
        {
            throw new ServiceException("invalid projectId");
        }
        if (!StringUtils.hasText(rootPath))
        {
            throw new ServiceException("knowledge base root path not configured, please check book.novel.kb.root-path in Nacos config book-novel-dev.yml");
        }
        return Paths.get(rootPath).resolve(String.valueOf(projectId)).normalize();
    }

    /**
     * Resolve and validate a relative path, preventing path traversal (e.g. "../../etc/passwd") outside the project root.
     */
    private Path resolveSafePath(Long projectId, String relativePath)
    {
        if (!StringUtils.hasText(relativePath))
        {
            throw new ServiceException("file relative path must not be empty");
        }
        Path projectRoot = resolveProjectRoot(projectId);
        Path resolved = projectRoot.resolve(relativePath).normalize();
        if (!resolved.startsWith(projectRoot))
        {
            throw new ServiceException("illegal file path: " + relativePath);
        }
        return resolved;
    }
}
