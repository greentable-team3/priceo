package com.priceo.service;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.priceo.dao.stayCalendarDAO;
import com.priceo.dto.stayCalendarDTO;

@Service
public class StayCalendarService {

    @Autowired
    private stayCalendarDAO calendarDao;

    // 1. 객실 등록 시 3월 달력 데이터 생성
    @Transactional
    public void makeFebruaryCalendar(int sr_no) {
        Calendar cal = Calendar.getInstance();
        
        for (int i = 1; i <= 31; i++) {
            cal.set(2026, Calendar.MARCH, i); // 2026년 3월 i일
            
            stayCalendarDTO dto = new stayCalendarDTO();
            dto.setSr_no(sr_no);
            dto.setSc_date(cal.getTime());
            dto.setSc_booking("N"); // 초기값: 예약 가능
            
            calendarDao.insertCalendarDate(dto);
        }
    }

    // 2. FullCalendar 전용 데이터 가공 (JSON용)
    public List<Map<String, Object>> getCalendarEvents(int sr_no, String startDate, String endDate) {
    	Map<String, Object> params = new HashMap<>();
        params.put("sr_no", sr_no);
        
        // 한 줄로 정리 (문자열이 길면 자르고, 아니면 그대로 유지)
        params.put("startDate", (startDate != null && startDate.length() >= 10) ? startDate.substring(0, 10) : startDate);
        params.put("endDate", (endDate != null && endDate.length() >= 10) ? endDate.substring(0, 10) : endDate);

        List<stayCalendarDTO> list = calendarDao.selectRoomCalendar(params);
        List<Map<String, Object>> events = new ArrayList<>();
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");

        for (stayCalendarDTO dto : list) {
            if (dto.getSc_date() == null) continue; // 최소한의 안전장치만 유지
            
            Map<String, Object> event = new HashMap<>();
            event.put("start", sdf.format(dto.getSc_date())); 
            
            // 상태값에 따른 설정을 변수로 처리하면 더 깔끔합니다.
            boolean isBooked = "Y".equals(dto.getSc_booking());
            event.put("title", isBooked ? "예약불가" : "예약가능");
            event.put("color", isBooked ? "#ff4d4d" : "#28a745");
            event.put("display", "block"); 
            
            events.add(event);
        }
        return events;
    }
}