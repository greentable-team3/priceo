package com.priceo.dto;

import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.Document;
import org.springframework.data.elasticsearch.annotations.Field;
import org.springframework.data.elasticsearch.annotations.FieldType;

// createIndex = false 를 넣어서 스프링이 엘라스틱서치에 직접 명령(PUT) 내리는 걸 막습니다.
@Document(indexName = "site_menu", createIndex = false) 
public class MenuDocument {
    @Id
    private String id;

    @Field(type = FieldType.Text, analyzer = "nori")
    private String menuName; 

    private String url;

    // Getter / Setter 생략 (기존 그대로 유지)
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getMenuName() { return menuName; }
    public void setMenuName(String menuName) { this.menuName = menuName; }
    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }
}