package com.priceo.dto;

import java.util.Date;

import lombok.Data;

@Data
public class ordermasterDTO {
	private int om_no;          // 주문번호 (PK)
    private int om_total;       // 총금액
    private String om_type;     // 주문유형
    private String pd_state;    // 주문상태 추가
    private Date om_date;       // 결제일
    private String om_payno;    // 결제고유번호
    private String om_addr;     // 배송지
    private String om_detail_addr; // 상세 주소 추가!
    private String om_name;     // 수신인
    private String om_tel;      // 연락처
    private String om_request;  // 요청사항
    private int m_no;           // 회원번호 (FK)
}
