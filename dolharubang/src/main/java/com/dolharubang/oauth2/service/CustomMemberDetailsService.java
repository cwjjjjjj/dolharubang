package com.dolharubang.oauth2.service;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.oauth2.model.UserPrincipal;
import com.dolharubang.repository.MemberRepository;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CustomMemberDetailsService implements UserDetailsService {

    private final MemberRepository memberRepository;

    @Override
    public UserDetails loadUserByUsername(String socialId) throws UsernameNotFoundException {
        Member member = memberRepository.findBySocialId(socialId);
        if (member == null) {
            throw new UsernameNotFoundException("Can not find with social id: " + socialId);
        }
        return UserPrincipal.create(member);
    }
}