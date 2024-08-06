package com.dolharubang.service;

import com.dolharubang.domain.dto.request.MembersReqDto;
import com.dolharubang.domain.dto.response.MembersResDto;
import com.dolharubang.domain.entity.Members;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.MembersRepository;
import jakarta.transaction.Transactional;

public class MemberService {
    private final MembersRepository membersRepository;

    public MemberService(MembersRepository membersRepository) {
        this.membersRepository = membersRepository;
    }

    @Transactional
    public MembersResDto createMember(MembersReqDto requestDto) {
        Members member = Members.builder()
            .memberEmail(requestDto.getMemberEmail())
            .nickname(requestDto.getNickname())
            .birthday(requestDto.getBirthday())
            .sands(requestDto.getSands())
            .profilePicture((requestDto.getProfilePicture()))
            .spaceName(requestDto.getSpaceName())
            .build();

        Members savedMember = membersRepository.save(member);
        return MembersResDto.fromEntity(savedMember);
    }

    @Transactional
    public MembersResDto updateMember(String memberEmail, MembersReqDto requestDto) {
        Members member = membersRepository.findByEmail(memberEmail);
//            .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        if (member == null) {
            throw new CustomException(ErrorCode.MEMBER_NOT_FOUND);
        }

        member.update(
            requestDto.getNickname(),
            requestDto.getSands(),
            requestDto.getProfilePicture(),
            requestDto.getSpaceName()
        );

        return MembersResDto.fromEntity(member);
    }
}
