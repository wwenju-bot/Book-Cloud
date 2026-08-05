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
 * 知识库文件系统存储 · 本地磁盘实现。
 *
 * 本地调试和生产环境走的是同一套代码，区别只在于 book.novel.kb.root-path 配置指向的磁盘路径不同
 * （本地如 D:/book-kb-data，生产如 /data/book/kb），业务代码完全不用改。
 *
 * @author book
 */
@Service
@ConditionalOnProperty(prefix = "book.novel.kb", name = "storage-type", havingValue = "local", matchIfMissing = true)
public class LocalFileSystemStorage implements KnowledgeBaseStorage
{
    private static final Logger log = LoggerFactory.getLogger(LocalFileSystemStorage.class);

    /** 知识库目录模板，沿用 Obsidian 兼容的目录结构，详见 AGENTS.md "知识库文件命名与元数据规范" */
    private static final String[] LAYOUT_DIRS = {
            "00-项目配置", "01-全局架构", "02-章节内容", "03-章节优化记录", "04-创作参考资料", "05-操作日志"
    };

    private static final String PROJECT_CONFIG_DIR = "00-项目配置";

    private static final String PROJECT_META_FILE = "project.json";

    private static final int KB_TEMPLATE_VERSION = 1;

    @Value("${book.novel.kb.root-path}")
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
            log.error("初始化项目[{}]知识库目录失败", projectId, e);
            throw new ServiceException("初始化知识库目录失败：" + e.getMessage());
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
            log.error("写入知识库文件失败，projectId={}, relativePath={}", projectId, relativePath, e);
            throw new ServiceException("写入知识库文件失败：" + e.getMessage());
        }
    }

    @Override
    public String readMarkdown(Long projectId, String relativePath)
    {
        Path target = resolveSafePath(projectId, relativePath);
        if (!Files.exists(target))
        {
            throw new ServiceException("文件不存在：" + relativePath);
        }
        try
        {
            return Files.readString(target, StandardCharsets.UTF_8);
        }
        catch (IOException e)
        {
            log.error("读取知识库文件失败，projectId={}, relativePath={}", projectId, relativePath, e);
            throw new ServiceException("读取知识库文件失败：" + e.getMessage());
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
            log.error("列出知识库目录失败，projectId={}, relativeDir={}", projectId, relativeDir, e);
            throw new ServiceException("列出知识库目录失败：" + e.getMessage());
        }
    }

    @Override
    public File packageAsZip(Long projectId)
    {
        Path projectRoot = resolveProjectRoot(projectId);
        if (!Files.isDirectory(projectRoot))
        {
            throw new ServiceException("项目知识库目录不存在，projectId=" + projectId);
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
            log.error("打包项目[{}]知识库失败", projectId, e);
            throw new ServiceException("打包知识库失败：" + e.getMessage());
        }
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
            throw new ServiceException("projectId 非法");
        }
        if (!StringUtils.hasText(rootPath))
        {
            throw new ServiceException("知识库根路径未配置，请检查 Nacos 配置 book-novel-dev.yml 中的 book.novel.kb.root-path");
        }
        return Paths.get(rootPath).resolve(String.valueOf(projectId)).normalize();
    }

    /**
     * 校验并解析相对路径，防止路径穿越（如 "../../etc/passwd"）逃出项目根目录
     */
    private Path resolveSafePath(Long projectId, String relativePath)
    {
        if (!StringUtils.hasText(relativePath))
        {
            throw new ServiceException("文件相对路径不能为空");
        }
        Path projectRoot = resolveProjectRoot(projectId);
        Path resolved = projectRoot.resolve(relativePath).normalize();
        if (!resolved.startsWith(projectRoot))
        {
            throw new ServiceException("非法的文件路径：" + relativePath);
        }
        return resolved;
    }
}
