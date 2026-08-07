package com.book.novel.domain;

import java.util.ArrayList;
import java.util.List;

/**
 * Architecture version diff result for frontend display.
 *
 * @author book
 */
public class ArchitectureDiffResult
{
    private Long leftVersionId;

    private Long rightVersionId;

    private Integer leftVersionNo;

    private Integer rightVersionNo;

    private List<DiffLine> lines = new ArrayList<>();

    public Long getLeftVersionId()
    {
        return leftVersionId;
    }

    public void setLeftVersionId(Long leftVersionId)
    {
        this.leftVersionId = leftVersionId;
    }

    public Long getRightVersionId()
    {
        return rightVersionId;
    }

    public void setRightVersionId(Long rightVersionId)
    {
        this.rightVersionId = rightVersionId;
    }

    public Integer getLeftVersionNo()
    {
        return leftVersionNo;
    }

    public void setLeftVersionNo(Integer leftVersionNo)
    {
        this.leftVersionNo = leftVersionNo;
    }

    public Integer getRightVersionNo()
    {
        return rightVersionNo;
    }

    public void setRightVersionNo(Integer rightVersionNo)
    {
        this.rightVersionNo = rightVersionNo;
    }

    public List<DiffLine> getLines()
    {
        return lines;
    }

    public void setLines(List<DiffLine> lines)
    {
        this.lines = lines;
    }

    public static class DiffLine
    {
        /** equal | insert | delete | change */
        private String type;

        private String left;

        private String right;

        public DiffLine()
        {
        }

        public DiffLine(String type, String left, String right)
        {
            this.type = type;
            this.left = left;
            this.right = right;
        }

        public String getType()
        {
            return type;
        }

        public void setType(String type)
        {
            this.type = type;
        }

        public String getLeft()
        {
            return left;
        }

        public void setLeft(String left)
        {
            this.left = left;
        }

        public String getRight()
        {
            return right;
        }

        public void setRight(String right)
        {
            this.right = right;
        }
    }
}
