package com.priceo.dto;


import lombok.Data;

@Data
public class productDTO {
	private int p_no;
	private String p_category;
	private String p_name;
	private int p_price;
	private int p_count;
	private int p_view;
	private String p_image;	
	
	private int id;         // p_no 또는 s_no 담기용
    private String name;    // p_name 또는 s_name 담기용
    private String type;    // 'PRODUCT' 또는 'STAY' 구분용
    
    // [핵심] 이 필드가 있어야 쿼리의 'thumb' 데이터를 받아옵니다.
    private String thumb; 
    
    // 혹시 모르니 아래 필드도 추가해두면 안전합니다.
    private String s_image;
    private String es_id;   // ⭐ [추가] 엘라스틱서치 저장용 고유 ID (예: PRODUCT_1)
}
