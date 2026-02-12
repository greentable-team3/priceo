package com.priceo.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.priceo.dto.stayDTO;

@Mapper
public interface stayDAO {
	// 1. 숙소 등록 (Insert)
    int insertStay(stayDTO dto);

    // 2. 숙소 전체 보기 (Select List)
    List<stayDTO> selectStayList();

    // 3. 숙소 상세보기 (Select One)
    stayDTO selectStayDetail(Integer s_no);

    // 4. 숙소 수정 (Update)
    int updateStay(stayDTO dto);

    // 5. 숙소 삭제 (Delete)
    int deleteStay(Integer s_no);
    
    // 추가: 조회수 증가 (Update)
    int updateViewCount(Integer s_no);
    
    // 숙소 목록 가져오기 (정렬 값 포함)
    List<stayDTO> getStayList(@Param("sort") String sort);
}
