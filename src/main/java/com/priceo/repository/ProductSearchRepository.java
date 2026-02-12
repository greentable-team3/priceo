package com.priceo.repository;

import java.util.List;

import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;
import org.springframework.stereotype.Repository;

import com.priceo.search.ProductDocument;

@Repository
public interface ProductSearchRepository extends ElasticsearchRepository<ProductDocument, Long> {
	List<ProductDocument> findByPNameContaining(String pName); // 이름에 포함된 단어로 검색
}