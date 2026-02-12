package com.priceo.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.priceo.dao.memberDAO;
import com.priceo.dao.productcartDAO;
import com.priceo.dto.memberDTO;
import com.priceo.dto.productcartDTO;

@Controller
public class productcartController {
   
   @Autowired
    private productcartDAO cdao;
   
   @Autowired
    private memberDAO mdao;

   @RequestMapping("/cartinsert")
    public String cartinsert(productcartDTO dto) {
        // [수정] 시큐리티에서 로그인 ID 가져오기
        String loginId = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication().getName();
        memberDTO member = mdao.getMemberByIdDao(loginId);
        
        dto.setM_no(member.getM_no()); // 실제 로그인한 유저 번호 세팅

        Integer existingPcNo = cdao.checkCartDao(dto.getM_no(), dto.getP_no());

        if (existingPcNo != null) {
            cdao.updateCartQtyDao(existingPcNo, dto.getPc_count());
        } else {
            cdao.cartinsertDao(dto);
        }
        return "redirect:/cartlist";
    }

    @RequestMapping("/cartlist")
    public String cartlist(Model model) {
        // [수정] 임시 번호 1 삭제 -> 실제 로그인 유저 번호 가져오기
        String loginId = SecurityContextHolder.getContext().getAuthentication().getName();
        memberDTO member = mdao.getMemberByIdDao(loginId);
        
        // 해당 유저의 장바구니만 조회
        model.addAttribute("clist", cdao.cartlistDao(member.getM_no()));
        return "user/productcart/cartlist"; 
    }
    
    @RequestMapping("/cartdelete")  // 장바구니 항목 삭제
    public String cartdelete(@RequestParam("pc_no") int pc_no) {
        cdao.cartdeleteDao(pc_no);
        return "redirect:/cartlist";
    }
    
    @RequestMapping("/cartupdate") // 장바구니 항목 수량 수정
    public String cartupdate(productcartDTO dto) {
        cdao.cartupdateDao(dto);
        return "redirect:/cartlist";
    }
}
