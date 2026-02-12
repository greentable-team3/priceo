package com.priceo.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.priceo.dao.PartnerApplyDAO;
import com.priceo.dto.PartnerApplyDTO;

@Controller
@RequestMapping("/partner")
public class PartnerApplyController {

    @Autowired
    private PartnerApplyDAO dao;

    // 입점문의 폼
    @GetMapping("/partnerApply")
    public String applyForm() {
        return "user/partner/partnerApply";
    }

    // 관리자 목록
    @GetMapping("/partnerApplyList")
    public String adminList(Model model) {
        model.addAttribute("list", dao.getAllApply());
        return "admin/partnerApplyList";
    }

    // 승인 / 반려
    @PostMapping("/admin/state")
    @ResponseBody
    public void updateState(
        @RequestParam("pa_no") int pa_no,
        @RequestParam("pa_state") String pa_state
    ) {
        System.out.println("pa_no = " + pa_no);
        System.out.println("pa_state = " + pa_state);
        int r = dao.updateState(pa_no, pa_state);
        System.out.println("update result = " + r);
    }
    
    // 입점문의 폼 제출
    @PostMapping("/apply")
    public String apply(PartnerApplyDTO dto) {
        dao.insertApply(dto);   // DB 저장
        return "redirect:/partner/partnerApplySuccess";
    }
   
    // 완료 페이지
    @GetMapping("/partnerApplySuccess")
    public String success() {
        return "user/partner/partnerApplySuccess";
    }
    
    // 입점 문의 삭제
    @PostMapping("/admin/delete")
    @ResponseBody
    public void deleteApply(@RequestParam("pa_no") int pa_no) {
        System.out.println("삭제 요청 pa_no=" + pa_no);
        dao.deleteApply(pa_no);
    }
    
    // 입점 신청 상세 보기
    @GetMapping("partner/admin/partnerApplyDetail")
    	public String partnerApplyDetail(Model model,@RequestParam("pa_no") int pa_no) {
    
	    PartnerApplyDTO dto = dao.getApply(pa_no);
	    model.addAttribute("partnerApply", dto);
	    
    	return "admin/partnerApplyDetail";
    }
}