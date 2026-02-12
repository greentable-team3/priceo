package com.priceo.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.priceo.dao.stayCalendarDAO;
import com.priceo.dao.stayDetailDAO;
import com.priceo.dao.stayRoomDAO;
import com.priceo.dto.stayRoomDTO;
import com.priceo.service.StayCalendarService;


@Controller
public class stayRoomController {
	
	@Autowired
    private stayRoomDAO srDao;
	
	@Autowired
	private StayCalendarService calendarService;
	
	@Autowired
	private stayCalendarDAO scDao;
	
	@Autowired
    private stayDetailDAO sdDao;

    // 1. 객실 등록 폼으로 이동
    // 어떤 숙소에 방을 추가할지 알아야 하므로 s_no를 파라미터로 받습니다.
    @RequestMapping("/roomInsertForm")
    public String roomInsertForm(@RequestParam("s_no") int s_no, Model model) {
        model.addAttribute("s_no", s_no);
        return "admin/srinsertForm"; // srinsertForm.jsp
    }

    // 2. 객실 실제 등록 처리
    @RequestMapping("/roomInsert")
    public String roomInsert(stayRoomDTO dto) {
    	// 1. 객실 정보 저장
        srDao.insertRoom(dto); 
        
        // 2. 방금 생성된 객실번호(sr_no)로 2월 달력 생성 호출
        calendarService.makeFebruaryCalendar(dto.getSr_no());
        
        return "redirect:/stayDetail?s_no=" + dto.getS_no();
    }

    // 5. 객실 개별 삭제
    @RequestMapping("/roomDelete")
    @Transactional
    public String roomDelete(@RequestParam("sr_no") int sr_no, @RequestParam("s_no") int s_no) {
    	
    	// 1. 해당 객실의 예약 상세 내역(stay_detail) 삭제 
        // sr_no를 직접 받는 메서드가 없다면 새로 만들거나, 기존 mapper를 활용해야 합니다.
        sdDao.deleteStayDetailByRoom(sr_no);
    	
    	// 1. 해당 객실의 달력 데이터 삭제 (부모인 객실을 지우기 위해 자식부터 삭제)
        scDao.deleteCalendarByRoom(sr_no); 

        // 2. 객실 삭제
        srDao.deleteRoom(sr_no);
        
        // 삭제 후에도 해당 숙소 페이지에 머물기 위해 s_no가 필요함
        return "redirect:/stayDetail?s_no=" + s_no;
    }
}
