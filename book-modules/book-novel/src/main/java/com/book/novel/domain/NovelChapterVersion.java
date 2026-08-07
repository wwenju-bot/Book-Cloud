package com.book.novel.domain;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.book.common.core.web.domain.BaseEntity;

/**
 * Chapter version entity, table novel_chapter_version.
 *
 * @author book
 */
public class NovelChapterVersion extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    public static final String MODEL_DEEPSEEK = "deepseek";

    public static final String MODEL_DOUBAO = "doubao";

    public static final String REVIEW_STATUS_PENDING = "pending";

    public static final String REVIEW_STATUS_APPROVED = "approved";

    public static final String REVIEW_STATUS_REJECTED = "rejected";

    private Long versionId;

    private Long chapterId;

    private Integer versionNo;

    private String content;

    private String modelSource;

    private Integer optimizeRound;

    /** Rule-based score 0-100 for multi-candidate ranking */
    private Integer score;

    private String reviewStatus;

    private String kbFilePath;

    public Long getVersionId()
    {
        return versionId;
    }

    public void setVersionId(Long versionId)
    {
        this.versionId = versionId;
    }

    public Long getChapterId()
    {
        return chapterId;
    }

    public void setChapterId(Long chapterId)
    {
        this.chapterId = chapterId;
    }

    public Integer getVersionNo()
    {
        return versionNo;
    }

    public void setVersionNo(Integer versionNo)
    {
        this.versionNo = versionNo;
    }

    public String getContent()
    {
        return content;
    }

    public void setContent(String content)
    {
        this.content = content;
    }

    public String getModelSource()
    {
        return modelSource;
    }

    public void setModelSource(String modelSource)
    {
        this.modelSource = modelSource;
    }

    public Integer getOptimizeRound()
    {
        return optimizeRound;
    }

    public void setOptimizeRound(Integer optimizeRound)
    {
        this.optimizeRound = optimizeRound;
    }

    public Integer getScore()
    {
        return score;
    }

    public void setScore(Integer score)
    {
        this.score = score;
    }

    public String getReviewStatus()
    {
        return reviewStatus;
    }

    public void setReviewStatus(String reviewStatus)
    {
        this.reviewStatus = reviewStatus;
    }

    public String getKbFilePath()
    {
        return kbFilePath;
    }

    public void setKbFilePath(String kbFilePath)
    {
        this.kbFilePath = kbFilePath;
    }

    @Override
    public String toString()
    {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
                .append("versionId", getVersionId())
                .append("chapterId", getChapterId())
                .append("versionNo", getVersionNo())
                .append("modelSource", getModelSource())
                .append("optimizeRound", getOptimizeRound())
                .append("score", getScore())
                .append("reviewStatus", getReviewStatus())
                .append("kbFilePath", getKbFilePath())
                .append("createTime", getCreateTime())
                .toString();
    }
}
