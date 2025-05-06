package com.dolharubang.service;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.domain.entity.MemberItem;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.MemberItemRepository;
import com.dolharubang.repository.MemberRepository;
import com.dolharubang.type.RewardType;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

@Service
@Transactional
public class RewardService {

    private final MemberItemRepository memberItemRepository;
    private final MemberRepository memberRepository;

    public RewardService(MemberItemRepository memberItemRepository,
        MemberRepository memberRepository) {
        this.memberItemRepository = memberItemRepository;
        this.memberRepository = memberRepository;
    }

    public void giveReward(Member member, RewardType type, int quantity, Long itemNo) {
        switch (type) {
            case SAND -> giveSandReward(member, quantity);
            case ITEM -> giveItemReward(member, itemNo);
            default -> throw new CustomException(ErrorCode.INVALID_REWARD_TYPE);
        }
    }

    private void giveSandReward(Member member, int quantity) {
        // ToDo: 멤버에서 모래 증가시키는 함수
//        member.increaseSands(quantity);
        memberRepository.save(member);
    }

    private void giveItemReward(Member member, Long itemNo) {
        // 해당 아이템이 있는 아이템인지 먼저 조회
        if (memberItemRepository.existsByMemberAndItemId(member, itemNo)) {
            throw new CustomException(ErrorCode.ALREADY_HAVE_ITEM);
        }

        // 아이템 지급 로직
        MemberItem memberItem = MemberItem.builder()
            .member(member)
            .itemId(itemNo)
            .whetherHasItem(true)
            .build();
        memberItemRepository.save(memberItem);
    }
}
