package com.book.novel.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.book.novel.domain.NovelChapter;

/**
 * Chapter mapper, table novel_chapter.
 *
 * @author book
 */
public interface NovelChapterMapper
{
    NovelChapter selectChapterById(Long chapterId);

    NovelChapter selectChapterByProjectIdAndNo(@Param("projectId") Long projectId, @Param("chapterNo") Integer chapterNo);

    List<NovelChapter> selectChaptersByProjectId(Long projectId);

    int insertChapter(NovelChapter chapter);

    int updateChapter(NovelChapter chapter);
}
