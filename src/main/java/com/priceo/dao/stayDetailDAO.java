package com.priceo.dao;

import org.apache.ibatis.annotations.Mapper;

import com.priceo.dto.stayDetailDTO;

@Mapper
public interface stayDetailDAO {
	// 숙소 예약 상세 내역 저장
    int insertStayDetail(stayDetailDTO dto);
    
    // 예약 번호로 상세 내역 조회 (나중에 내역 보기용)
    stayDetailDTO selectStayDetail(int om_no);
    
    void deleteStayDetailByStay(int s_no);
    
    void deleteStayDetailByRoom(int sr_no); // 객실 번호로 예약 내역 삭제
}
