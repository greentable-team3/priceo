package com.priceo.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.priceo.dto.stayCalendarDTO;

@Mapper
public interface stayCalendarDAO {
	// 1. 특정 객실의 특정 월 예약 현황 가져오기
    List<stayCalendarDTO> selectRoomCalendar(Map<String, Object> map);

    // 2. 예약 시 상태를 'Y'로 변경
    int updateBookingStatus(Map<String, Object> map);
    
    void restoreBookingStatus(Map<String, Object> map);
    
    // 3. (관리자용) 특정 날짜의 예약 데이터 생성 (달력 초기화)
    int insertCalendarDate(stayCalendarDTO dto);
    
    void deleteCalendarByStay(int s_no);
    
    int deleteCalendarByRoom(int sr_no);
}
