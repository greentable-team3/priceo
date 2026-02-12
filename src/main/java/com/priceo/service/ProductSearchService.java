package com.priceo.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.elasticsearch.client.elc.NativeQuery;
import org.springframework.data.elasticsearch.core.ElasticsearchOperations;
import org.springframework.data.elasticsearch.core.SearchHits;
import org.springframework.data.elasticsearch.core.mapping.IndexCoordinates;
import org.springframework.stereotype.Service;

import com.priceo.dto.ProductSearchDTO;

@Service
public class ProductSearchService {

    @Autowired
    private ElasticsearchOperations elasticsearchOperations;

    /* 1. 통합 검색 */
    public List<ProductSearchDTO> search(String keyword) {
        NativeQuery query = NativeQuery.builder()
            .withQuery(qBuilder -> qBuilder
                .multiMatch(mm -> mm
                    .query(keyword)
                    .fields("p_name^2", "p_info") // 이름에 가중치 부여
                )
            )
            .build();

        SearchHits<Map> hits = elasticsearchOperations.search(query, Map.class, IndexCoordinates.of("product"));
        
        return hits.getSearchHits().stream().map(hit -> {
            Map<String, Object> map = hit.getContent();
            ProductSearchDTO dto = new ProductSearchDTO();
            dto.setP_no(map.get("p_no") != null ? Integer.parseInt(map.get("p_no").toString()) : 0);
            dto.setP_name(map.get("p_name") != null ? map.get("p_name").toString() : "");
            dto.setP_price(map.get("p_price") != null ? Integer.parseInt(map.get("p_price").toString()) : 0);
            return dto;
        }).collect(Collectors.toList());
    }

    /* 2. 자동완성 */
    public List<String> autocomplete(String q) {
        if (q == null || q.trim().isEmpty()) return new ArrayList<>();

        NativeQuery query = NativeQuery.builder()
            .withQuery(qBuilder -> qBuilder
                .bool(b -> b
                    .should(s -> s.matchPhrasePrefix(mpp -> mpp.field("p_name").query(q)))
                    .should(s -> s.term(t -> t.field("p_name.keyword").value(q).boost(2.0f)))
                )
            )
            .withPageable(PageRequest.of(0, 10))
            .build();

        SearchHits<Map> hits = elasticsearchOperations.search(query, Map.class, IndexCoordinates.of("product"));
        
        return hits.getSearchHits().stream()
                   .map(hit -> hit.getContent().get("p_name"))
                   .filter(name -> name != null)
                   .map(Object::toString)
                   .distinct()
                   .collect(Collectors.toList());
    }
}