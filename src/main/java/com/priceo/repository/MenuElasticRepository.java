package com.priceo.repository;

import java.util.List;

// ✅ 반드시 이 경로인지 확인 (버전에 따라 경로가 다를 수 있어)
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;
import org.springframework.stereotype.Repository; // 추가해주는 게 좋아

import com.priceo.dto.MenuDocument;

@Repository // 이 어노테이션을 붙여서 스프링이 관리하게 하자
public interface MenuElasticRepository extends ElasticsearchRepository<MenuDocument, String> {
    List<MenuDocument> findByMenuName(String menuName);
}