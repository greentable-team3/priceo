package com.priceo.dto;

import lombok.Data;

@Data
public class stayRoomDTO {
	private Integer sr_no;          // 객실 번호 (PK)
    private Integer s_no;          // 숙소 번호 (FK)
    private String sr_name;         // 객실 타입명 (디럭스 등)
    private Integer sr_people; // 기준 인원
    private Integer sr_lowprice;    // 평일 가격
    private Integer sr_highprice;   // 주말 가격
}
