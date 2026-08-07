package com.book.novel.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.book.novel.domain.NovelReviewRecord;

/**
 * Review record mapper, table novel_review_record.
 *
 * @author book
 */
public interface NovelReviewRecordMapper
{
    int insertRecord(NovelReviewRecord record);

    List<NovelReviewRecord> selectByTarget(@Param("targetType") String targetType, @Param("targetId") Long targetId);
}
