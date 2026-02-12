package com.priceo.controller;

import java.util.Map;

import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.priceo.dao.memberDAO;
import com.priceo.dto.memberDTO;
import com.priceo.service.PushService;

import jakarta.servlet.http.HttpSession;


@RestController
@RequestMapping("/fcm")
public class pushController {

    private final PushService pushService;
    private final memberDAO dao;

    public pushController(PushService pushService, memberDAO dao) {
        this.pushService = pushService;
        this.dao = dao;
    }
    
    

    // FCM 토큰 저장 (이게 없어서 안 됐던 거다)
    @PostMapping("/token")
    public void saveToken(@RequestBody Map<String, String> map, Authentication authentication) {
        System.out.println("/fcm/token 호출됨");

        String token = map.get("token");

        // 1. 시큐리티에서 현재 로그인한 유저의 ID(getName) 가져오기
        if (authentication == null) {
            System.out.println("인증 정보 없음 (로그아웃 상태)");
            return;
        }
        
        String loginId = authentication.getName(); // 네이버/카카오는 이메일 혹은 고유 ID가 나옵니다.
        System.out.println("현재 로그인된 ID: " + loginId);

        // 2. ID로 DB에서 m_no 조회하기
        memberDTO member = dao.getMemberByIdDao(loginId);

        if (member == null) {
            System.out.println("DB에 해당 유저 정보가 없음");
            return;
        }

        // 3. 드디어 m_no와 token으로 저장!
        System.out.println("m_no = " + member.getM_no());
        System.out.println("token = " + token);

        dao.saveFcmToken(member.getM_no(), token);
        System.out.println("FCM 토큰 DB 저장 완료!");
    }

    // 테스트용 푸시
    // pushController.java 파일 수정

    @GetMapping("/send")
    public void sendTest(HttpSession session) {
        // 1. 세션에서 로그인 정보 가져오기
        memberDTO login = (memberDTO) session.getAttribute("loginMember");
        if (login == null) {
            System.out.println("❌ [테스트 실패] 로그인이 안 되어 있습니다.");
            return;
        }

        // 2. DB에서 내 토큰 가져오기
        String token = dao.getFcmToken(login.getM_no());
        
        // 3. 테스트용 상품 번호 (형님 사이트에 실제로 있는 상품 번호 아무거나 하나 넣으세요)
        int testPno = 1; // <- 여기에 실제 있는 p_no 하나만 써보세요!
        
        System.out.println("🚀 [테스트] " + testPno + "번 상품으로 이동하는 알림 발송!");

        // 4. 푸시 발송 (인자 6개 확인!)
        pushService.sendPush(
            login.getM_no(), 
            token, 
            "테스트 알림", 
            "클릭하면 " + testPno + "번 상품으로 갑니다!", 
            null,    // 이미지 주소 (일단 비움)
            testPno  // 이게 p_no로 들어갑니다.
        );
    }
}