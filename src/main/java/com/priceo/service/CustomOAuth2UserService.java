package com.priceo.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.DefaultOAuth2User;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import com.priceo.dao.memberDAO;
import com.priceo.dto.memberDTO;

import jakarta.servlet.http.HttpSession;

@Service
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    @Autowired
    private memberDAO dao;
    
    @Autowired
    private HttpSession session;

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);
        String registrationId = userRequest.getClientRegistration().getRegistrationId();
        
        // 🥊 [기강 잡기] 액세스 토큰 낚아채서 세션에 저장
        String accessToken = userRequest.getAccessToken().getTokenValue();
        if ("kakao".equals(registrationId)) {
            session.setAttribute("kakao_access_token", accessToken);
        } else if ("google".equals(registrationId)) {
            session.setAttribute("google_access_token", accessToken);
        } else if ("naver".equals(registrationId)) {
            session.setAttribute("naver_access_token", accessToken);
        }

        Map<String, Object> attributes = oAuth2User.getAttributes();
        
        String mid = "";
        String nickname = "";
        String name = "";
        String email = "";
        String tel = "010-0000-0000"; 
        String addr = "";
        String authority = "";

        if ("naver".equals(registrationId)) {
            Map<String, Object> response = (Map<String, Object>) attributes.get("response");
            mid = (String) response.get("id");
            nickname = (String) response.get("nickname");
            name = (String) response.get("name"); 
            email = (String) response.get("email");
            tel = (String) response.get("mobile");
            addr = "네이버 가입자";
            authority = "NAVER";
        } else if ("kakao".equals(registrationId)) {
            Map<String, Object> kakaoAccount = (Map<String, Object>) attributes.get("kakao_account");
            Map<String, Object> profile = (Map<String, Object>) kakaoAccount.get("profile");
            mid = attributes.get("id").toString();
            nickname = (profile != null) ? (String) profile.get("nickname") : "카카오유저";
            name = nickname;
            email = (kakaoAccount != null) ? (String) kakaoAccount.get("email") : "이메일미제공";
            addr = "카카오 가입자";
            authority = "KAKAO";
        } else if ("google".equals(registrationId)) {
            mid = (String) attributes.get("sub");
            nickname = (String) attributes.get("name");
            name = (String) attributes.get("name");
            email = (String) attributes.get("email");
            addr = "구글 가입자";
            authority = "GOOGLE";
        }

        memberDTO member = dao.findByMid(mid);
        if (member == null) {
            member = new memberDTO();
            member.setM_id(mid);
            member.setM_passwd("OAUTH2_USER");
            member.setM_name(name);        
            member.setM_nickname(nickname); 
            member.setM_email(email);
            member.setM_addr(addr);
            member.setM_tel(tel);           
            member.setM_authority(authority); 

            if ("NAVER".equals(authority)) {
                dao.naverSignup(member);
            } else {
                dao.kakaoSignup(member);
            }
        }
        
        session.setAttribute("loginMember", member); 
        session.setAttribute("m_id", member.getM_id());
        session.setAttribute("m_nickname", member.getM_nickname());
        session.setAttribute("m_authority", member.getM_authority());
        
        List<GrantedAuthority> authorities = AuthorityUtils.createAuthorityList(member.getM_authority());
        Map<String, Object> finalAttributes = new HashMap<>(attributes);
        finalAttributes.put("m_id", mid); 

        return new DefaultOAuth2User(authorities, finalAttributes, "m_id");
    }
}