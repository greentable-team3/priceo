package com.priceo.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.priceo.dto.productcartDTO;

@Mapper
public interface productcartDAO {
    public void cartinsertDao(productcartDTO dto); // 장바구니 담기 
    public List<productcartDTO> cartlistDao(int m_no); // 장바구니 목록 
    public void cartdeleteDao(int pc_no); // 장바구니 항목 삭제
    public void cartupdateDao(productcartDTO dto); // 장바구니 수량 수정
    
    // 1. 이미 담긴 상품인지 확인 (존재하면 pc_no 반환, 없으면 null/0)
    public Integer checkCartDao(@Param("m_no") int m_no, @Param("p_no") int p_no);
    
    // 2. 기존 상품 수량 합치기 (기존 수량 + 새 수량)
    public void updateCartQtyDao(@Param("pc_no") int pc_no, @Param("pc_count") int pc_count);
    

}
