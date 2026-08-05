package com.book.novel.domain;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.book.common.core.web.domain.BaseEntity;

/**
 * 创作项目表 novel_project
 *
 * @author book
 */
public class NovelProject extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 来源类型：上传手稿 */
    public static final String SOURCE_TYPE_UPLOAD = "upload";

    /** 来源类型：灵感输入 */
    public static final String SOURCE_TYPE_INSPIRATION = "inspiration";

    /** 项目状态：草稿 */
    public static final String STATUS_DRAFT = "draft";

    /** 项目ID */
    private Long projectId;

    /** 归属用户ID */
    private Long userId;

    /** 项目名称 */
    @NotBlank(message = "项目名称不能为空")
    @Size(max = 100, message = "项目名称长度不能超过100个字符")
    private String projectName;

    /** 来源类型（upload=上传手稿 inspiration=灵感输入） */
    private String sourceType;

    /** 项目状态（draft=草稿 in_progress=进行中 completed=已完成 archived=已归档） */
    private String status;

    /** 知识库文件系统落盘绝对路径 */
    private String kbRootPath;

    public Long getProjectId()
    {
        return projectId;
    }

    public void setProjectId(Long projectId)
    {
        this.projectId = projectId;
    }

    public Long getUserId()
    {
        return userId;
    }

    public void setUserId(Long userId)
    {
        this.userId = userId;
    }

    public String getProjectName()
    {
        return projectName;
    }

    public void setProjectName(String projectName)
    {
        this.projectName = projectName;
    }

    public String getSourceType()
    {
        return sourceType;
    }

    public void setSourceType(String sourceType)
    {
        this.sourceType = sourceType;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getKbRootPath()
    {
        return kbRootPath;
    }

    public void setKbRootPath(String kbRootPath)
    {
        this.kbRootPath = kbRootPath;
    }

    @Override
    public String toString()
    {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
                .append("projectId", getProjectId())
                .append("userId", getUserId())
                .append("projectName", getProjectName())
                .append("sourceType", getSourceType())
                .append("status", getStatus())
                .append("kbRootPath", getKbRootPath())
                .append("createBy", getCreateBy())
                .append("createTime", getCreateTime())
                .append("updateBy", getUpdateBy())
                .append("updateTime", getUpdateTime())
                .append("remark", getRemark())
                .toString();
    }
}
