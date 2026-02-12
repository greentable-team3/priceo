package com.priceo.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.priceo.dto.productDTO;

@Mapper
public interface productDAO {
	public List<productDTO> plistDao(@Param("p_category") String p_category); // 레시피 목록(분류에 따라)
	public productDTO pdetailDao(@Param("p_no") int p_no);
	public int pinsertDao(productDTO dto); // 상품 등록
	public void pdeleteDao(@Param("p_no") int p_no); // 상품 삭제
	public productDTO peditDao(int p_no); // 상품 수정 전 폼
	public int pupdateDao(productDTO dto); // 상품 수정 폼
	// 조회수 증가 (상세보기 시 세트로 호출하면 좋음)
    public void pviewUpDao(@Param("p_no") int p_no);
    
    // 인기순 20개 출력
    List<productDTO> getPopularList();
    
    // ⭐ [추가] 시각화 및 전체 검색을 위한 통합 데이터 조회 (엘라스틱서치 동기화용)
    List<productDTO> getTotalDataForES();
    
    // 상품 검색
    productDTO selectByNo(int p_no);
    
    List<productDTO> getOnlyProductData();
    
    List<productDTO> getOnlyStayData();
    
    // 정렬
    List<productDTO> getProductList(@Param("p_category") String p_category, @Param("sort") String sort);
}
