package com.priceo.dto;

import lombok.Data;

@Data
public class productdetailDTO {
	private int pd_no;      // 상세번호 (PK)
    private int pd_count;   // 구매수량
    private String pd_state; // 주문상태 (Default: 결제완료)
    private int om_no;      // 주문번호 (FK)
    private int p_no;       // 상품번호 (FK)
}
