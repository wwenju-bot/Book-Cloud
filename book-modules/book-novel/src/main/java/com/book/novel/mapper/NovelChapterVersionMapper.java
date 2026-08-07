package com.book.novel.mapper;

import java.util.List;
import com.book.novel.domain.NovelChapterVersion;

/**
 * Chapter version mapper, table novel_chapter_version.
 *
 * @author book
 */
public interface NovelChapterVersionMapper
{
    NovelChapterVersion selectVersionById(Long versionId);

    List<NovelChapterVersion> selectVersionsByChapterId(Long chapterId);

    Integer selectMaxVersionNo(Long chapterId);

    Integer selectMaxOptimizeRound(Long chapterId);

    int insertVersion(NovelChapterVersion version);

    int updateVersion(NovelChapterVersion version);
}
