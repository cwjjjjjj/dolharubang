package com.dolharubang.service;

import com.dolharubang.domain.dto.request.ContestReqDto;
import com.dolharubang.domain.dto.response.ContestResDto;
import com.dolharubang.domain.entity.Contest;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.ContestRepository;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.s3.S3UploadService;
import com.dolharubang.type.ContestFeedSortType;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
public class ContestService {

    private final ContestRepository contestRepository;
    private final MemberRepository memberRepository;
    private final S3UploadService s3UploadService;

    public ContestService(ContestRepository contestRepository, MemberRepository memberRepository,
        S3UploadService s3UploadService) {
        this.contestRepository = contestRepository;
        this.memberRepository = memberRepository;
        this.s3UploadService = s3UploadService;
    }

    @Transactional
    public ContestResDto createContest(Long memberId, ContestReqDto reqDto,
        MultipartFile imageFile) {
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        Contest contest = Contest.builder()
            .member(member)
            .isPublic(reqDto.getIsPublic())
            .stoneName(reqDto.getStoneName())
            .build();

        Contest savedContest = contestRepository.save(contest);

        // 이미지 S3에 업로드 (ID 활용해서 경로 생성)
        String imageUrl = s3UploadService.saveImage(
            imageFile,
            "dolharubang/contest/",
            savedContest.getId()
        );

        // 이미지 URL 갱신
        savedContest.updateImage(imageUrl);

        return ContestResDto.fromEntity(savedContest);
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
