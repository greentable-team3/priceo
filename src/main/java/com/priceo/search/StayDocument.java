package com.priceo.search;

import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.Document;
import org.springframework.data.elasticsearch.annotations.Field;
import org.springframework.data.elasticsearch.annotations.FieldType;
import org.springframework.data.elasticsearch.core.geo.GeoPoint;
import lombok.Builder;
import lombok.Getter;

@Document(indexName = "stay")
@Getter
@Builder // 빌더 패턴 쓰면 데이터 옮길 때 편함
public class StayDocument {
    @Id
    private Long s_no;

    @Field(type = FieldType.Text, analyzer = "korean_analyzer")
    private String s_name;

    @Field(type = FieldType.Text, analyzer = "korean_analyzer")
    private String s_addr;

    // 엘라스틱의 geo_point랑 매핑!
    private GeoPoint location; 

    @Field(type = FieldType.Integer)
    private Integer s_view;

    @Field(type = FieldType.Keyword, index = false)
    private String s_image;
}