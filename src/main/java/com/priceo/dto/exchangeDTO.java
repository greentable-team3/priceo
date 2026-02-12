package com.priceo.dto;

import lombok.Data;

@Data
public class exchangeDTO {
	private int e_no;         // 교환 번호 (PK)
    private String e_reason;  // 교환 사유 (Not Null)
    private String e_image;   // 이미지 (선택)
    private String e_state;   // 상태여부 (기본값: 교환접수)
    private int om_no;        // 주문번호 (FK)
}
