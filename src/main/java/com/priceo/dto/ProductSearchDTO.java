package com.priceo.dto;

import lombok.Data;

@Data
public class ProductSearchDTO {

    private int p_no;
    private String p_name;
    private String p_category;
    private int p_price;
    private String p_info;
    private int p_view;
}