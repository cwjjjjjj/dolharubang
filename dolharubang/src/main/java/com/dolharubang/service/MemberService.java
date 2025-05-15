package com.dolharubang.service;

import com.dolharubang.domain.dto.request.member.MemberInfoReqDto;
import com.dolharubang.domain.dto.request.member.MemberProfileReqDto;
import com.dolharubang.domain.dto.response.member.MemberProfileResDto;
import com.dolharubang.domain.dto.response.member.MemberResDto;
import com.dolharubang.domain.dto.response.member.MemberSearchResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.FriendRepository;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.repository.StoneRepository;
import com.dolharubang.s3.S3UploadService;
import com.dolharubang.type.FriendStatusType;
import java.util.List;
import java.util.Set;
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

    public MemberService(MemberRepository memberRepository,
        S3UploadService s3UploadService, StoneRepository stoneRepository,
        FriendRepository friendRepository) {
        this.memberRepository = memberRepository;
        this.s3UploadService = s3UploadService;
        this.stoneRepository = stoneRepository;
        this.friendRepository = friendRepository;
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
        log.info("회원 프로필 사진 업데이트 서비스 시작 - 회원 ID: {}", memberId);

        Member member = findMember(memberId);
        log.info("회원 정보 조회 성공 - 이름: {}", member.getNickname());

        try {
            // 이미지 S3에 업로드 (ID 활용해서 경로 생성)
            log.info("S3 업로드 시작 - 파일명: {}", imageFile.getOriginalFilename());
            String imageUrl = s3UploadService.saveImage(
                imageFile,
                "dolharubang/memberProfile/",
                member.getMemberId()
            );
            log.info("S3 업로드 완료 - 이미지 URL: {}", imageUrl);

            // 이미지 URL 갱신
            member.updateProfilePicture(imageUrl);
            log.info("회원 프로필 이미지 URL 업데이트 완료");

            return MemberProfileResDto.fromEntity(member);
        } catch (Exception e) {
            log.error("이미지 업로드 중 오류 발생", e);
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
    public List<MemberSearchResDto> 가(Long myId, String keyword) {  // myId 파라미터 추가
        Member currentUser = memberRepository.findById(myId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        Set<Long> friendIds = friendRepository.findFriendIdsByStatus(
            currentUser,
            FriendStatusType.ACCEPTED
        );

        List<Member> members = memberRepository.findByNicknameContaining(keyword);

        return members.stream()
            .filter(member -> !member.getMemberId().equals(myId))  // 본인 제외
            .map(member -> MemberSearchResDto.fromEntity(
                member,
                friendIds.contains(member.getMemberId())  // 친구 여부 추가
            ))
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

    private boolean checkNicknameFormat(String newNickname) {
        String regex = "^[가-힣a-zA-Z0-9]+$";
        return newNickname.matches(regex);
    }

    private Member findMember(Long memberId) {
        return memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));
    }
}
