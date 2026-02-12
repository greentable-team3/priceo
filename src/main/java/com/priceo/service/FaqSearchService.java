package com.priceo.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.elasticsearch.client.elc.NativeQuery;
import org.springframework.data.elasticsearch.core.ElasticsearchOperations;
import org.springframework.data.elasticsearch.core.SearchHit;
import org.springframework.data.elasticsearch.core.SearchHits;
import org.springframework.data.elasticsearch.core.mapping.IndexCoordinates;
import org.springframework.data.elasticsearch.core.query.Query;
import org.springframework.data.elasticsearch.core.query.StringQuery;
import org.springframework.stereotype.Service;

@Service
public class FaqSearchService {

    @Autowired
    private ElasticsearchOperations elasticsearchOperations;

    /* =========================
       1. 상품 검색 (수정: 중복 제거 및 .auto 적용)
       ========================= */
    public Map<String, Object> searchProducts(String keyword) {
        Map<String, Object> result = new HashMap<>();
        try {
            // 상품도 auto 필드를 fuzziness AUTO로 검색!
            String jsonQuery = String.format(
                "{\"match\": {\"p_name.auto\": {\"query\": \"%s\", \"fuzziness\": \"AUTO\"}}}", 
                keyword
            );

            Query query = new StringQuery(jsonQuery);
            SearchHits<Map> hits = elasticsearchOperations.search(query, Map.class, IndexCoordinates.of("product"));

            List<Map<String, Object>> list = hits.stream()
                    .map(hit -> (Map<String, Object>) hit.getContent())
                    .toList();
            result.put("products", list);

            // 오타 교정 판단 (예: "후로이드" -> "후라이드")
            if (!list.isEmpty()) {
                String topName = list.get(0).get("p_name").toString();
                if (!topName.contains(keyword)) {
                    result.put("message", topName);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return result;
    }

    /* =========================
    2. 숙소 검색 (stay 인덱스) - 한 글자 검색 지원
    ========================= */
    public Map<String, Object> searchStaysWithSmartFeedback(String keyword) {
        Map<String, Object> result = new HashMap<>();
        try {
            String jsonQuery = String.format(
                "{\"match\": {\"s_name.auto\": {\"query\": \"%s\", \"fuzziness\": \"AUTO\"}}}", 
                keyword
            );

            Query query = new StringQuery(jsonQuery);
            SearchHits<Map> hits = elasticsearchOperations.search(query, Map.class, IndexCoordinates.of("stay"));

            List<Map<String, Object>> list = hits.stream().map(hit -> (Map<String, Object>) hit.getContent()).toList();
            result.put("stays", list);

            if (!list.isEmpty()) {
                String topName = list.get(0).get("s_name").toString();
                double topScore = hits.getSearchHit(0).getScore();

                // 🥊 1. 교정 완료: 점수가 매우 높고 오타가 확실할 때
                if (topScore > 10.0 && !topName.contains(keyword)) {
                    result.put("message", "\"" + topName + "\" (으)로 검색한 결과입니다.");
                } 
                // 🥊 2. 검색어 제안: 결과가 있긴 한데 오타일 확률이 있을 때 (Did you mean?)
                else if (!topName.contains(keyword)) {
                    result.put("suggestion", "\"" + topName + "\" (으)로 검색하시겠습니까?");
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return result;
    }

	 /* =========================
	 3. 메뉴 / 기능 검색 (로그인 상태 필터링 추가)
	 ========================= */
    public Map<String, String> searchMenuDetail(String keyword, boolean isLogin) {
        try {
            // 🥊 1. menuName.auto 필드 사용 + 오탈자(fuzziness) 적용
            String jsonQuery = String.format(
                "{\"match\": {\"menuName.auto\": {\"query\": \"%s\", \"fuzziness\": \"AUTO\"}}}", 
                keyword
            );
            
            System.out.println(">>> [ES 메뉴 검색] 쿼리: " + jsonQuery);
            
            Query query = new StringQuery(jsonQuery);
            SearchHits<Map> hits = elasticsearchOperations.search(
                    query, Map.class, IndexCoordinates.of("site_menu"));

            if (hits.hasSearchHits()) {
                Map<String, Object> src = hits.getSearchHit(0).getContent();
                
                // [필터링 로직 - 기존 유지]
                String show = (src.get("show") != null) ? src.get("show").toString() : "all";
                String menuName = src.get("menuName").toString();

                // 로그인/비로그인 권한 필터링
                if (isLogin && "guest".equals(show)) return null; 
                if (!isLogin && "user".equals(show)) return null;

                Map<String, String> result = new HashMap<>();
                result.put("menuName", menuName);
                result.put("url", src.get("url").toString());
                result.put("message", "찾으시는 **" + menuName + "** 페이지를 발견했습니다! 😊");
                return result;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    /* =========================
       4. 상품 자동완성 API용 (추가)
       ========================= */
    public List<String> autocomplete(String q) {
        List<String> suggestions = new ArrayList<>();
        try {
            String jsonQuery = "{\"match\": {\"p_name.auto\": \"" + q + "\"}}";
            Query query = new StringQuery(jsonQuery);
            SearchHits<Map> hits = elasticsearchOperations.search(
                    query, Map.class, IndexCoordinates.of("product"));
            for (SearchHit<Map> hit : hits) {
                Object name = hit.getContent().get("p_name");
                if (name != null) suggestions.add(name.toString());
            }
        } catch (Exception e) { e.printStackTrace(); }
        return suggestions;
    }

    /* =========================
    5. 숙소 자동완성
    ========================= */
    public List<String> autocompleteStays(String q) {
        List<String> suggestions = new ArrayList<>();
        try {
            // 🥊 검색 로직과 동일하게 fuzziness: AUTO를 추가합니다.
            // 사용자가 "컨티네"라고 오타를 내도 "컨티넨탈..."을 추천해줍니다.
            String jsonQuery = String.format(
                "{\"match\": {\"s_name.auto\": {\"query\": \"%s\", \"fuzziness\": \"AUTO\"}}}", 
                q
            );
            
            Query query = new StringQuery(jsonQuery);
            SearchHits<Map> hits = elasticsearchOperations.search(
                    query, Map.class, IndexCoordinates.of("stay"));
            
            for (SearchHit<Map> hit : hits) {
                Object name = hit.getContent().get("s_name");
                if (name != null) suggestions.add(name.toString());
            }
        } catch (Exception e) { e.printStackTrace(); }
        return suggestions;
    }
    /* =========================
    6. FAQ 답변 검색 (원래 로직으로 복구!)
    ========================= */

    public Map<String, Object> searchAnswer(String question) {
        try {
            // 🥊 7.10.1 버전에서 가장 안전한 StringQuery 방식 + fuzziness 추가
            String jsonQuery = String.format(
                "{\"match\": {\"question.auto\": {\"query\": \"%s\", \"fuzziness\": \"AUTO\"}}}", 
                question
            );

            Query query = new StringQuery(jsonQuery);
            SearchHits<Map> hits = elasticsearchOperations.search(
                    query, Map.class, IndexCoordinates.of("faq_index"));

            if (!hits.hasSearchHits()) return null;

            SearchHit<Map> hit = hits.getSearchHit(0);

            // 🔥 점수 필터링 (너무 낮은 건 모르는 걸로 간주)
            if (hit.getScore() < 2.0f) return null;

            Map<String, Object> res = new HashMap<>();
            res.put("answer", hit.getContent().get("answer"));
            res.put("score", hit.getScore());
            return res;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /* =========================
    7. 챗봇 전용 메뉴 검색 (형님이 인증하신 '잘 되는' 첫 번째 로직! 🥊)
    ========================= */
 public Map<String, String> searchMenuDetailForChatbot(String keyword) {
     try {
         // 🥊 기교 부리지 않고 menuName.auto 필드에 집중!
         String jsonQuery = String.format(
             "{\"match\": {\"menuName.auto\": {\"query\": \"%s\", \"fuzziness\": \"AUTO\"}}}", 
             keyword
         );
         
         System.out.println(">>> [챗봇 메뉴 검색] 실행: " + jsonQuery);

         Query query = new StringQuery(jsonQuery);
         // 🥊 잘 되던 'site_menu' 인덱스로 다시 고정!
         SearchHits<Map> hits = elasticsearchOperations.search(
                 query, Map.class, IndexCoordinates.of("site_menu"));

         if (hits.hasSearchHits()) {
             Map<String, Object> src = hits.getSearchHit(0).getContent();
             Map<String, String> result = new HashMap<>();
             
             // 🥊 이 show 정보가 있어야 '이미 로그인 중입니다'가 뜹니다!
             result.put("show", (src.get("show") != null) ? src.get("show").toString() : "all");
             result.put("menuName", src.get("menuName").toString());
             result.put("url", src.get("url").toString());
             
             return result;
         }
     } catch (Exception e) { 
         e.printStackTrace(); 
     }
     return null; // 검색 결과 없으면 컨트롤러에서 다음 단계(FAQ나 GPT)로 이동
 }
}
