package com.priceo.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.data.elasticsearch.core.ElasticsearchOperations;
import org.springframework.data.elasticsearch.core.SearchHit;
import org.springframework.data.elasticsearch.core.SearchHits;
import org.springframework.data.elasticsearch.core.mapping.IndexCoordinates;
import org.springframework.data.elasticsearch.core.query.Query;
import org.springframework.data.elasticsearch.core.query.StringQuery;
import org.springframework.security.core.Authentication; // 🥊 추가
import org.springframework.security.core.context.SecurityContextHolder; // 🥊 추가
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.priceo.service.FaqSearchService;
import com.priceo.service.ProductService;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class SearchController {

    private final FaqSearchService faqSearchService;
    private final ProductService productService;
    private final ElasticsearchOperations elasticsearchOperations;

    @GetMapping("/search")
    public String search(@RequestParam("keyword") String keyword, Model model) {
        
        // 🥊 1. 로그인 상태 확인 (형님 원래 의도대로 복구)
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        boolean isLogin = (auth != null && auth.isAuthenticated() 
                           && !auth.getPrincipal().equals("anonymousUser"));

        // 🥊 2. 숙소 검색 결과 (컨트롤러 내 메서드 사용)
        Map<String, Object> stayRes = searchStays(keyword);
        
        // 🥊 3. 상품 검색 결과 (서비스 호출)
        Map<String, Object> productRes = faqSearchService.searchProducts(keyword);
        
        // 🥊 4. 메뉴 검색 결과 (isLogin을 던져서 로그인 시 '로그인/회원가입' 필터링!)
        Map<String, String> menuResult = faqSearchService.searchMenuDetail(keyword, isLogin);

        // 모델에 데이터 담기
        model.addAttribute("q", keyword);
        
        // 숙소 결과 및 오타 메시지
        model.addAttribute("stayList", stayRes.get("stays"));
        model.addAttribute("stayMessage", stayRes.get("message"));
        
        // 상품 결과 및 오타 메시지
        model.addAttribute("productList", productRes.get("products"));
        model.addAttribute("productMessage", productRes.get("message")); 
        
        // 메뉴 결과
        model.addAttribute("menuResult", menuResult);

        return "user/product/searchResult";
    }

    // 내부 숙소 검색 로직 (fuzziness AUTO 적용)
    public Map<String, Object> searchStays(String keyword) {
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
                if (!topName.contains(keyword)) {
                    result.put("message", topName);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    @GetMapping("/product/autocomplete")
    @ResponseBody
    public List<String> autocomplete(@RequestParam("q") String q) {
        return faqSearchService.autocomplete(q);
    }
}