package com.priceo.dto;

import lombok.Data;

@Data
public class imagefileDTO {
	private Integer i_no;           // 파일번호 (PK)
    private Integer i_referenceno;  // 참조번호 (숙소번호 s_no 또는 상품번호)
    private String i_referencetype; // 참조유형 (예: 'stay', 'product')
    private String i_originalfile;  // 원본파일명
    private String i_savefile;      // 저장파일명 (UUID가 포함된 실제 파일명)
    private String i_root;          // 파일경로 (예: C:/stay/)
}
