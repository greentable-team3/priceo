package com.priceo.dto;

import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.Document;
import lombok.Data;

@Data
@Document(indexName = "stay") // [표식] stayDTO가 아닌 'stay' 인덱스 강제 지정
public class stayDTO {
    @Id
	private Integer s_no;          // 숙소 번호 (PK)
    private String s_name;         // 숙소명
    private String s_addr;         // 숙소위치
    private Double s_lat;          // 위도 (12, 8)
    private Double s_long;         // 경도 (12, 8)
    private Integer s_view = 0;    // 조회수 (기본값 0)
    private String s_image;        // 이미지
    private Integer min_price; // DB 조인으로 가져올 최저가 저장용 (테이블엔 없지만 DTO엔 필요)
}