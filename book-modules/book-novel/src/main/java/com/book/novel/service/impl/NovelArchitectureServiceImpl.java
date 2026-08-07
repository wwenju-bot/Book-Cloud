package com.book.novel.service.impl;

import java.io.IOException;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
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
import com.book.novel.domain.ArchitectureDiffResult;
import com.book.novel.domain.ArchitectureReviewRequest;
import com.book.novel.domain.NovelArchitectureVersion;
import com.book.novel.domain.NovelGenerationTask;
import com.book.novel.domain.NovelReviewRecord;
import com.book.novel.kb.KbOperationLogger;
import com.book.novel.kb.KnowledgeBaseStorage;
import com.book.novel.mapper.NovelArchitectureVersionMapper;
import com.book.novel.mapper.NovelReviewRecordMapper;
import com.book.novel.service.INovelArchitectureService;
import com.book.novel.service.INovelGenerationTaskService;
import com.book.novel.service.INovelProjectService;
import com.github.difflib.DiffUtils;
import com.github.difflib.patch.AbstractDelta;
import com.github.difflib.patch.Patch;

/**
 * Architecture service: materials, async parse/optimize, review, diff.
 *
 * @author book
 */
@Service
public class NovelArchitectureServiceImpl implements INovelArchitectureService
{
    private static final Logger log = LoggerFactory.getLogger(NovelArchitectureServiceImpl.class);

    private static final String DIR_REFERENCE = "04-\u521b\u4f5c\u53c2\u8003\u8d44\u6599";

    private static final String DIR_ARCHITECTURE = "01-\u5168\u5c40\u67b6\u6784";

    private static final String CURRENT_ARCHITECTURE_FILE = "\u5f53\u524d\u67b6\u6784.md";

    private static final String SCENARIO_ARCHITECTURE_PARSE = "architecture_parse";

    private static final String SCENARIO_ARCHITECTURE_OPTIMIZE = "architecture_optimize";

    private static final String MODEL_DEEPSEEK = "deepseek";

    private static final String MODEL_DOUBAO = "doubao";

    @Autowired
    private NovelArchitectureVersionMapper versionMapper;

    @Autowired
    private NovelReviewRecordMapper reviewRecordMapper;

    @Autowired
    private INovelProjectService projectService;

    @Autowired
    private KnowledgeBaseStorage knowledgeBaseStorage;

    @Autowired
    private AiServiceClient aiServiceClient;

    @Autowired
    private INovelGenerationTaskService generationTaskService;

    @Autowired
    private KbOperationLogger kbOperationLogger;

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
    public List<String> listMaterials(Long projectId)
    {
        projectService.selectProjectById(projectId);
        return knowledgeBaseStorage.listFiles(projectId, DIR_REFERENCE);
    }

    @Override
    public Long submitParseArchitecture(Long projectId)
    {
        projectService.selectProjectById(projectId);
        String createBy = SecurityUtils.getUsername();
        return generationTaskService.submit(projectId, NovelGenerationTask.TYPE_ARCHITECTURE_PARSE, "{}",
                () -> runParse(projectId, createBy, null));
    }

    /**
     * Called by task runner; taskId is resolved by wrapping in submitWithTaskId helper.
     */
    private void runParse(Long projectId, String createBy, Long taskId)
    {
        Long tid = taskId;
        if (tid == null)
        {
            // submit() does not pass taskId into runnable — patch via ThreadLocal in task service.
            tid = CURRENT_TASK_ID.get();
        }
        try
        {
            if (tid != null)
            {
                generationTaskService.updateProgress(tid, 10);
            }
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
                throw new ServiceException("reference material could not be read as text; phase 1 only supports .txt/.md");
            }
            if (tid != null)
            {
                generationTaskService.updateProgress(tid, 40);
            }
            Map<String, Object> vars = new HashMap<>();
            vars.put("sourceContent", sourceContent.toString());
            String prompt = aiServiceClient.renderPrompt(SCENARIO_ARCHITECTURE_PARSE, vars);
            String architectureContent = aiServiceClient.chat(MODEL_DEEPSEEK, null, prompt);
            if (!StringUtils.hasText(architectureContent))
            {
                throw new ServiceException("model returned empty architecture content, please retry");
            }
            if (tid != null)
            {
                generationTaskService.updateProgress(tid, 80);
            }
            NovelArchitectureVersion version = persistArchitectureVersion(projectId, architectureContent,
                    NovelArchitectureVersion.SOURCE_DEEPSEEK_PARSE, MODEL_DEEPSEEK, createBy);
            kbOperationLogger.log(projectId, "architecture_parse", "versionId=" + version.getVersionId());
            if (tid != null)
            {
                generationTaskService.markSuccess(tid, String.valueOf(version.getVersionId()));
            }
        }
        catch (RuntimeException e)
        {
            if (tid != null)
            {
                generationTaskService.markFailed(tid, e.getMessage());
            }
            throw e;
        }
    }

    @Override
    public Long submitOptimizeArchitecture(Long versionId)
    {
        NovelArchitectureVersion base = selectVersionById(versionId);
        String createBy = SecurityUtils.getUsername();
        String params = "{\"versionId\":" + versionId + "}";
        return generationTaskService.submit(base.getProjectId(), NovelGenerationTask.TYPE_ARCHITECTURE_OPTIMIZE, params,
                () -> runOptimize(base.getProjectId(), versionId, createBy));
    }

    private void runOptimize(Long projectId, Long versionId, String createBy)
    {
        Long tid = CURRENT_TASK_ID.get();
        try
        {
            if (tid != null)
            {
                generationTaskService.updateProgress(tid, 10);
            }
            NovelArchitectureVersion base = versionMapper.selectVersionById(versionId);
            if (base == null || !StringUtils.hasText(base.getContent()))
            {
                throw new ServiceException("architecture version content is empty");
            }
            if (tid != null)
            {
                generationTaskService.updateProgress(tid, 40);
            }
            Map<String, Object> vars = new HashMap<>();
            vars.put("architectureContent", base.getContent());
            vars.put("extraInstruction", "none");
            String prompt = aiServiceClient.renderPrompt(SCENARIO_ARCHITECTURE_OPTIMIZE, vars);
            String optimized;
            try
            {
                optimized = aiServiceClient.chat(MODEL_DOUBAO, null, prompt);
            }
            catch (ServiceException doubaoEx)
            {
                log.warn("doubao optimize failed, fallback deepseek: {}", doubaoEx.getMessage());
                optimized = aiServiceClient.chat(MODEL_DEEPSEEK, null, prompt);
            }
            if (!StringUtils.hasText(optimized))
            {
                throw new ServiceException("model returned empty optimized architecture");
            }
            if (tid != null)
            {
                generationTaskService.updateProgress(tid, 80);
            }
            NovelArchitectureVersion version = persistArchitectureVersion(projectId, optimized,
                    NovelArchitectureVersion.SOURCE_DOUBAO_OPTIMIZE, MODEL_DOUBAO, createBy);
            kbOperationLogger.log(projectId, "architecture_optimize",
                    "baseVersionId=" + versionId + " newVersionId=" + version.getVersionId());
            if (tid != null)
            {
                generationTaskService.markSuccess(tid, String.valueOf(version.getVersionId()));
            }
        }
        catch (RuntimeException e)
        {
            if (tid != null)
            {
                generationTaskService.markFailed(tid, e.getMessage());
            }
            throw e;
        }
    }

    private NovelArchitectureVersion persistArchitectureVersion(Long projectId, String content, String source,
            String model, String createBy)
    {
        int nextVersionNo = versionMapper.selectMaxVersionNo(projectId) + 1;
        String versionFilePath = DIR_ARCHITECTURE + "/v" + nextVersionNo + "-\u67b6\u6784.md";
        String fileContent = buildFrontmatter(projectId, nextVersionNo, model,
                NovelArchitectureVersion.REVIEW_STATUS_PENDING) + content;
        knowledgeBaseStorage.writeMarkdown(projectId, versionFilePath, fileContent);

        NovelArchitectureVersion version = new NovelArchitectureVersion();
        version.setProjectId(projectId);
        version.setVersionNo(nextVersionNo);
        version.setContent(content);
        version.setSource(source);
        version.setReviewStatus(NovelArchitectureVersion.REVIEW_STATUS_PENDING);
        version.setKbFilePath(versionFilePath);
        version.setCreateBy(createBy);
        versionMapper.insertVersion(version);
        return version;
    }

    @Override
    public ArchitectureDiffResult diffVersions(Long versionId, Long compareToId)
    {
        NovelArchitectureVersion left = selectVersionById(compareToId);
        NovelArchitectureVersion right = selectVersionById(versionId);
        if (!left.getProjectId().equals(right.getProjectId()))
        {
            throw new ServiceException("diff versions must belong to the same project");
        }
        List<String> original = Arrays.asList((left.getContent() == null ? "" : left.getContent()).split("\n", -1));
        List<String> revised = Arrays.asList((right.getContent() == null ? "" : right.getContent()).split("\n", -1));
        Patch<String> patch = DiffUtils.diff(original, revised);

        ArchitectureDiffResult result = new ArchitectureDiffResult();
        result.setLeftVersionId(left.getVersionId());
        result.setRightVersionId(right.getVersionId());
        result.setLeftVersionNo(left.getVersionNo());
        result.setRightVersionNo(right.getVersionNo());
        List<ArchitectureDiffResult.DiffLine> lines = new ArrayList<>();
        for (AbstractDelta<String> delta : patch.getDeltas())
        {
            switch (delta.getType())
            {
                case INSERT:
                    for (String line : delta.getTarget().getLines())
                    {
                        lines.add(new ArchitectureDiffResult.DiffLine("insert", "", line));
                    }
                    break;
                case DELETE:
                    for (String line : delta.getSource().getLines())
                    {
                        lines.add(new ArchitectureDiffResult.DiffLine("delete", line, ""));
                    }
                    break;
                case CHANGE:
                    int max = Math.max(delta.getSource().size(), delta.getTarget().size());
                    for (int i = 0; i < max; i++)
                    {
                        String l = i < delta.getSource().size() ? delta.getSource().getLines().get(i) : "";
                        String r = i < delta.getTarget().size() ? delta.getTarget().getLines().get(i) : "";
                        lines.add(new ArchitectureDiffResult.DiffLine("change", l, r));
                    }
                    break;
                default:
                    break;
            }
        }
        if (lines.isEmpty())
        {
            lines.add(new ArchitectureDiffResult.DiffLine("equal", "(no differences)", "(no differences)"));
        }
        result.setLines(lines);
        return result;
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

    @Override
    @Transactional
    public NovelArchitectureVersion updateVersionContent(Long versionId, String content)
    {
        if (!StringUtils.hasText(content))
        {
            throw new ServiceException("architecture content must not be blank");
        }
        NovelArchitectureVersion version = selectVersionById(versionId);
        String fileContent = buildFrontmatter(version.getProjectId(), version.getVersionNo(),
                "manual", NovelArchitectureVersion.REVIEW_STATUS_PENDING) + content;
        String kbPath = StringUtils.hasText(version.getKbFilePath())
                ? version.getKbFilePath()
                : DIR_ARCHITECTURE + "/v" + version.getVersionNo() + "-\u67b6\u6784.md";
        knowledgeBaseStorage.writeMarkdown(version.getProjectId(), kbPath, fileContent);

        NovelArchitectureVersion update = new NovelArchitectureVersion();
        update.setVersionId(versionId);
        update.setContent(content);
        update.setSource(NovelArchitectureVersion.SOURCE_MANUAL_EDIT);
        update.setReviewStatus(NovelArchitectureVersion.REVIEW_STATUS_PENDING);
        update.setReviewComment("");
        update.setUpdateBy(SecurityUtils.getUsername());
        versionMapper.updateVersion(update);
        return selectVersionById(versionId);
    }

    @Override
    @Transactional
    public NovelArchitectureVersion reviewVersion(Long versionId, ArchitectureReviewRequest request)
    {
        if (request == null || !StringUtils.hasText(request.getResult()))
        {
            throw new ServiceException("review result must be pass or reject");
        }
        String result = request.getResult().trim().toLowerCase();
        String reviewStatus;
        if ("pass".equals(result))
        {
            reviewStatus = NovelArchitectureVersion.REVIEW_STATUS_APPROVED;
        }
        else if ("reject".equals(result))
        {
            reviewStatus = NovelArchitectureVersion.REVIEW_STATUS_REJECTED;
        }
        else
        {
            throw new ServiceException("review result must be pass or reject");
        }

        NovelArchitectureVersion version = selectVersionById(versionId);
        NovelArchitectureVersion update = new NovelArchitectureVersion();
        update.setVersionId(versionId);
        update.setReviewStatus(reviewStatus);
        update.setReviewComment(request.getComment() == null ? "" : request.getComment());
        update.setUpdateBy(SecurityUtils.getUsername());
        versionMapper.updateVersion(update);

        NovelReviewRecord record = new NovelReviewRecord();
        record.setTargetType(NovelReviewRecord.TARGET_ARCHITECTURE);
        record.setTargetId(version.getProjectId());
        record.setVersionId(versionId);
        record.setReviewerId(SecurityUtils.getUserId());
        record.setReviewResult(result);
        record.setReviewComment(request.getComment() == null ? "" : request.getComment());
        record.setCreateBy(SecurityUtils.getUsername());
        reviewRecordMapper.insertRecord(record);

        if (NovelArchitectureVersion.REVIEW_STATUS_APPROVED.equals(reviewStatus))
        {
            String content = version.getContent() == null ? "" : version.getContent();
            String fileContent = buildFrontmatter(version.getProjectId(), version.getVersionNo(),
                    version.getSource() == null ? "manual" : version.getSource(), reviewStatus) + content;
            String kbPath = StringUtils.hasText(version.getKbFilePath())
                    ? version.getKbFilePath()
                    : DIR_ARCHITECTURE + "/v" + version.getVersionNo() + "-\u67b6\u6784.md";
            knowledgeBaseStorage.writeMarkdown(version.getProjectId(), kbPath, fileContent);
            knowledgeBaseStorage.writeMarkdown(version.getProjectId(),
                    DIR_ARCHITECTURE + "/" + CURRENT_ARCHITECTURE_FILE, fileContent);
        }
        kbOperationLogger.log(version.getProjectId(), "architecture_review",
                "versionId=" + versionId + " result=" + result);
        return selectVersionById(versionId);
    }

    private String buildFrontmatter(Long projectId, int version, String model, String reviewStatus)
    {
        String tag = NovelArchitectureVersion.REVIEW_STATUS_APPROVED.equals(reviewStatus)
                ? "[\u67b6\u6784, \u5df2\u5ba1\u6838]"
                : "[\u67b6\u6784, \u5f85\u5ba1\u6838]";
        return "---\n"
                + "project_id: " + projectId + "\n"
                + "version: " + version + "\n"
                + "model: " + model + "\n"
                + "review_status: " + reviewStatus + "\n"
                + "created_at: " + DateUtils.getTime() + "\n"
                + "tags: " + tag + "\n"
                + "---\n\n";
    }

    /** Task id for the current async worker thread. */
    public static final ThreadLocal<Long> CURRENT_TASK_ID = new ThreadLocal<>();
}
