package com.book.novel.domain;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.book.common.core.web.domain.BaseEntity;

/**
 * Architecture (outline) version entity, table novel_architecture_version.
 *
 * @author book
 */
public class NovelArchitectureVersion extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** Source: parsed by DeepSeek */
    public static final String SOURCE_DEEPSEEK_PARSE = "deepseek_parse";

    /** Source: optimized by Doubao */
    public static final String SOURCE_DOUBAO_OPTIMIZE = "doubao_optimize";

    /** Source: manually edited */
    public static final String SOURCE_MANUAL_EDIT = "manual_edit";

    /** Review status: pending */
    public static final String REVIEW_STATUS_PENDING = "pending";

    /** Review status: approved */
    public static final String REVIEW_STATUS_APPROVED = "approved";

    /** Review status: rejected */
    public static final String REVIEW_STATUS_REJECTED = "rejected";

    /** Version id */
    private Long versionId;

    /** Owning project id */
    private Long projectId;

    /** Version number, increments from 1 */
    private Integer versionNo;

    /** Architecture content (Markdown) */
    private String content;

    /** Source: deepseek_parse / doubao_optimize / manual_edit */
    private String source;

    /** Review status: pending / approved / rejected */
    private String reviewStatus;

    /** Review comment */
    private String reviewComment;

    /** Relative path of the corresponding knowledge base file */
    private String kbFilePath;

    public Long getVersionId()
    {
        return versionId;
    }

    public void setVersionId(Long versionId)
    {
        this.versionId = versionId;
    }

    public Long getProjectId()
    {
        return projectId;
    }

    public void setProjectId(Long projectId)
    {
        this.projectId = projectId;
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

    public String getSource()
    {
        return source;
    }

    public void setSource(String source)
    {
        this.source = source;
    }

    public String getReviewStatus()
    {
        return reviewStatus;
    }

    public void setReviewStatus(String reviewStatus)
    {
        this.reviewStatus = reviewStatus;
    }

    public String getReviewComment()
    {
        return reviewComment;
    }

    public void setReviewComment(String reviewComment)
    {
        this.reviewComment = reviewComment;
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
                .append("projectId", getProjectId())
                .append("versionNo", getVersionNo())
                .append("source", getSource())
                .append("reviewStatus", getReviewStatus())
                .append("kbFilePath", getKbFilePath())
                .append("createTime", getCreateTime())
                .toString();
    }
}
