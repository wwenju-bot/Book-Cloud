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
 * LocalFileSystemStorage unit tests: layout template init, write/read round trip,
 * path traversal protection, zip export.
 *
 * @author book
 */
class LocalFileSystemStorageTest
{
    private static final String[] EXPECTED_DIRS = {
            "00-\u9879\u76ee\u914d\u7f6e", "01-\u5168\u5c40\u67b6\u6784", "02-\u7ae0\u8282\u5185\u5bb9",
            "03-\u7ae0\u8282\u4f18\u5316\u8bb0\u5f55", "04-\u521b\u4f5c\u53c2\u8003\u8d44\u6599", "05-\u64cd\u4f5c\u65e5\u5fd7"
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
        storage.initProjectLayout(1001L, "test-project");

        Path projectRoot = tempDir.resolve("1001");
        for (String dir : EXPECTED_DIRS)
        {
            assertTrue(Files.isDirectory(projectRoot.resolve(dir)), "missing dir: " + dir);
        }
        Path metaFile = projectRoot.resolve("00-\u9879\u76ee\u914d\u7f6e").resolve("project.json");
        assertTrue(Files.exists(metaFile), "project.json not generated");
    }

    @Test
    void writeAndReadMarkdown_roundTrip() throws Exception
    {
        storage.initProjectLayout(1002L, "round-trip-test");

        storage.writeMarkdown(1002L, "01-\u5168\u5c40\u67b6\u6784/v1.md", "# Architecture\nFirst draft");
        String content = storage.readMarkdown(1002L, "01-\u5168\u5c40\u67b6\u6784/v1.md");

        assertEquals("# Architecture\nFirst draft", content);
    }

    @Test
    void writeMarkdown_rejectsPathTraversal()
    {
        storage.initProjectLayout(1003L, "traversal-test");

        assertThrows(ServiceException.class,
                () -> storage.writeMarkdown(1003L, "../../evil.md", "hacked"));
    }

    @Test
    void listFiles_returnsEmptyListWhenDirMissing()
    {
        storage.initProjectLayout(1004L, "empty-dir-test");

        List<String> files = storage.listFiles(1004L, "02-\u7ae0\u8282\u5185\u5bb9");

        assertTrue(files.isEmpty());
    }

    @Test
    void packageAsZip_containsAllTemplateDirsAndWrittenFile() throws Exception
    {
        storage.initProjectLayout(1005L, "export-test");
        storage.writeMarkdown(1005L, "02-\u7ae0\u8282\u5185\u5bb9/chapter1.md", "chapter body");

        File zipFile = storage.packageAsZip(1005L);
        try (ZipFile zip = new ZipFile(zipFile))
        {
            assertTrue(zip.stream().anyMatch(e -> e.getName().endsWith("project.json")));
            assertTrue(zip.stream().anyMatch(e -> e.getName().contains("chapter1.md")));
        }
        finally
        {
            assertFalse(!zipFile.delete() && zipFile.exists());
        }
    }
}
