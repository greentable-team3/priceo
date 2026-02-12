package com.priceo.repository;

import java.util.List;

import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;
import org.springframework.stereotype.Repository;

import com.priceo.search.StayDocument;

@Repository
public interface StaySearchRepository extends ElasticsearchRepository<StayDocument, Long> {
    // 여기에 메서드 이름을 findBySName 이런 식으로 지으면 자동 검색 쿼리가 생겨!
	List<StayDocument> findBySNameContaining(String sName); // 숙소명 검색
	
}