package com.priceo.dto;

import java.util.Date;
import lombok.Data;

@Data
public class PartnerApplyDTO {

    private int pa_no;
    private String pa_brand;
    private String pa_name;
    private String pa_tel;
    private String pa_email;
    private String pa_type;
    private String pa_content;
    private Date pa_date;
    private String pa_state;
}