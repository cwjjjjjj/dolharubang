package com.dolharubang.oauth2.model;

import com.dolharubang.domain.entity.Member;
import java.util.Collection;
import java.util.Collections;
import java.util.Map;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.oauth2.core.oidc.OidcIdToken;
import org.springframework.security.oauth2.core.oidc.OidcUserInfo;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.security.oauth2.core.user.OAuth2User;

@Getter
@Setter
@RequiredArgsConstructor
public class UserPrincipal implements OAuth2User, UserDetails, OidcUser {

    private final Long memberId;
    private final String password;
    private final Role role;
    private final Collection<GrantedAuthority> authorities;
    private Map<String, Object> attributes; //사용자 추가정보

    @Override
    public Map<String, Object> getAttributes() {
        return attributes;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getUsername() {
        return memberId.toString();
    }

    @Override
    public String getName() {
        return memberId.toString();
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }

    @Override
    public Map<String, Object> getClaims() {
        return null;
    }

    @Override
    public OidcUserInfo getUserInfo() {
        return null;
    }

    @Override
    public OidcIdToken getIdToken() {
        return null;
    }

    public static UserPrincipal create(Member member) {
        return new UserPrincipal(
            member.getMemberId(),
            null,
            Role.USER,
            Collections.singletonList(new SimpleGrantedAuthority(Role.USER.getKey()))
        );
    }

    public static UserPrincipal create(Member member, Map<String, Object> attributes) {
        UserPrincipal userPrincipal = create(member);
        userPrincipal.setAttributes(attributes);

        return userPrincipal;
    }
}
