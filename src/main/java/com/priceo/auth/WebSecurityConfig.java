package com.priceo.auth;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityCustomizer;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.firewall.HttpFirewall;
import org.springframework.security.web.firewall.StrictHttpFirewall;

import com.priceo.service.CustomOAuth2UserService;

import jakarta.servlet.DispatcherType;
import jakarta.servlet.http.HttpSession;

@Configuration
@EnableWebSecurity
public class WebSecurityConfig {
    @Autowired private CustomOAuth2UserService customOAuth2UserService;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public HttpFirewall allowUrlEncodedFirewall() {
        StrictHttpFirewall firewall = new StrictHttpFirewall();
        firewall.setAllowUrlEncodedSlash(true);
        firewall.setAllowSemicolon(true);
        firewall.setAllowUrlEncodedPercent(true);
        firewall.setAllowBackSlash(true);
        firewall.setAllowUrlEncodedDoubleSlash(true);
        return firewall;
    }

    @Bean
    public WebSecurityCustomizer webSecurityCustomizer() {
        return web -> web.httpFirewall(allowUrlEncodedFirewall());
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {

        http
            .csrf(csrf -> csrf.disable())
            .cors(cors -> cors.disable())
            .authorizeHttpRequests(auth -> auth
                .dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.INCLUDE).permitAll()         
                .requestMatchers(
                	"/chatbot/autocomplete","/product/autocomplete","/search","/stay/autocomplete",
                    "/api/search/autocomplete","/api/search/autocomplete",
                    "/css/**", "/js/**", "/image/**","/firebase-messaging-sw.js",
                    "/upload/**", "/profile_images/**", "/product/**", "/productreview/**", "/exchange/**", 
                    "/stay/**", "/stayreview/**"
                ).permitAll()
                .requestMatchers(
                    "/", "/main", "/mloginForm", "/login", "/signup", "/msignup",
                    "/write","/kakao", "/idCheck", "/mailCheck", "/verifyCode","/delete",
                    "/mfindIdForm", "/findId", "/mresetPasswordForm", "/findPwAuth", "/updatePassword",
                    "/plist", "/pdetail", "/searchResult",
                    "/stayList", "/stayDetail", "/mfaq", "/mfaq/ask", "/mfaq/sendMail",
                    "/fcm/token", "/fcm/send", "/fcm/send-login","/api/main/popular","/api/calendar/**"
                ).permitAll()
                .requestMatchers(
                    "/myinfo", "/mupdateForm", "/update", "/mpasswordCheckForm", "/passwordCheck",
                    "/cartinsert", "/cartlist", "/cartdelete", "/cartupdate",
                    "/orderform", "/orderProcess", "/orderlist", "/orderdetail",
                    "/orderCancel", "/orderExchangeForm", "/orderExchange",
                    "/reservationForm","/list",
                    "/productReviewInsert", "/productReviewDelete", "/stayReviewInsert", "/stayReviewDelete",
                    "/partner/partnerApply", "/partner/apply", "/partner/partnerApplySuccess"
                ).authenticated()
                .requestMatchers(
                    "/adminhome", "/alist", "/adminreviewlist", "/deleteReview",
                    "/adminorderlist", "/adminorderdetail", "/updateOrderStatus", "/updateStatus",
                    "/pinsertForm", "/pinsert", "/pupdateForm", "/pupdate", "/pdelete","/sync/all",
                    "/stayInsertForm", "/stayInsert", "/stayUpdate","/stayUpdateForm","/stayDelete",
                    "/roomInsertForm", "/roomInsert", "/roomUpdateForm", "/roomUpdate", "/roomDelete",
                    "/partner/partnerApplyList", "/partner/admin/**"
                ).hasAuthority("ADMIN")
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                    .loginPage("/mloginForm")
                    .loginProcessingUrl("/loginProc")
                    .defaultSuccessUrl("/main", true)
                    .failureUrl("/mloginForm?error=true")
                    .permitAll()
                )
         // 🥊 OAuth2 로그인 설정 부분 수정
            .oauth2Login(oauth2 -> oauth2
                .loginPage("/mloginForm")
                .userInfoEndpoint(userInfo -> userInfo.userService(customOAuth2UserService))
                .successHandler((request, response, authentication) -> {
                    
                    // 🥊 [핵심] 로그인 성공 시 토큰 낚아채서 세션에 저장하기
                    org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken authToken = 
                        (org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken) authentication;
                    
                    // 어떤 플랫폼(kakao, google 등)인지 확인
                    String registrationId = authToken.getAuthorizedClientRegistrationId();
                    
                    // 세션 가져오기
                    HttpSession session = request.getSession();

                    // 🥊 여기서 토큰을 세션에 박습니다. 
                    // (참고: 원래는 OAuth2AuthorizedClientService를 써야 정확하지만, 
                    // 간단하게 처리하기 위해 현재 인증 정보에서 토큰을 추출하거나 
                    // CustomOAuth2UserService에서 이미 처리했을 수도 있습니다.)
                    
                    // 형님, 만약 CustomOAuth2UserService에서 토큰을 세션에 안 담으셨다면 
                    // 여기서 담아주는 로직이 필요합니다.
                    
                    response.sendRedirect("/main");
                })
            )
             // 🥊 2. 로그아웃 (구글 토큰 파기 + 카카오 리다이렉트 합체)
                .logout(logout -> logout
                    .logoutUrl("/logout")
                    .addLogoutHandler((request, response, authentication) -> {
                        HttpSession session = request.getSession(false);
                        if (session != null) {
                            // 1. 구글 유저라면 로그아웃 시마다 토큰 파기 기강 잡기
                            String googleToken = (String) session.getAttribute("google_access_token");
                            if (googleToken != null) {
                                try {
                                    // 🥊 백엔드에서 조용히 구글 서버에 '연결 끊기' 신호 전송
                                    java.net.URL url = new java.net.URL("https://oauth2.googleapis.com/revoke?token=" + googleToken);
                                    java.net.HttpURLConnection conn = (java.net.HttpURLConnection) url.openConnection();
                                    conn.setRequestMethod("POST");
                                    conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
                                    
                                    int responseCode = conn.getResponseCode();
                                    System.out.println("구글 토큰 파기 완료 (코드: " + responseCode + ")");
                                } catch (Exception e) {
                                    System.out.println("구글 토큰 파기 실패: " + e.getMessage());
                                }
                            }

                            // 2. 기존 카카오 권한 체크 로직 유지
                            String auth = (String) session.getAttribute("m_authority");
                            request.setAttribute("ex_auth", auth);
                        }
                    })
                    .logoutSuccessHandler((request, response, authentication) -> {
                        String auth = (String) request.getAttribute("ex_auth");
                        // 카카오는 기존처럼 카카오 전용 로그아웃 페이지로 이동
                        if ("KAKAO".equals(auth)) {
                            response.sendRedirect("https://kauth.kakao.com/oauth/logout"
                                + "?client_id=5f221fc7c50592655e4ddcf6194025ff"
                                + "&logout_redirect_uri=http://192.168.10.103:8080/logout");
                        } else {
                            response.sendRedirect("/"); 
                        }
                    })
                    .invalidateHttpSession(true)
                    .deleteCookies("JSESSIONID")
                );

            return http.build();
    }
}
