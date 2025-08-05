package com.dolharubang.service;

import com.dolharubang.domain.dto.response.CloverResDto;
import com.dolharubang.domain.entity.Clover;
import com.dolharubang.domain.entity.Member;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.repository.CloverRepository;
import com.dolharubang.repository.MemberRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
public class CloverService {

    private final CloverRepository cloverRepository;
    private final MemberRepository memberRepository;

    public CloverService(CloverRepository cloverRepository, MemberRepository memberRepository) {
        this.cloverRepository = cloverRepository;
        this.memberRepository = memberRepository;
    }

    @Transactional(readOnly = true)
    public CloverResDto getClover(Long id) {
        Clover clover = cloverRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.CLOVER_NOT_FOUND));

        return CloverResDto.fromEntity(clover);
    }

    @Transactional
    public CloverResDto createClover(Member sendingMember, String nickname) {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = startOfDay.plusDays(1).minusNanos(1);
        int maxCloverPerDay = 7;

        Member target = memberRepository.findByNickname(nickname)
                .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        //오늘 보낸 클로버 리스트
        List<Clover> todayClover = cloverRepository.findBySendingMemberAndCreatedAtBetween(sendingMember, startOfDay, endOfDay);
        if(todayClover.size() >= maxCloverPerDay) {
            throw new CustomException(ErrorCode.TOO_MANY_CLOVERS);
        }

        //해당 멤버에게 이미 보냈는지 확인
        boolean alreadySentToReceiver = todayClover.stream()
                .anyMatch(clover -> clover.getReceivingMember().equals(target));

        if(alreadySentToReceiver) {
            throw new CustomException(ErrorCode.ALREADY_SENT_CLOVER_TO_RECEIVER);
        }

        //7개 이하 + 해당 멤버에게 오늘 보내지 않았다면
        Clover clover = Clover.builder()
                .sendingMember(sendingMember)
                .receivingMember(target)
                .build();

        Clover saveClover = cloverRepository.save(clover);

        return CloverResDto.fromEntity(saveClover);
    }

    @Transactional(readOnly = true)
    public List<CloverResDto> getSentCloverList(Member sendingMember) {
        List<Clover> response = cloverRepository.findBySendingMember(sendingMember);

        if (response.isEmpty()) {
            throw new CustomException(ErrorCode.CLOVER_NOT_FOUND);
        }

        return response.stream()
                .map(CloverResDto::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<CloverResDto> getReceivedCloverList(Member receivedMember) {
        List<Clover> response = cloverRepository.findByReceivingMember(receivedMember);

        if (response.isEmpty()) {
            throw new CustomException(ErrorCode.CLOVER_NOT_FOUND);
        }

        return response.stream()
                .map(CloverResDto::fromEntity)
                .collect(Collectors.toList());
    }
}
