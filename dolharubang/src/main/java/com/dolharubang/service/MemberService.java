package com.dolharubang.service;

import com.dolharubang.domain.dto.request.MemberProfileReqDto;
import com.dolharubang.domain.dto.request.MemberReqDto;
import com.dolharubang.domain.dto.response.member.MemberProfileResDto;
import com.dolharubang.domain.dto.response.member.MemberResDto;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.MemberItem;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.mongo.entity.Item;
import com.dolharubang.mongo.repository.ItemRepository;
import com.dolharubang.repository.MemberItemRepository;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.s3.S3UploadService;
import java.util.List;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
public class MemberService {

    private final MemberRepository memberRepository;
    private final ItemRepository itemRepository;
    private final MemberItemRepository memberItemRepository;
    private final S3UploadService s3UploadService;

    public MemberService(MemberRepository memberRepository, ItemRepository itemRepository,
        MemberItemRepository memberItemRepository,
        S3UploadService s3UploadService) {
        this.memberRepository = memberRepository;
        this.itemRepository = itemRepository;
        this.memberItemRepository = memberItemRepository;
        this.s3UploadService = s3UploadService;
    }

    @Transactional(readOnly = true)
    public List<MemberResDto> getAllMembers() {
        List<Member> members = memberRepository.findAll();

        return members.stream()
            .map(MemberResDto::fromEntity)
            .collect(Collectors.toList());
    }

    @Transactional
    public MemberResDto createMember(MemberReqDto requestDto) {
        Member member = Member.builder()
            .memberEmail(requestDto.getMemberEmail())
            .nickname(requestDto.getNickname())
            .birthday(requestDto.getBirthday())
            .sands(requestDto.getSands())
            .spaceName(requestDto.getSpaceName())
            .build();

        Member savedMember = memberRepository.save(member);

        s3UploadService.deleteImageIfExist("dolharubang/memberProfile/", savedMember.getMemberId().toString());
        String imageUrl = s3UploadService.saveImage(requestDto.getImageBase64(),
            "dolharubang/memberProfile/", savedMember.getMemberId());
        //TODO 프로필 사진 지정 안 했을 경우 기본 프사 지정
        savedMember.updateProfilePicture(imageUrl);

        //회원 가입 시 mongoDB의 모든 아이템 목록에 대해 false로 memberItem 생성
        List<Item> items = itemRepository.findAll();

        for (Item item : items) {
            MemberItem memberItem = MemberItem.builder()
                .member(savedMember)
                .itemId(item.getItemId().toString())
                .whetherHasItem(false)
                .build();
            memberItemRepository.save(memberItem);
        }

        return MemberResDto.fromEntity(savedMember);
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
