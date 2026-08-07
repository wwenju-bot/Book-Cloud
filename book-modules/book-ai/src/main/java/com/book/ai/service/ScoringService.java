package com.book.ai.service;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import com.book.ai.domain.ScoreRequest;
import com.book.ai.domain.ScoreResult;

/**
 * Rule-based chapter candidate scoring (length + keyword coverage + sensitive words).
 * Model self-review scoring can be layered on later.
 *
 * @author book
 */
@Service
public class ScoringService
{
    private static final int DEFAULT_TARGET_LENGTH = 2500;

    private static final Pattern CJK_NAME = Pattern.compile("[\\u4e00-\\u9fff]{2,6}");

    /** Lightweight sensitive lexicon (demo). */
    private static final String[] SENSITIVE_WORDS = {
            "\u653f\u5e9c\u654f\u611f", "\u8272\u60c5", "\u66b4\u529b\u8840\u8165", "\u81ea\u6740\u6559\u7a0b"
    };

    public ScoreResult score(ScoreRequest request)
    {
        String content = request == null || request.getContent() == null ? "" : request.getContent();
        String architecture = request == null || request.getArchitectureContent() == null
                ? "" : request.getArchitectureContent();
        int target = request != null && request.getTargetLength() != null && request.getTargetLength() > 0
                ? request.getTargetLength() : DEFAULT_TARGET_LENGTH;

        int length = countMeaningfulChars(content);
        int lengthScore = scoreLength(length, target);
        List<String> keywords = extractKeywords(architecture);
        int keywordScore = scoreKeywords(content, keywords);
        int sensitiveScore = scoreSensitive(content);

        int total = Math.max(0, Math.min(100, lengthScore + keywordScore + sensitiveScore));

        ScoreResult result = new ScoreResult();
        result.setScore(total);
        result.setLengthScore(lengthScore);
        result.setKeywordScore(keywordScore);
        result.setSensitiveScore(sensitiveScore);
        result.setContentLength(length);
        result.getDetails().put("targetLength", target);
        result.getDetails().put("keywords", keywords);
        result.getDetails().put("matchedKeywords", matchedKeywords(content, keywords));
        return result;
    }

    private int countMeaningfulChars(String content)
    {
        if (!StringUtils.hasText(content))
        {
            return 0;
        }
        int n = 0;
        for (int i = 0; i < content.length(); i++)
        {
            char c = content.charAt(i);
            if (!Character.isWhitespace(c))
            {
                n++;
            }
        }
        return n;
    }

    private int scoreLength(int length, int target)
    {
        if (length <= 0)
        {
            return 0;
        }
        double ratio = (double) length / target;
        if (ratio >= 0.8 && ratio <= 1.3)
        {
            return 40;
        }
        if (ratio >= 0.5 && ratio < 0.8)
        {
            return 25;
        }
        if (ratio > 1.3 && ratio <= 1.8)
        {
            return 30;
        }
        if (ratio > 0.2)
        {
            return 15;
        }
        return 5;
    }

    private List<String> extractKeywords(String architecture)
    {
        Set<String> set = new LinkedHashSet<>();
        if (!StringUtils.hasText(architecture))
        {
            return new ArrayList<>();
        }
        String[] lines = architecture.split("\\R");
        for (String line : lines)
        {
            String trimmed = line.trim();
            if (trimmed.isEmpty() || trimmed.startsWith("---"))
            {
                continue;
            }
            boolean focus = trimmed.contains("\u4eba\u7269") || trimmed.contains("\u89d2\u8272")
                    || trimmed.contains("\u5730\u70b9") || trimmed.contains("\u5730\u540d")
                    || trimmed.contains("\u4e16\u754c") || trimmed.startsWith("#")
                    || trimmed.startsWith("-") || trimmed.startsWith("*");
            if (!focus && set.size() >= 8)
            {
                continue;
            }
            Matcher matcher = CJK_NAME.matcher(trimmed);
            while (matcher.find() && set.size() < 20)
            {
                String name = matcher.group();
                if (name.length() >= 2 && !isStopWord(name))
                {
                    set.add(name);
                }
            }
        }
        return new ArrayList<>(set);
    }

    private boolean isStopWord(String word)
    {
        String[] stops = {
                "\u4eba\u7269", "\u89d2\u8272", "\u5730\u70b9", "\u4e16\u754c\u89c2", "\u7ae0\u8282",
                "\u5927\u7eb2", "\u63cf\u8ff0", "\u5185\u5bb9", "\u4e3b\u89d2", "\u914d\u89d2"
        };
        for (String s : stops)
        {
            if (s.equals(word))
            {
                return true;
            }
        }
        return false;
    }

    private int scoreKeywords(String content, List<String> keywords)
    {
        if (keywords.isEmpty())
        {
            return 20;
        }
        int matched = matchedKeywords(content, keywords).size();
        double ratio = (double) matched / keywords.size();
        if (ratio >= 0.5)
        {
            return 40;
        }
        if (ratio >= 0.25)
        {
            return 25;
        }
        if (matched > 0)
        {
            return 15;
        }
        return 5;
    }

    private List<String> matchedKeywords(String content, List<String> keywords)
    {
        List<String> matched = new ArrayList<>();
        if (!StringUtils.hasText(content))
        {
            return matched;
        }
        for (String kw : keywords)
        {
            if (content.contains(kw))
            {
                matched.add(kw);
            }
        }
        return matched;
    }

    private int scoreSensitive(String content)
    {
        if (!StringUtils.hasText(content))
        {
            return 20;
        }
        String lower = content.toLowerCase(Locale.ROOT);
        for (String word : SENSITIVE_WORDS)
        {
            if (lower.contains(word.toLowerCase(Locale.ROOT)))
            {
                return 0;
            }
        }
        return 20;
    }
}
