package com.priceo.dto;

import lombok.Data;

@Data
public class stayDetailDTO {
	private Integer sd_no;           // 예약번호 (PK)
    private String sd_name;          // 예약자명
    private String sd_checkin;       // 체크인날짜 (예: "2026-01-27")
    private String sd_checkout;      // 체크아웃날짜
    private String sd_bookingstate;  // 예약상태 (기본값 '예약완료')
    private Integer om_no;           // 주문번호 (FK - ordermaster와 연결)
    private Integer sr_no;           // 객실번호 (FK - stay_room과 연결)
}
