package com.priceo.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.priceo.dto.reviewDTO;

@Mapper
public interface reviewDAO {
	// 특정 타입(STAY/PRODUCT)에 따른 리스트 조회
    List<reviewDTO> rlistByType(@Param("r_typeno") int r_typeno, @Param("r_type") String r_type);
    
    public void rinsertDao(reviewDTO dto); 
    
    // 특정 리뷰 1개 삭제 (사용자용)
    public void rdeleteDao(int r_no);
    
    // 특정 타입의 특정 번호에 해당하는 모든 리뷰 삭제 (숙소/상품 삭제 시 호출)
    void deleteReviewsByItem(@Param("r_typeno") int r_typeno, @Param("r_type") String r_type);
    
    // 삭제 전 파일명을 알아내기 위해 리뷰 정보 조회
    reviewDTO getReviewDetail(int r_no);
    
    List<Map<String, Object>> getAllReviews();
    
    // 1. 페이징 처리를 위한 리스트 가져오기
    // XML에서 #{start}, #{end}를 인식할 수 있게 @Param 어노테이션을 붙여주는 게 좋습니다.
    List<reviewDTO> getListWithPaging(@Param("start") int start, @Param("end") int end);

    // 2. 전체 리뷰 개수 가져오기
    int getTotalCount();
    
    List<reviewDTO> getReviewList();
    
    // 특정 상품/숙소에 달린 모든 리뷰 번호를 가져오는 메서드 추가
    List<Integer> getReviewNosByItem(@Param("type") String type, @Param("no") int no);
}
