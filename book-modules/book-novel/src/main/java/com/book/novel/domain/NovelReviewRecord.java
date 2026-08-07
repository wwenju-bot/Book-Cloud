package com.book.novel.domain;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.book.common.core.web.domain.BaseEntity;

/**
 * Review audit record, table novel_review_record.
 *
 * @author book
 */
public class NovelReviewRecord extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    public static final String TARGET_ARCHITECTURE = "architecture";

    public static final String TARGET_CHAPTER = "chapter";

    public static final String RESULT_PASS = "pass";

    public static final String RESULT_REJECT = "reject";

    private Long recordId;

    private String targetType;

    private Long targetId;

    private Long versionId;

    private Long reviewerId;

    private String reviewResult;

    private String reviewComment;

    public Long getRecordId()
    {
        return recordId;
    }

    public void setRecordId(Long recordId)
    {
        this.recordId = recordId;
    }

    public String getTargetType()
    {
        return targetType;
    }

    public void setTargetType(String targetType)
    {
        this.targetType = targetType;
    }

    public Long getTargetId()
    {
        return targetId;
    }

    public void setTargetId(Long targetId)
    {
        this.targetId = targetId;
    }

    public Long getVersionId()
    {
        return versionId;
    }

    public void setVersionId(Long versionId)
    {
        this.versionId = versionId;
    }

    public Long getReviewerId()
    {
        return reviewerId;
    }

    public void setReviewerId(Long reviewerId)
    {
        this.reviewerId = reviewerId;
    }

    public String getReviewResult()
    {
        return reviewResult;
    }

    public void setReviewResult(String reviewResult)
    {
        this.reviewResult = reviewResult;
    }

    public String getReviewComment()
    {
        return reviewComment;
    }

    public void setReviewComment(String reviewComment)
    {
        this.reviewComment = reviewComment;
    }

    @Override
    public String toString()
    {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
                .append("recordId", getRecordId())
                .append("targetType", getTargetType())
                .append("targetId", getTargetId())
                .append("versionId", getVersionId())
                .append("reviewerId", getReviewerId())
                .append("reviewResult", getReviewResult())
                .append("reviewComment", getReviewComment())
                .append("createTime", getCreateTime())
                .toString();
    }
}
