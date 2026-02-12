package com.priceo.dto;

import java.util.Date;

import lombok.Data;

@Data
public class stayCalendarDTO {
	private Integer sc_no;      // 달력일정번호 (PK)
    private Date sc_date;       // 날짜
    private String sc_booking;  // 예약여부 (예: 'Y', 'N')
    private Integer sr_no;      // 객실번호 (FK)
}
