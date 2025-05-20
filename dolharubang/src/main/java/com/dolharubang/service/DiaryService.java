package com.dolharubang.service;

import com.dolharubang.domain.dto.request.DiaryReqDto;
import com.dolharubang.domain.dto.response.DiaryResDto;
import com.dolharubang.domain.entity.Diary;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.DiaryRepository;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.s3.S3UploadService;
import com.dolharubang.type.DeleteTarget;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Slf4j
@Service
public class DiaryService {

    private final DiaryRepository diaryRepository;
    private final MemberRepository memberRepository;
    private final S3UploadService s3UploadService;

    public DiaryService(DiaryRepository diaryRepository, MemberRepository memberRepository,
        S3UploadService s3UploadService) {
        this.diaryRepository = diaryRepository;
        this.memberRepository = memberRepository;
        this.s3UploadService = s3UploadService;
    }

    @Transactional
    public DiaryResDto createDiary(Member member, DiaryReqDto diaryReqDto,
        MultipartFile imageFile) {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = startOfDay.plusDays(1).minusNanos(1);
        int maxDiariesPerDay = 1;

        List<Diary> todayDiary = diaryRepository.findAllByMemberAndCreatedAtBetween(member,
            startOfDay, endOfDay);
        if (todayDiary.size() >= maxDiariesPerDay) {
            throw new CustomException(ErrorCode.TOO_MANY_DIARIES);
        }

        Diary diary = Diary.builder()
            .member(member)
            .contents(diaryReqDto.getContents())
            .emoji(diaryReqDto.getEmoji())
            .build();

        Diary savedDiary = diaryRepository.save(diary);
        if (imageFile != null && !imageFile.isEmpty()) {
            String imageUrl = s3UploadService.saveImage(
                imageFile,
                "dolharubang/diary/",
                savedDiary.getDiaryId()
            );

            // 이미지 URL 갱신
            savedDiary.updateImageUrl(imageUrl);
        }

        return DiaryResDto.fromEntity(savedDiary);
    }

    //TODO 일기 수정 기능에 제한 필요
    @Transactional
    public DiaryResDto updateDiary(Long memberId, Long id, DiaryReqDto diaryReqDto,
        MultipartFile imageFile) {
        Diary diary = diaryRepository.findByDiaryId(id)
            .orElseThrow(() -> new CustomException(ErrorCode.DIARY_NOT_FOUND));

        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        String imageUrl = s3UploadService.saveImage(
            imageFile,
            "dolharubang/diary/",
            diary.getDiaryId()
        );

        diary.update(
            member,
            diaryReqDto.getContents(),
            diaryReqDto.getEmoji(),
            imageUrl,
            diary.getReply()
        );

        return DiaryResDto.fromEntity(diary);
    }

    @Transactional
    public DiaryResDto partialDeleteDiary(Long memberId, Long id, DeleteTarget deleteTarget) {
        Diary diary = diaryRepository.findByDiaryId(id)
            .orElseThrow(() -> new CustomException(ErrorCode.DIARY_NOT_FOUND));

        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        switch (deleteTarget) {
            case CONTENT:
                diary.update(member, null, diary.getEmoji(), diary.getImageUrl(), diary.getReply());
                break;
            case EMOJI:
                diary.update(member, diary.getContents(), null, diary.getImageUrl(), diary.getReply());
                break;
            case IMAGE:
                diary.update(member, diary.getContents(), diary.getEmoji(), null, diary.getReply());
                break;
            default:
                throw new CustomException(ErrorCode.INVALID_DELETE_TARGET);
        }

        if (diary.getContents() == null & diary.getEmoji() == null & diary.getImageUrl() == null) {
            deleteDiary(diary.getDiaryId());
        }

        return DiaryResDto.fromEntity(diary);
    }

    @Transactional(readOnly = true)
    public DiaryResDto getDiary(Long id) {
        Diary diary = diaryRepository.findByDiaryId(id)
            .orElseThrow(() -> new CustomException(ErrorCode.DIARY_NOT_FOUND));

        return DiaryResDto.fromEntity(diary);
    }

    @Transactional(readOnly = true)
    public List<DiaryResDto> getDiaryListByMemberId(Long memberId) {
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        List<Diary> response = diaryRepository.findAllByMember(member);

        if (response.isEmpty()) {
            throw new CustomException(ErrorCode.DIARY_NOT_FOUND);
        }

        return response.stream()
            .map(DiaryResDto::fromEntity)
            .collect(Collectors.toList());
    }

    @Transactional
    public void deleteDiary(Long id) {
        Diary diary = diaryRepository.findByDiaryId(id)
            .orElseThrow(() -> new CustomException(ErrorCode.DIARY_NOT_FOUND));

        diaryRepository.delete(diary);
    }
}
