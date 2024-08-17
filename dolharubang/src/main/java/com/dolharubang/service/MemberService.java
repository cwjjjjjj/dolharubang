package com.dolharubang.service;

import com.dolharubang.domain.dto.request.MemberReqDto;
import com.dolharubang.domain.dto.response.MemberResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.MemberRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
public class MemberService {
    private final MemberRepository memberRepository;

    public MemberService(MemberRepository memberRepository) {
        this.memberRepository = memberRepository;
    }

    @Transactional
    public MemberResDto createMember(MemberReqDto requestDto) {
        Member member = Member.builder()
            .memberEmail(requestDto.getMemberEmail())
            .nickname(requestDto.getNickname())
            .birthday(requestDto.getBirthday())
            .sands(requestDto.getSands())
            .profilePicture((requestDto.getProfilePicture()))
            .spaceName(requestDto.getSpaceName())
            .build();

        if(member.getMemberEmail() != null){
            Member savedMember = memberRepository.save(member);
            return MemberResDto.fromEntity(savedMember);
        } else {
            System.out.println("멤버 이메일이 없심.");
            return MemberResDto.fromEntity(Member.builder().build());
        }
    }

    @Transactional
    public MemberResDto updateMember(String memberEmail, MemberReqDto requestDto) {
        Member member = memberRepository.findByEmail(memberEmail);

        if (member == null) {
            throw new CustomException(ErrorCode.MEMBER_NOT_FOUND);
        }

        member.update(
            requestDto.getNickname(),
            requestDto.getSands(),
            requestDto.getProfilePicture(),
            requestDto.getSpaceName()
        );

        return MemberResDto.fromEntity(member);
    }

    @Transactional(readOnly = true)
    public MemberResDto getMember(String memberEmail){
        Member member = memberRepository.findByEmail(memberEmail);

        return MemberResDto.fromEntity(member);
    }
}
