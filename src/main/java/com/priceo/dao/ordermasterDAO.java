package com.priceo.dao;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.priceo.dto.exchangeDTO;
import com.priceo.dto.ordermasterDTO;
import com.priceo.dto.productdetailDTO;

@Mapper
public interface ordermasterDAO {
    
    // --- 사용자 주문 관련 ---
    void orderinsertDao(ordermasterDTO dto); 
    void cartclearDao(int m_no); 
    List<Map<String, Object>> orderlistDao(int m_no);
    int insertProductDetail(productdetailDTO pdto);
    
    // --- 상세 조회 및 재고 관련 ---
    List<Map<String, Object>> getOrderDetail(int om_no);
    List<productdetailDTO> getOrderDetailItems(int om_no);
    int updateProductStock(@Param("p_no") int p_no, @Param("pd_count") int pd_count);
    int restoreProductStock(@Param("p_no") int p_no, @Param("pd_count") int pd_count);
    
    // --- 취소/교환 관련 ---
    int updateStayDetailStatus(@Param("om_no") int om_no, @Param("status") String status);
    int updateProductDetailStatus(@Param("om_no") int om_no, @Param("status") String status);
    int insertExchange(exchangeDTO edto);
    int updateOrderForExchange(int om_no);
    
    // --- 관리자 기능 (중요: 메서드명과 XML ID 일치) ---
    // 전체 주문 목록 조회
    List<Map<String, Object>> selectAllOrders();
    
    // 관리자 주문 상세 조회
    Map<String, Object> selectAdminOrderDetail(int om_no);

    // 관리자 주문 상품 목록 조회
    List<Map<String, Object>> selectAdminOrderItems(int om_no);
    
    // 관리자 상태 업데이트 (updateOrderMasterStatus와 동일한 역할이면 하나만 써도 되지만, 
    // Mapper XML에 updateOrderStatus가 있다면 아래를 사용합니다.)
    void updateProductState(@Param("om_no") int om_no, @Param("pd_state") String pd_state);
}