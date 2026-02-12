package com.priceo.controller;

import java.security.Principal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import com.priceo.dao.memberDAO;
import com.priceo.dao.productcartDAO;
import com.priceo.dto.memberDTO;
import com.priceo.dto.productcartDTO;

import jakarta.servlet.http.HttpSession;

@ControllerAdvice // 모든 컨트롤러에 공통적으로 적용되는 설정
public class GlobalControllerAdvice {

    @Autowired
    private productcartDAO cdao;

    @Autowired
    private memberDAO mdao;

    @ModelAttribute // 모든 페이지 요청 시 이 메서드가 먼저 실행됨
    public void addCartCount(Principal principal, HttpSession session) {
        if (principal != null) {
            // 1. 현재 로그인한 사용자 정보 가져오기
            String loginId = principal.getName();
            memberDTO member = mdao.getMemberByIdDao(loginId);
            
            if (member != null) {
                // 2. DB에서 해당 사용자의 장바구니 항목 개수 조회
                List<productcartDTO> list = cdao.cartlistDao(member.getM_no());
                
                // 3. 세션에 담기 (header.jsp에서 ${cartTypeCount}로 사용 가능)
                session.setAttribute("cartTypeCount", list.size());
            }
        } else {
            // 로그아웃 상태면 개수를 0으로 설정
        	session.removeAttribute("cartTypeCount");
        }
    }
}