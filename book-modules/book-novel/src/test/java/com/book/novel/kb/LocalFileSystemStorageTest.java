package com.book.novel.kb;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.zip.ZipFile;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.test.util.ReflectionTestUtils;
import com.book.common.core.exception.ServiceException;

/**
 * LocalFileSystemStorage 单元测试：覆盖目录初始化模板、文件读写往返、路径穿越防护、打包导出
 *
 * @author book
 */
class LocalFileSystemStorageTest
{
    private static final String[] EXPECTED_DIRS = {
            "00-项目配置", "01-全局架构", "02-章节内容", "03-章节优化记录", "04-创作参考资料", "05-操作日志"
    };

    @TempDir
    Path tempDir;

    private LocalFileSystemStorage storage;

    @BeforeEach
    void setUp()
    {
        storage = new LocalFileSystemStorage();
        ReflectionTestUtils.setField(storage, "rootPath", tempDir.toString());
    }

    @Test
    void initProjectLayout_createsAllSixDirsAndProjectJson()
    {
        storage.initProjectLayout(1001L, "测试项目");

        Path projectRoot = tempDir.resolve("1001");
        for (String dir : EXPECTED_DIRS)
        {
            assertTrue(Files.isDirectory(projectRoot.resolve(dir)), "缺少目录：" + dir);
        }
        Path metaFile = projectRoot.resolve("00-项目配置").resolve("project.json");
        assertTrue(Files.exists(metaFile), "project.json 未生成");
    }

    @Test
    void writeAndReadMarkdown_roundTrip() throws Exception
    {
        storage.initProjectLayout(1002L, "往返测试");

        storage.writeMarkdown(1002L, "01-全局架构/v1-架构.md", "# 架构\n第一版");
        String content = storage.readMarkdown(1002L, "01-全局架构/v1-架构.md");

        assertEquals("# 架构\n第一版", content);
    }

    @Test
    void writeMarkdown_rejectsPathTraversal()
    {
        storage.initProjectLayout(1003L, "越权测试");

        assertThrows(ServiceException.class,
                () -> storage.writeMarkdown(1003L, "../../evil.md", "hacked"));
    }

    @Test
    void listFiles_returnsEmptyListWhenDirMissing()
    {
        storage.initProjectLayout(1004L, "空目录测试");

        List<String> files = storage.listFiles(1004L, "02-章节内容");

        assertTrue(files.isEmpty());
    }

    @Test
    void packageAsZip_containsAllTemplateDirsAndWrittenFile() throws Exception
    {
        storage.initProjectLayout(1005L, "导出测试");
        storage.writeMarkdown(1005L, "02-章节内容/第1章.md", "正文内容");

        File zipFile = storage.packageAsZip(1005L);
        try (ZipFile zip = new ZipFile(zipFile))
        {
            assertTrue(zip.stream().anyMatch(e -> e.getName().endsWith("project.json")));
            assertTrue(zip.stream().anyMatch(e -> e.getName().contains("第1章.md")));
        }
        finally
        {
            assertFalse(!zipFile.delete() && zipFile.exists());
        }
    }
}
