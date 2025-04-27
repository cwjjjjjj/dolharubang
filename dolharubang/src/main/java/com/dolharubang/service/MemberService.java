package com.dolharubang.service;

import com.dolharubang.domain.dto.request.member.MemberInfoReqDto;
import com.dolharubang.domain.dto.request.member.MemberProfileReqDto;
import com.dolharubang.domain.dto.response.member.MemberProfileResDto;
import com.dolharubang.domain.dto.response.member.MemberResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.s3.S3UploadService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
public class MemberService {

    private final MemberRepository memberRepository;
    private final S3UploadService s3UploadService;

    public MemberService(MemberRepository memberRepository,
        S3UploadService s3UploadService) {
        this.memberRepository = memberRepository;
        this.s3UploadService = s3UploadService;
    }

    @Transactional
    public MemberProfileResDto updateMemberProfile(Long memberId, MemberProfileReqDto requestDto) {
        Member member = findMember(memberId);

        member.update(
            requestDto.getNickname(),
            requestDto.getSpaceName()
        );

        return MemberProfileResDto.fromEntity(member);
    }

    @Transactional
    public MemberProfileResDto updateMemberProfilePicture(Long memberId,
        String imageBase64) {
        Member member = findMember(memberId);

        String imageUrl = s3UploadService.saveImage(imageBase64,
            "dolharubang/memberProfile/", memberId);
        member.updateProfilePicture(imageUrl);

        return MemberProfileResDto.fromEntity(member);
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

    private Member findMember(Long memberId) {
        return memberRepository.findById(memberId)
            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));
    }
}
