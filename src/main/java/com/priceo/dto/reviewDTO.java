package com.priceo.dto;

import java.util.List;

import lombok.Data;

@Data
public class reviewDTO {
	private Integer r_no;          // 리뷰 번호
    private String r_score;    // 별점
    private int r_typeno;      // 항목 번호 (상품 번호)
    private String r_type;     // 항목 구분
    private String r_review;   // 리뷰 내용
    private Integer m_no;          // 회원 번호
    
    // [중요] DB 테이블에는 없지만, 조회 시 해당 리뷰의 사진들을 담아두기 위한 필드
    private List<imagefileDTO> reviewImages;
    private String m_nickname;
    private String m_name;
}
