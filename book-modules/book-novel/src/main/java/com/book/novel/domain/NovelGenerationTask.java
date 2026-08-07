package com.book.novel.domain;

import java.util.Date;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.book.common.core.web.domain.BaseEntity;

/**
 * Async generation task, table novel_generation_task.
 *
 * @author book
 */
public class NovelGenerationTask extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    public static final String TYPE_ARCHITECTURE_PARSE = "architecture_parse";

    public static final String TYPE_ARCHITECTURE_OPTIMIZE = "architecture_optimize";

    public static final String TYPE_CHAPTER_GENERATE = "chapter_generate";

    public static final String STATUS_PENDING = "pending";

    public static final String STATUS_RUNNING = "running";

    public static final String STATUS_SUCCESS = "success";

    public static final String STATUS_FAILED = "failed";

    private Long taskId;

    private Long projectId;

    private String taskType;

    private String status;

    private Integer progress;

    private String inputParams;

    private String resultRef;

    private String errorMsg;

    private Date startTime;

    private Date finishTime;

    public Long getTaskId()
    {
        return taskId;
    }

    public void setTaskId(Long taskId)
    {
        this.taskId = taskId;
    }

    public Long getProjectId()
    {
        return projectId;
    }

    public void setProjectId(Long projectId)
    {
        this.projectId = projectId;
    }

    public String getTaskType()
    {
        return taskType;
    }

    public void setTaskType(String taskType)
    {
        this.taskType = taskType;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public Integer getProgress()
    {
        return progress;
    }

    public void setProgress(Integer progress)
    {
        this.progress = progress;
    }

    public String getInputParams()
    {
        return inputParams;
    }

    public void setInputParams(String inputParams)
    {
        this.inputParams = inputParams;
    }

    public String getResultRef()
    {
        return resultRef;
    }

    public void setResultRef(String resultRef)
    {
        this.resultRef = resultRef;
    }

    public String getErrorMsg()
    {
        return errorMsg;
    }

    public void setErrorMsg(String errorMsg)
    {
        this.errorMsg = errorMsg;
    }

    public Date getStartTime()
    {
        return startTime;
    }

    public void setStartTime(Date startTime)
    {
        this.startTime = startTime;
    }

    public Date getFinishTime()
    {
        return finishTime;
    }

    public void setFinishTime(Date finishTime)
    {
        this.finishTime = finishTime;
    }

    @Override
    public String toString()
    {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
                .append("taskId", getTaskId())
                .append("projectId", getProjectId())
                .append("taskType", getTaskType())
                .append("status", getStatus())
                .append("progress", getProgress())
                .append("resultRef", getResultRef())
                .append("errorMsg", getErrorMsg())
                .toString();
    }
}
