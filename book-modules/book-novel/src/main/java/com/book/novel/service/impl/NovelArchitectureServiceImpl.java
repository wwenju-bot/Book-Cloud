package com.book.novel.service.impl;

import java.io.IOException;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import com.book.common.core.exception.ServiceException;
import com.book.common.core.utils.DateUtils;
import com.book.common.core.utils.StringUtils;
import com.book.common.security.utils.SecurityUtils;
import com.book.novel.client.AiServiceClient;
import com.book.novel.domain.NovelArchitectureVersion;
import com.book.novel.domain.NovelProject;
import com.book.novel.kb.KnowledgeBaseStorage;
import com.book.novel.mapper.NovelArchitectureVersionMapper;
import com.book.novel.service.INovelArchitectureService;
import com.book.novel.service.INovelProjectService;

/**
 * Architecture service implementation: phase 1 keeps the DeepSeek call synchronous (no
 * novel_generation_task yet, see AGENTS.md roadmap 1.5/2.4).
 *
 * @author book
 */
@Service
public class NovelArchitectureServiceImpl implements INovelArchitectureService
{
    private static final Logger log = LoggerFactory.getLogger(NovelArchitectureServiceImpl.class);

    /** 04-\u521b\u4f5c\u53c2\u8003\u8d44\u6599 (04-creative reference material) */
    private static final String DIR_REFERENCE = "04-\u521b\u4f5c\u53c2\u8003\u8d44\u6599";

    /** 01-\u5168\u5c40\u67b6\u6784 (01-global architecture) */
    private static final String DIR_ARCHITECTURE = "01-\u5168\u5c40\u67b6\u6784";

    /** \u5f53\u524d\u67b6\u6784.md (current-architecture.md) */
    private static final String CURRENT_ARCHITECTURE_FILE = "\u5f53\u524d\u67b6\u6784.md";

    private static final String SCENARIO_ARCHITECTURE_PARSE = "architecture_parse";

    private static final String MODEL_DEEPSEEK = "deepseek";

    @Autowired
    private NovelArchitectureVersionMapper versionMapper;

    @Autowired
    private INovelProjectService projectService;

    @Autowired
    private KnowledgeBaseStorage knowledgeBaseStorage;

    @Autowired
    private AiServiceClient aiServiceClient;

    @Override
    public String uploadMaterial(Long projectId, MultipartFile file)
    {
        projectService.selectProjectById(projectId);
        if (file == null || file.isEmpty())
        {
            throw new ServiceException("upload file must not be empty");
        }
        String originalFilename = file.getOriginalFilename();
        String safeFilename = StringUtils.hasText(originalFilename)
                ? Paths.get(originalFilename).getFileName().toString()
                : "material-" + System.currentTimeMillis();
        String relativePath = DIR_REFERENCE + "/" + safeFilename;
        try
        {
            knowledgeBaseStorage.writeFile(projectId, relativePath, file.getBytes());
        }
        catch (IOException e)
        {
            throw new ServiceException("read upload file failed: " + e.getMessage());
        }
        return relativePath;
    }

    @Override
    @Transactional
    public NovelArchitectureVersion parseArchitecture(Long projectId)
    {
        projectService.selectProjectById(projectId);

        List<String> fileNames = knowledgeBaseStorage.listFiles(projectId, DIR_REFERENCE);
        if (fileNames.isEmpty())
        {
            throw new ServiceException("no reference material uploaded yet, please call /project/{id}/upload first");
        }

        StringBuilder sourceContent = new StringBuilder();
        for (String fileName : fileNames)
        {
            String relativePath = DIR_REFERENCE + "/" + fileName;
            try
            {
                String text = knowledgeBaseStorage.readMarkdown(projectId, relativePath);
                sourceContent.append("### ").append(fileName).append("\n\n").append(text).append("\n\n");
            }
            catch (Exception e)
            {
                log.warn("skip non text-decodable reference material, projectId={}, file={}", projectId, fileName);
            }
        }
        if (sourceContent.length() == 0)
        {
            throw new ServiceException("reference material could not be read as text; phase 1 only supports .txt/.md, please re-upload");
        }

        Map<String, Object> vars = new HashMap<>();
        vars.put("sourceContent", sourceContent.toString());
        String prompt = aiServiceClient.renderPrompt(SCENARIO_ARCHITECTURE_PARSE, vars);
        String architectureContent = aiServiceClient.chat(MODEL_DEEPSEEK, null, prompt);
        if (!StringUtils.hasText(architectureContent))
        {
            throw new ServiceException("model returned empty architecture content, please retry");
        }

        int nextVersionNo = versionMapper.selectMaxVersionNo(projectId) + 1;
        String versionFilePath = DIR_ARCHITECTURE + "/v" + nextVersionNo + "-\u67b6\u6784.md";
        String fileContent = buildFrontmatter(projectId, nextVersionNo, MODEL_DEEPSEEK,
                NovelArchitectureVersion.REVIEW_STATUS_PENDING) + architectureContent;

        knowledgeBaseStorage.writeMarkdown(projectId, versionFilePath, fileContent);
        knowledgeBaseStorage.writeMarkdown(projectId, DIR_ARCHITECTURE + "/" + CURRENT_ARCHITECTURE_FILE, fileContent);

        NovelArchitectureVersion version = new NovelArchitectureVersion();
        version.setProjectId(projectId);
        version.setVersionNo(nextVersionNo);
        version.setContent(architectureContent);
        version.setSource(NovelArchitectureVersion.SOURCE_DEEPSEEK_PARSE);
        version.setReviewStatus(NovelArchitectureVersion.REVIEW_STATUS_PENDING);
        version.setKbFilePath(versionFilePath);
        version.setCreateBy(SecurityUtils.getUsername());
        versionMapper.insertVersion(version);
        return version;
    }

    @Override
    public NovelArchitectureVersion selectVersionById(Long versionId)
    {
        NovelArchitectureVersion version = versionMapper.selectVersionById(versionId);
        if (version == null)
        {
            throw new ServiceException("architecture version not found, versionId=" + versionId);
        }
        projectService.selectProjectById(version.getProjectId());
        return version;
    }

    @Override
    public List<NovelArchitectureVersion> selectVersionsByProjectId(Long projectId)
    {
        projectService.selectProjectById(projectId);
        return versionMapper.selectVersionsByProjectId(projectId);
    }

    /**
     * Build the YAML frontmatter block required for every knowledge base Markdown file, see
     * AGENTS.md "knowledge base file naming and metadata spec".
     */
    private String buildFrontmatter(Long projectId, int version, String model, String reviewStatus)
    {
        return "---\n"
                + "project_id: " + projectId + "\n"
                + "version: " + version + "\n"
                + "model: " + model + "\n"
                + "review_status: " + reviewStatus + "\n"
                + "created_at: " + DateUtils.getTime() + "\n"
                + "tags: [\u67b6\u6784, \u5f85\u5ba1\u6838]\n"
                + "---\n\n";
    }
}
