package com.dolharubang.service;

import com.dolharubang.domain.dto.request.member.MemberInfoReqDto;
import com.dolharubang.domain.dto.request.member.MemberProfileReqDto;
import com.dolharubang.domain.dto.response.member.MemberProfileResDto;
import com.dolharubang.domain.dto.response.member.MemberResDto;
import com.dolharubang.domain.dto.response.member.MemberSearchResDto;
import com.dolharubang.domain.entity.Friend;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.ContestRepository;
import com.dolharubang.repository.DiaryRepository;
import com.dolharubang.repository.FriendRepository;
import com.dolharubang.repository.MemberItemRepository;
import com.dolharubang.repository.MemberMissionRepository;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.repository.NotificationRepository;
import com.dolharubang.repository.RefreshTokenRepository;
import com.dolharubang.repository.ScheduleRepository;
import com.dolharubang.repository.StoneRepository;
import com.dolharubang.s3.S3UploadService;
import com.dolharubang.type.FriendStatusType;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Slf4j
@Service
public class MemberService {

    private final MemberRepository memberRepository;
    private final S3UploadService s3UploadService;
    private final StoneRepository stoneRepository;
    private final FriendRepository friendRepository;
    private final ContestRepository contestRepository;
    private final DiaryRepository diaryRepository;
    private final MemberItemRepository memberItemRepository;
    private final MemberMissionRepository memberMissionRepository;
    private final NotificationRepository notificationRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final ScheduleRepository scheduleRepository;

    public MemberService(MemberRepository memberRepository,
        S3UploadService s3UploadService,
        StoneRepository stoneRepository,
        FriendRepository friendRepository, ContestRepository contestRepository,
        DiaryRepository diaryRepository, MemberItemRepository memberItemRepository,
        MemberMissionRepository memberMissionRepository, NotificationRepository notificationRepository,
        RefreshTokenRepository refreshTokenRepository, ScheduleRepository scheduleRepository) {
        this.memberRepository = memberRepository;
        this.s3UploadService = s3UploadService;
        this.stoneRepository = stoneRepository;
        this.friendRepository = friendRepository;
        this.contestRepository = contestRepository;
        this.diaryRepository = diaryRepository;
        this.memberItemRepository = memberItemRepository;
        this.memberMissionRepository = memberMissionRepository;
        this.notificationRepository = notificationRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.scheduleRepository = scheduleRepository;
    }

    @Transactional
    public MemberProfileResDto updateMemberProfile(Long memberId, MemberProfileReqDto requestDto) {
        Member member = findMember(memberId);

        if (!checkNicknameFormat(requestDto.getNickname())) {
            throw new CustomException(ErrorCode.INVALID_NICKNAME_FORMAT);
        }

        if (!checkNicknameDuplication(requestDto.getNickname(), member.getNickname())) {
            throw new CustomException(ErrorCode.DUPLICATE_NICKNAME);
        }

        member.update(
            requestDto.getNickname(),
            requestDto.getSpaceName()
        );

        return MemberProfileResDto.fromEntity(member);
    }

    @Transactional
    public MemberProfileResDto updateMemberProfilePicture(Long memberId, MultipartFile imageFile) {

        Member member = findMember(memberId);
        try {
            // 이미지 S3에 업로드 (ID 활용해서 경로 생성)
            String imageUrl = s3UploadService.saveImage(
                imageFile,
                "dolharubang/memberProfile/",
                member.getMemberId()
            );

            member.updateProfilePicture(imageUrl);
            return MemberProfileResDto.fromEntity(member);
        } catch (Exception e) {
            throw e;
        }
    }

    @Transactional
    public MemberProfileResDto addMemberInfo(Long memberId, MemberInfoReqDto requestDto) {
        Member member = findMember(memberId);

        member.addInfo(
            requestDto.getNickname(),
            requestDto.getBirthday()
        );

        return MemberProfileResDto.fromEntity(member);
    }

    @Transactional(readOnly = true)
    public MemberResDto getMember(Long memberId) {
        Member member = findMember(memberId);
        return MemberResDto.fromEntity(member);
    }

    @Transactional(readOnly = true)
    public MemberProfileResDto getMemberProfile(Long memberId) {
        Member member = findMember(memberId);
        return MemberProfileResDto.fromEntity(member);
    }

    @Transactional(readOnly = true)
    public int getSands(Long memberId) {
        Member member = findMember(memberId);
        return member.getSands();
    }

    @Transactional(readOnly = true)
    public List<MemberSearchResDto> searchMember(Long myId, String keyword) {
        Member currentUser = memberRepository.findById(myId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        // 1. 검색 결과 회원 목록
        List<Member> members = memberRepository.findByNicknameContaining(keyword)
            .stream()
            .filter(member -> !member.getMemberId().equals(myId)) // 본인 제외
            .collect(Collectors.toList());

        // 2. 검색 결과 회원 ID 리스트
        List<Long> searchMemberIds = members.stream()
            .map(Member::getMemberId)
            .collect(Collectors.toList());

        // 3. 이 중에서 나와의 관계만 한 번에 조회
        List<Friend> relations = friendRepository.findRelationsWithMembers(myId, searchMemberIds);

        // 4. 관계 맵핑 (memberId -> Friend)
        Map<Long, Friend> relationMap = new HashMap<>();
        for (Friend f : relations) {
            Long otherId = f.getRequester().getMemberId().equals(myId)
                ? f.getReceiver().getMemberId()
                : f.getRequester().getMemberId();
            relationMap.put(otherId, f);
        }

        // 5. DTO 변환
        return members.stream()
            .map(member -> {
                Friend relation = relationMap.get(member.getMemberId());
                boolean isFriend = false;
                boolean isRequested = false;
                boolean isReceived = false;

                if (relation != null) {
                    if (relation.getStatus() == FriendStatusType.ACCEPTED) {
                        isFriend = true;
                    } else if (relation.getStatus() == FriendStatusType.PENDING) {
                        // 내가 요청자면 isRequested, 내가 수신자면 isReceived
                        if (relation.getRequester().getMemberId().equals(myId)) {
                            isRequested = true;
                        } else {
                            isReceived = true;
                        }
                    }
                }

                return MemberSearchResDto.fromEntity(
                    member,
                    isFriend,
                    isRequested,
                    isReceived
                );
            })
            .collect(Collectors.toList());
    }


    @Transactional(readOnly = true)
    public boolean checkNicknameDuplication(String newNickname, String originalNickname) {
        if (originalNickname != null & originalNickname.equals(newNickname)) {
            return true;
        }

        return memberRepository.findByNickname(newNickname).isEmpty();
    }

    @Transactional(readOnly = true)
    public boolean isStoneEmpty(Member member) {
        return stoneRepository.findByMember(member).isEmpty();
    }

    @Transactional
    public boolean deleteMember(Long memberId) {
        Member member = findMember(memberId);
        deleteMemberObjects(member);
        memberRepository.delete(member);
        return memberRepository.findById(memberId).isEmpty();
    }

    @Transactional
    public void deleteMemberObjects(Member member) {
        scheduleRepository.deleteAllByMember(member);
        refreshTokenRepository.deleteAllByMember(member);
        notificationRepository.deleteAllByReceiverId(member.getMemberId());
        notificationRepository.deleteAllByRequester(member);
        memberMissionRepository.deleteAllByMember(member);
        memberItemRepository.deleteAllByMember(member);
        diaryRepository.deleteAllByMember(member);
        contestRepository.deleteAllByMember(member);
        stoneRepository.deleteAllByMember(member);
        friendRepository.deleteAllByReceiver(member);
        friendRepository.deleteAllByRequester(member);
    }

    private boolean checkNicknameFormat(String newNickname) {
        String regex = "^[가-힣a-zA-Z0-9]+$";
        return newNickname.matches(regex);
    }

    private Member findMember(Long memberId) {
        return memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));
    }
}
