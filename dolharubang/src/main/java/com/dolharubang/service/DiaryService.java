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
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
    public DiaryResDto createDiary(Member member, DiaryReqDto diaryReqDto) {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = startOfDay.plusDays(1).minusNanos(1);

        Optional<Diary> todayDiary = diaryRepository.findByMemberAndCreatedAtBetween(member, startOfDay, endOfDay);
        if(todayDiary.isPresent()) {
            throw new CustomException(ErrorCode.DIARY_ALREADY_EXISTS);
        }

        Diary diary = Diary.builder()
            .member(member)
            .contents(diaryReqDto.getContents())
            .emoji(diaryReqDto.getEmoji())
            .build();

        Diary savedDiary = diaryRepository.save(diary);
        if(diaryReqDto.getImageBase64() != null) {
            String imageUrl = s3UploadService.saveImage(diaryReqDto.getImageBase64(),
                "dolharubang/diary/", savedDiary.getDiaryId());
            savedDiary.updateImageUrl(imageUrl);
        }

        return DiaryResDto.fromEntity(savedDiary);
    }

    //TODO 일기 수정 기능에 제한 필요
    @Transactional
    public DiaryResDto updateDiary(Long memberId, Long id, DiaryReqDto diaryReqDto) {
        Diary diary = diaryRepository.findByDiaryId(id)
            .orElseThrow(() -> new CustomException(ErrorCode.DIARY_NOT_FOUND));

        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        String imageUrl = diaryReqDto.getImageBase64();
        if(diaryReqDto.getImageBase64() != null) {
            s3UploadService.deleteImageIfExist("dolharubang/diary/", id.toString());
        }

        diary.update(
            member,
            diaryReqDto.getContents(),
            diaryReqDto.getEmoji(),
            imageUrl,
            diary.getReply()
        );

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
