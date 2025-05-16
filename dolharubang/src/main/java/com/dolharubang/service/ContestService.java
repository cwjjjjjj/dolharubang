package com.dolharubang.service;

import com.dolharubang.domain.dto.request.ContestReqDto;
import com.dolharubang.domain.dto.response.ContestResDto;
import com.dolharubang.domain.entity.Contest;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.Stone;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.ContestRepository;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.repository.StoneRepository;
import com.dolharubang.s3.S3UploadService;
import com.dolharubang.type.ContestFeedSortType;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
public class ContestService {

    private final ContestRepository contestRepository;
    private final MemberRepository memberRepository;
    private final StoneRepository stoneRepository;
    private final S3UploadService s3UploadService;

    public ContestService(ContestRepository contestRepository, MemberRepository memberRepository,
        StoneRepository stoneRepository, S3UploadService s3UploadService) {
        this.contestRepository = contestRepository;
        this.memberRepository = memberRepository;
        this.stoneRepository = stoneRepository;
        this.s3UploadService = s3UploadService;
    }

    @Transactional
    public ContestResDto createContest(Long memberId, ContestReqDto reqDto,
        MultipartFile imageFile) {
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        Stone stone = stoneRepository.findById(reqDto.getStoneId())
            .orElseThrow(() -> new CustomException(ErrorCode.STONE_NOT_FOUND));

        // 1. 소유권 확인 (옵션: member가 stone을 소유했는지 체크)
        if (!stone.getMember().getMemberId().equals(memberId)) {
            throw new CustomException(ErrorCode.STONE_OWNERSHIP_MISMATCH);
        }

        // 2. 일일 생성 가능 여부 체크
        LocalDateTime startOfDay = LocalDateTime.now().truncatedTo(ChronoUnit.DAYS);
        int count = contestRepository.countTodayContestByMemberAndStone(member, stone, startOfDay);

        if (count >= 1) {
            throw new CustomException(ErrorCode.DAILY_CONTEST_LIMIT_EXCEEDED);
        }

        // 3. Contest 생성
        Contest contest = Contest.builder()
            .member(member)
            .stone(stone)
            .isPublic(reqDto.getIsPublic())
            .build();

        Contest savedContest = contestRepository.save(contest);

        // 4. 이미지 업로드 (ID 확보 후 진행)
        String imageUrl = s3UploadService.saveImage(
            imageFile,
            "dolharubang/contest/",
            savedContest.getId()
        );
        savedContest.updateImage(imageUrl);

        return ContestResDto.fromEntity(savedContest);
    }

    // 생성 가능 여부 체크 메서드
    public boolean checkEligibility(Long memberId, Long stoneId) {
        // 1. 멤버 & 돌 조회
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));
        Stone stone = stoneRepository.findById(stoneId)
            .orElseThrow(() -> new CustomException(ErrorCode.STONE_NOT_FOUND));

        // 2. 소유권 확인 (내 돌인지 체크)
        if (!stone.getMember().getMemberId().equals(memberId)) {
            throw new CustomException(ErrorCode.STONE_OWNERSHIP_MISMATCH);
        }

        // 3. 오늘 생성한 기록 있는지 확인
        LocalDateTime startOfDay = LocalDateTime.now().truncatedTo(ChronoUnit.DAYS);
        return contestRepository.countTodayContestByMemberAndStone(member, stone, startOfDay) == 0;
    }


    @Transactional(readOnly = true)
    public List<ContestResDto> getMyAllContestProfiles(Long memberId) {
        List<Contest> contest = contestRepository.findAllByMember(
            memberRepository.findById(memberId)
                .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND)));
        if (contest.isEmpty()) {
            throw new CustomException(ErrorCode.CONTEST_NOT_FOUND_BY_MEMBER);
        }
        return contest.stream()
            .map(ContestResDto::fromEntity)
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public ContestResDto getContestProfile(Long memberId, Long contestId) {
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        Contest contest = contestRepository.findByIdAndMember(contestId, member)
            .orElseThrow(() -> new CustomException(ErrorCode.CONTEST_MEMBER_MISMATCH));

        return ContestResDto.fromEntity(contest);
    }

    @Transactional
    public ContestResDto updateContestVisibility(Long memberId, Long contestId, Boolean isPublic) {
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        Contest contest = contestRepository.findByIdAndMember(contestId, member)
            .orElseThrow(() -> new CustomException(ErrorCode.CONTEST_MEMBER_MISMATCH));

        contest.updateContestVisibility(isPublic);

        return ContestResDto.fromEntity(contest);
    }

    @Transactional
    public void deleteContest(Long memberId, Long contestId) {
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        Contest contest = contestRepository.findByIdAndMember(contestId, member)
            .orElseThrow(() -> new CustomException(ErrorCode.CONTEST_MEMBER_MISMATCH));

        contestRepository.delete(contest);
    }

    @Transactional(readOnly = true)
    public List<ContestResDto> getFeedContests(Long memberId, Long lastContestId,
        ContestFeedSortType contestFeedSortType, int size) {
        List<Contest> contests = switch (contestFeedSortType) {
            case RECOMMENDED ->
                contestRepository.findFeedContestsWithWeight(memberId, lastContestId, size);
            case LATEST -> contestRepository.findLatestContests(lastContestId, size);
        };

        if (contests.isEmpty()) {
            throw new CustomException(ErrorCode.CONTEST_NOT_FOUND);
        }

        return contests.stream()
            .map(ContestResDto::fromEntity)
            .collect(Collectors.toList());
    }

}
