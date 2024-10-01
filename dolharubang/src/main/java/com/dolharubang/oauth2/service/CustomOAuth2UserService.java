package com.dolharubang.oauth2.service;

import com.dolharubang.domain.entity.Member;
import com.dolharubang.exception.CustomException;
import com.dolharubang.exception.ErrorCode;
import com.dolharubang.oauth2.info.OAuth2UserInfo;
import com.dolharubang.oauth2.info.OAuth2UserInfoFactory;
import com.dolharubang.oauth2.model.Role;
import com.dolharubang.oauth2.model.UserPrincipal;
import com.dolharubang.repository.MemberRepository;
import java.time.LocalDateTime;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.authentication.InternalAuthenticationServiceException;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    private final MemberRepository memberRepository;

    //구글 로그인 버튼 클릭 -> 구글 로그인창 -> 로그인 완료 -> code를 리턴(OAuth-Clien라이브러리가 받아줌) -> code를 통해서 AcssToken요청(access토큰 받음)
    //OAuth2-client 라이브러리가 code단계 처리후 OAuth2UserRequest객체에 엑세스 토큰, 플랫폼 사용자 고유 key값을 반환해준다.

    @Override
    public OAuth2User loadUser(OAuth2UserRequest oAuth2UserRequest) throws OAuth2AuthenticationException {

        OAuth2User oAuth2User = super.loadUser(oAuth2UserRequest); //oauth에서 가져온 user 정보

        try {
            return process(oAuth2UserRequest, oAuth2User);//인증된 사용자 정보
        } catch (AuthenticationException ex) {//인증 예외
            throw ex;
        } catch (Exception ex) {
            ex.printStackTrace();
            throw new InternalAuthenticationServiceException(ex.getMessage(), ex.getCause());//일반 예외 - 시스템 문제로 내부 인증 관련 처리 요청 x
        }
    }

    protected OAuth2User process(OAuth2UserRequest oAuth2UserRequest, OAuth2User oAuth2User) {

        //플렛폼 별 사용자 추가정보
        OAuth2UserInfo oAuth2UserInfo = OAuth2UserInfoFactory.getOAuth2UserInfo(oAuth2User.getAttributes());

        Member savedMember = memberRepository.findBySocialId(oAuth2UserInfo.getId());

        //가입된 경우
//        if(savedMember != null) {
//            updateUser(Optional.of(savedMember), oAuth2UserInfo);
//        }

        //미가입 경우
//        else {
            savedMember = registerMember(oAuth2UserInfo);
//        }
        return UserPrincipal.create(savedMember, oAuth2User.getAttributes());
    }

    private Member registerMember(OAuth2UserInfo oauth2UserInfo) {

        Member member = Member.builder()
            .socialId(oauth2UserInfo.getId())
            .memberEmail(oauth2UserInfo.getEmail())
            .sands(0L)
            .role(Role.USER)
            .lastLoginAt(LocalDateTime.now())
            .totalLoginDays(0L)
            .build();

        return memberRepository.save(member);
    }

//    private Member updateUser(Member savedMember, OAuth2UserInfo oAuth2UserInfo) {
//        // 이름이 다르다면 업데이트
//        if (oAuth2UserInfo.getEmail() != null && !savedMember.getEmail().equals(oAuth2UserInfo.getEmail())) {
//            savedMember.setUsername(oAuth2UserInfo.getName());
//        }
//
//        // 변경 사항을 저장
//        return memberRepository.save(savedMember);
//    }
}
