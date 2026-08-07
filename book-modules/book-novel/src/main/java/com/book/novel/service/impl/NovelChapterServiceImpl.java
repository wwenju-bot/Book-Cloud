package com.book.novel.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.book.common.core.exception.ServiceException;
import com.book.common.core.utils.DateUtils;
import com.book.common.core.utils.StringUtils;
import com.book.common.security.utils.SecurityUtils;
import com.book.novel.client.AiServiceClient;
import com.book.novel.domain.ArchitectureReviewRequest;
import com.book.novel.domain.ChapterGenerateRequest;
import com.book.novel.domain.NovelArchitectureVersion;
import com.book.novel.domain.NovelChapter;
import com.book.novel.domain.NovelChapterVersion;
import com.book.novel.domain.NovelGenerationTask;
import com.book.novel.domain.NovelProject;
import com.book.novel.domain.NovelReviewRecord;
import com.book.novel.kb.KbOperationLogger;
import com.book.novel.kb.KnowledgeBaseStorage;
import com.book.novel.mapper.NovelArchitectureVersionMapper;
import com.book.novel.mapper.NovelChapterMapper;
import com.book.novel.mapper.NovelChapterVersionMapper;
import com.book.novel.mapper.NovelReviewRecordMapper;
import com.book.novel.service.INovelChapterService;
import com.book.novel.service.INovelGenerationTaskService;
import com.book.novel.service.INovelProjectService;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * Chapter service: multi-model candidates + scoring + review.
 *
 * @author book
 */
@Service
public class NovelChapterServiceImpl implements INovelChapterService
{
    private static final Logger log = LoggerFactory.getLogger(NovelChapterServiceImpl.class);

    private static final String DIR_ARCHITECTURE = "01-\u5168\u5c40\u67b6\u6784";

    private static final String CURRENT_ARCHITECTURE_FILE = "\u5f53\u524d\u67b6\u6784.md";

    private static final String DIR_CHAPTER = "02-\u7ae0\u8282\u5185\u5bb9";

    private static final String DIR_OPTIMIZE = "03-\u7ae0\u8282\u4f18\u5316\u8bb0\u5f55";

    private static final String SCENARIO_CHAPTER_GENERATE = "chapter_generate";

    public static final ThreadLocal<Long> CURRENT_TASK_ID = new ThreadLocal<>();

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    @Autowired
    private NovelChapterMapper chapterMapper;

    @Autowired
    private NovelChapterVersionMapper chapterVersionMapper;

    @Autowired
    private NovelArchitectureVersionMapper architectureVersionMapper;

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
    public Long submitGenerateChapter(Long projectId, ChapterGenerateRequest request)
    {
        projectService.selectProjectById(projectId);
        if (request == null || request.getChapterNo() == null || !StringUtils.hasText(request.getChapterTitle()))
        {
            throw new ServiceException("chapterNo and chapterTitle are required");
        }
        NovelArchitectureVersion approved = architectureVersionMapper.selectLatestApprovedByProjectId(projectId);
        if (approved == null)
        {
            throw new ServiceException("no approved architecture yet; please review and pass an architecture version first");
        }
        String createBy = SecurityUtils.getUsername();
        String params;
        try
        {
            params = OBJECT_MAPPER.writeValueAsString(request);
        }
        catch (Exception e)
        {
            params = "{}";
        }
        final ChapterGenerateRequest req = request;
        return generationTaskService.submit(projectId, NovelGenerationTask.TYPE_CHAPTER_GENERATE, params,
                () -> runGenerate(projectId, req, createBy));
    }

    private void runGenerate(Long projectId, ChapterGenerateRequest request, String createBy)
    {
        Long tid = CURRENT_TASK_ID.get();
        try
        {
            if (tid != null)
            {
                generationTaskService.updateProgress(tid, 10);
            }
            NovelProject project = projectService.selectProjectById(projectId);
            NovelArchitectureVersion approved = architectureVersionMapper.selectLatestApprovedByProjectId(projectId);
            if (approved == null)
            {
                throw new ServiceException("no approved architecture yet");
            }
            String architectureContent;
            try
            {
                architectureContent = knowledgeBaseStorage.readMarkdown(projectId,
                        DIR_ARCHITECTURE + "/" + CURRENT_ARCHITECTURE_FILE);
            }
            catch (Exception e)
            {
                architectureContent = approved.getContent();
            }
            if (!StringUtils.hasText(architectureContent))
            {
                throw new ServiceException("current architecture content is empty");
            }
            if (tid != null)
            {
                generationTaskService.updateProgress(tid, 25);
            }

            Map<String, Object> vars = new HashMap<>();
            vars.put("chapterNo", request.getChapterNo());
            vars.put("chapterTitle", request.getChapterTitle());
            vars.put("architectureContent", architectureContent);
            vars.put("extraInstruction",
                    StringUtils.hasText(request.getExtraInstruction()) ? request.getExtraInstruction() : "none");
            String prompt = aiServiceClient.renderPrompt(SCENARIO_CHAPTER_GENERATE, vars);

            List<String> modelKeys = aiServiceClient.listEnabledModelKeys();
            if (modelKeys.isEmpty())
            {
                throw new ServiceException("no enabled model for chapter generate");
            }

            NovelChapter chapter = chapterMapper.selectChapterByProjectIdAndNo(projectId, request.getChapterNo());
            if (chapter == null)
            {
                chapter = new NovelChapter();
                chapter.setProjectId(projectId);
                chapter.setChapterNo(request.getChapterNo());
                chapter.setTitle(request.getChapterTitle());
                chapter.setStatus(NovelChapter.STATUS_GENERATING);
                chapter.setCreateBy(createBy);
                chapterMapper.insertChapter(chapter);
            }
            else
            {
                NovelChapter update = new NovelChapter();
                update.setChapterId(chapter.getChapterId());
                update.setTitle(request.getChapterTitle());
                update.setStatus(NovelChapter.STATUS_GENERATING);
                update.setUpdateBy(createBy);
                chapterMapper.updateChapter(update);
                chapter.setTitle(request.getChapterTitle());
            }

            int nextRound = chapterVersionMapper.selectMaxOptimizeRound(chapter.getChapterId()) + 1;
            int versionNoBase = chapterVersionMapper.selectMaxVersionNo(chapter.getChapterId());
            String optimizeDir = DIR_OPTIMIZE + "/\u7b2c" + request.getChapterNo() + "\u7ae0";

            List<Long> versionIds = new ArrayList<>();
            NovelChapterVersion best = null;
            int done = 0;
            List<String> errors = new ArrayList<>();

            for (String modelKey : modelKeys)
            {
                try
                {
                    String chapterContent = aiServiceClient.chat(modelKey, null, prompt);
                    if (!StringUtils.hasText(chapterContent))
                    {
                        errors.add(modelKey + ": empty content");
                        continue;
                    }
                    int score = aiServiceClient.scoreContent(chapterContent, architectureContent);
                    int nextVersionNo = ++versionNoBase;
                    String optimizeFilePath = optimizeDir + "/v" + nextVersionNo + "-" + modelKey + ".md";
                    String fileContent = buildFrontmatter(projectId, nextVersionNo, modelKey,
                            NovelChapterVersion.REVIEW_STATUS_PENDING, score) + chapterContent;
                    knowledgeBaseStorage.writeMarkdown(projectId, optimizeFilePath, fileContent);

                    NovelChapterVersion version = new NovelChapterVersion();
                    version.setChapterId(chapter.getChapterId());
                    version.setVersionNo(nextVersionNo);
                    version.setContent(chapterContent);
                    version.setModelSource(modelKey);
                    version.setOptimizeRound(nextRound);
                    version.setScore(score);
                    version.setReviewStatus(NovelChapterVersion.REVIEW_STATUS_PENDING);
                    version.setKbFilePath(optimizeFilePath);
                    version.setRemark("score=" + score);
                    version.setCreateBy(createBy);
                    chapterVersionMapper.insertVersion(version);
                    versionIds.add(version.getVersionId());
                    if (best == null || (version.getScore() != null && best.getScore() != null
                            && version.getScore() > best.getScore())
                            || (best.getScore() == null && version.getScore() != null))
                    {
                        best = version;
                    }
                }
                catch (Exception e)
                {
                    log.warn("chapter candidate failed, model={}: {}", modelKey, e.getMessage());
                    errors.add(modelKey + ": " + e.getMessage());
                }
                done++;
                if (tid != null)
                {
                    int progress = 30 + (int) Math.round(50.0 * done / modelKeys.size());
                    generationTaskService.updateProgress(tid, Math.min(progress, 85));
                }
            }

            if (versionIds.isEmpty())
            {
                throw new ServiceException("all model candidates failed: " + String.join("; ", errors));
            }

            NovelChapter latestUpdate = new NovelChapter();
            latestUpdate.setChapterId(chapter.getChapterId());
            latestUpdate.setStatus(NovelChapter.STATUS_PENDING_REVIEW);
            latestUpdate.setLatestVersionId(best != null ? best.getVersionId() : versionIds.get(0));
            latestUpdate.setUpdateBy(createBy);
            chapterMapper.updateChapter(latestUpdate);

            if (NovelProject.STATUS_DRAFT.equals(project.getStatus()))
            {
                NovelProject projectUpdate = new NovelProject();
                projectUpdate.setProjectId(projectId);
                projectUpdate.setStatus("in_progress");
                projectService.updateProject(projectUpdate);
            }

            String resultRef = "round=" + nextRound + ";versions=" + versionIds
                    + ";winner=" + (best != null ? best.getVersionId() : versionIds.get(0));
            kbOperationLogger.log(projectId, "chapter_generate",
                    "ch" + request.getChapterNo() + " round=" + nextRound + " candidates=" + versionIds.size()
                            + " winnerScore=" + (best != null ? best.getScore() : "-"));
            if (tid != null)
            {
                generationTaskService.markSuccess(tid, resultRef);
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
    public List<NovelChapter> selectChaptersByProjectId(Long projectId)
    {
        projectService.selectProjectById(projectId);
        return chapterMapper.selectChaptersByProjectId(projectId);
    }

    @Override
    public List<NovelChapterVersion> selectVersionsByChapterId(Long chapterId)
    {
        NovelChapter chapter = chapterMapper.selectChapterById(chapterId);
        if (chapter == null)
        {
            throw new ServiceException("chapter not found, chapterId=" + chapterId);
        }
        projectService.selectProjectById(chapter.getProjectId());
        return chapterVersionMapper.selectVersionsByChapterId(chapterId);
    }

    @Override
    @Transactional
    public NovelChapterVersion promoteVersion(Long versionId)
    {
        NovelChapterVersion version = chapterVersionMapper.selectVersionById(versionId);
        if (version == null)
        {
            throw new ServiceException("chapter version not found, versionId=" + versionId);
        }
        NovelChapter chapter = chapterMapper.selectChapterById(version.getChapterId());
        if (chapter == null)
        {
            throw new ServiceException("chapter not found, chapterId=" + version.getChapterId());
        }
        projectService.selectProjectById(chapter.getProjectId());

        NovelChapter update = new NovelChapter();
        update.setChapterId(chapter.getChapterId());
        update.setLatestVersionId(versionId);
        update.setStatus(NovelChapter.STATUS_PENDING_REVIEW);
        update.setUpdateBy(SecurityUtils.getUsername());
        chapterMapper.updateChapter(update);

        kbOperationLogger.log(chapter.getProjectId(), "chapter_promote",
                "chapterId=" + chapter.getChapterId() + " versionId=" + versionId
                        + " model=" + version.getModelSource() + " score=" + version.getScore());
        return chapterVersionMapper.selectVersionById(versionId);
    }

    @Override
    @Transactional
    public NovelChapterVersion reviewVersion(Long versionId, ArchitectureReviewRequest request)
    {
        if (request == null || !StringUtils.hasText(request.getResult()))
        {
            throw new ServiceException("review result must be pass or reject");
        }
        String result = request.getResult().trim().toLowerCase();
        String reviewStatus;
        String chapterStatus;
        if ("pass".equals(result))
        {
            reviewStatus = NovelChapterVersion.REVIEW_STATUS_APPROVED;
            chapterStatus = NovelChapter.STATUS_APPROVED;
        }
        else if ("reject".equals(result))
        {
            reviewStatus = NovelChapterVersion.REVIEW_STATUS_REJECTED;
            chapterStatus = NovelChapter.STATUS_REJECTED;
        }
        else
        {
            throw new ServiceException("review result must be pass or reject");
        }

        NovelChapterVersion version = chapterVersionMapper.selectVersionById(versionId);
        if (version == null)
        {
            throw new ServiceException("chapter version not found, versionId=" + versionId);
        }
        NovelChapter chapter = chapterMapper.selectChapterById(version.getChapterId());
        if (chapter == null)
        {
            throw new ServiceException("chapter not found, chapterId=" + version.getChapterId());
        }
        projectService.selectProjectById(chapter.getProjectId());

        NovelChapterVersion versionUpdate = new NovelChapterVersion();
        versionUpdate.setVersionId(versionId);
        versionUpdate.setReviewStatus(reviewStatus);
        versionUpdate.setUpdateBy(SecurityUtils.getUsername());
        chapterVersionMapper.updateVersion(versionUpdate);

        NovelChapter chapterUpdate = new NovelChapter();
        chapterUpdate.setChapterId(chapter.getChapterId());
        chapterUpdate.setStatus(chapterStatus);
        if (NovelChapterVersion.REVIEW_STATUS_APPROVED.equals(reviewStatus))
        {
            chapterUpdate.setLatestVersionId(versionId);
        }
        chapterUpdate.setUpdateBy(SecurityUtils.getUsername());
        chapterMapper.updateChapter(chapterUpdate);

        NovelReviewRecord record = new NovelReviewRecord();
        record.setTargetType(NovelReviewRecord.TARGET_CHAPTER);
        record.setTargetId(chapter.getChapterId());
        record.setVersionId(versionId);
        record.setReviewerId(SecurityUtils.getUserId());
        record.setReviewResult(result);
        record.setReviewComment(request.getComment() == null ? "" : request.getComment());
        record.setCreateBy(SecurityUtils.getUsername());
        reviewRecordMapper.insertRecord(record);

        if (NovelChapterVersion.REVIEW_STATUS_APPROVED.equals(reviewStatus))
        {
            String content = version.getContent() == null ? "" : version.getContent();
            String safeTitle = sanitizeFileName(chapter.getTitle());
            String chapterFilePath = DIR_CHAPTER + "/\u7b2c" + chapter.getChapterNo() + "\u7ae0-" + safeTitle + ".md";
            String fileContent = buildFrontmatter(chapter.getProjectId(), version.getVersionNo(),
                    version.getModelSource() == null ? "manual" : version.getModelSource(), reviewStatus,
                    version.getScore()) + content;
            knowledgeBaseStorage.writeMarkdown(chapter.getProjectId(), chapterFilePath, fileContent);
            if (StringUtils.hasText(version.getKbFilePath()))
            {
                knowledgeBaseStorage.writeMarkdown(chapter.getProjectId(), version.getKbFilePath(), fileContent);
            }
        }
        kbOperationLogger.log(chapter.getProjectId(), "chapter_review",
                "versionId=" + versionId + " result=" + result);
        return chapterVersionMapper.selectVersionById(versionId);
    }

    private String buildFrontmatter(Long projectId, int version, String model, String reviewStatus, Integer score)
    {
        String tag = NovelChapterVersion.REVIEW_STATUS_APPROVED.equals(reviewStatus)
                ? "[\u7ae0\u8282, \u5df2\u5ba1\u6838]"
                : "[\u7ae0\u8282, \u5f85\u5ba1\u6838]";
        return "---\n"
                + "project_id: " + projectId + "\n"
                + "version: " + version + "\n"
                + "model: " + model + "\n"
                + "score: " + (score == null ? "" : score) + "\n"
                + "review_status: " + reviewStatus + "\n"
                + "created_at: " + DateUtils.getTime() + "\n"
                + "tags: " + tag + "\n"
                + "---\n\n";
    }

    private String sanitizeFileName(String title)
    {
        String cleaned = title.replaceAll("[\\\\/:*?\"<>|]", "_").trim();
        return StringUtils.hasText(cleaned) ? cleaned : "untitled";
    }
}
