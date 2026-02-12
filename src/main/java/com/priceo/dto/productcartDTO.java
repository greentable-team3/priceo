package com.priceo.dto;

import lombok.Data;

@Data
public class productcartDTO {
	// 1. 테이블 정의서 기반 필수 컬럼
    private int pc_no;       // 상품카트 번호 (PK)
    private int pc_count;    // 항목갯수 (수량, Not Null)
    private int m_no;        // 회원 번호 (FK)
    private int p_no;        // 상품 번호 (FK)
    
    // 2. 화면 출력을 위해 추가로 필요한 필드 (상품 정보 Join용)
    private String p_name;    // 상품 이름
    private int p_price;      // 상품 단가
    private String p_image;   // 상품 이미지
}
