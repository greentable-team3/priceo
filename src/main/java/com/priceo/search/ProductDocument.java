package com.priceo.search;

import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.Document;
import org.springframework.data.elasticsearch.annotations.Field;
import org.springframework.data.elasticsearch.annotations.FieldType;
import lombok.*;

@Document(indexName = "product")
@Data // Getter, Setter 한 번에 해결
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductDocument {
    @Id
    private Long id; // 형님, 서비스에서 .id()로 호출하니까 이거 무조건 id여야 합니다.

    @Field(type = FieldType.Text, analyzer = "korean_analyzer")
    private String p_name;

    @Field(type = FieldType.Keyword)
    private String p_category;

    private Integer p_price;
    private Integer p_count;
    private String p_image;
}