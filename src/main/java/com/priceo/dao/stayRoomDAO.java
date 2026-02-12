package com.priceo.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.priceo.dto.stayRoomDTO;

@Mapper
public interface stayRoomDAO {
	// 1. 객실 등록
    int insertRoom(stayRoomDTO dto);

    // 2. 특정 숙소에 속한 객실 목록 가져오기 (상세페이지용)
    List<stayRoomDTO> selectRoomsByStay(Integer s_no);

    // 3. 특정 객실 정보 보기
    stayRoomDTO selectRoomDetail(Integer sr_no);

    // 5. 객실 삭제
    int deleteRoom(Integer sr_no);
    
    // 6. 숙소 삭제 시 해당 숙소의 모든 객실 삭제
    int deleteRoomsByStay(Integer s_no);
}
