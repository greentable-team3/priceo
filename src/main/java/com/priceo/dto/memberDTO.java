package com.priceo.dto;

import lombok.Data;


@Data
public class memberDTO {
	private String fcm_token;
	private int m_no;
	private String m_id;
	private String m_passwd;
	private String m_name;
	private String m_nickname;
	private String m_tel;
	private String m_addr;
	private String m_email;
	private String m_authority;
	public String getFcm_token() {
	    return fcm_token;
	}
	public void setFcm_token(String fcm_token) {
	    this.fcm_token = fcm_token;
	}
}
