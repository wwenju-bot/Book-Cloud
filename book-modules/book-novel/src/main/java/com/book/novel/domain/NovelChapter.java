package com.book.novel.domain;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.book.common.core.web.domain.BaseEntity;

/**
 * Chapter entity, table novel_chapter.
 *
 * @author book
 */
public class NovelChapter extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    public static final String STATUS_PENDING = "pending";

    public static final String STATUS_GENERATING = "generating";

    public static final String STATUS_PENDING_REVIEW = "pending_review";

    public static final String STATUS_APPROVED = "approved";

    public static final String STATUS_REJECTED = "rejected";

    public static final String STATUS_PUBLISHED = "published";

    private Long chapterId;

    private Long projectId;

    private Integer chapterNo;

    private String title;

    private String status;

    private Long latestVersionId;

    public Long getChapterId()
    {
        return chapterId;
    }

    public void setChapterId(Long chapterId)
    {
        this.chapterId = chapterId;
    }

    public Long getProjectId()
    {
        return projectId;
    }

    public void setProjectId(Long projectId)
    {
        this.projectId = projectId;
    }

    public Integer getChapterNo()
    {
        return chapterNo;
    }

    public void setChapterNo(Integer chapterNo)
    {
        this.chapterNo = chapterNo;
    }

    public String getTitle()
    {
        return title;
    }

    public void setTitle(String title)
    {
        this.title = title;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public Long getLatestVersionId()
    {
        return latestVersionId;
    }

    public void setLatestVersionId(Long latestVersionId)
    {
        this.latestVersionId = latestVersionId;
    }

    @Override
    public String toString()
    {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
                .append("chapterId", getChapterId())
                .append("projectId", getProjectId())
                .append("chapterNo", getChapterNo())
                .append("title", getTitle())
                .append("status", getStatus())
                .append("latestVersionId", getLatestVersionId())
                .append("createTime", getCreateTime())
                .toString();
    }
}
