package com.priceo.service;

import java.util.List;
import java.util.Map;

import org.elasticsearch.action.delete.DeleteRequest;
import org.elasticsearch.action.index.IndexRequest;
import org.elasticsearch.action.support.WriteRequest;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.RestHighLevelClient;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.priceo.dao.productDAO;
import com.priceo.dto.productDTO;
import com.priceo.dto.stayDTO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ProductService {

    private final productDAO productDao; 
    private final RestHighLevelClient client; // 🥊 하나만 남김
    private final ObjectMapper objectMapper = new ObjectMapper(); // 🥊 하나만 남김

    /* =========================
       1. DB 상세 조회
       ========================= */
    public productDTO getProductByNo(int p_no) {
        return productDao.pdetailDao(p_no);
    }

    /* =========================
       2. 단건 동기화 로직 (이미지 주입 필수!)
       ========================= */
    private void syncToElastic(productDTO dto) {
        try {
            if (dto.getType() != null && "STAY".equals(dto.getType())) {
                return; 
            }

            IndexRequest request = new IndexRequest("product");
            request.id(String.valueOf(dto.getP_no()));

            // 🥊 Jackson 변환 시 누락될 수 있는 p_image 강제 주입
            Map<String, Object> dataMap = objectMapper.convertValue(dto, Map.class);
            dataMap.put("p_image", dto.getP_image()); 
            
            request.source(dataMap);
            request.setRefreshPolicy(WriteRequest.RefreshPolicy.IMMEDIATE);

            client.index(request, RequestOptions.DEFAULT);
            System.out.println(">>> [ES] 상품 동기화 완료: ID = " + dto.getP_no() + ", 이미지 = " + dto.getP_image());
        } catch (Exception e) {
            System.err.println(">>> [ES] 동기화 실패: " + e.getMessage());
        }
    }

    /* =========================
       3. 전체 재동기화
       ========================= */
    @Transactional
    public void syncAllProducts() {
        List<productDTO> dbList = productDao.getOnlyProductData(); 
        if (dbList != null) {
            for (productDTO dto : dbList) {
                syncToElastic(dto);
            }
        }
        System.out.println(">>> [ES] 전체 상품 재동기화 완료!");
    }

    /* =========================
    4. 통합 인덱스(priceo_total) 갱신
    메인 페이지(23개)는 건드리지 않고, 챗봇을 위해 전체 데이터를 넣습니다. 🥊
    ========================= */
 public void refreshTotalIndex() {
     try {
         // 🥊 1. 상품 전체 리스트 가져오기 (이미 있는 메서드 활용)
         List<productDTO> productList = productDao.getOnlyProductData(); 
         
         // 🥊 2. 숙소 전체 리스트 가져오기 (없다면 DAO에 새로 만드셔야 합니다!)
         // 만약 숙소 전용 메서드가 없다면 mapper에서 SELECT * FROM stay 쿼리 연결
         List<productDTO> stayList = productDao.getOnlyStayData(); 

         // 🥊 3. 두 리스트 합치기 (데이터 수혈 준비)
         if (productList != null && stayList != null) {
             productList.addAll(stayList);
         }
         
         List<productDTO> totalList = productList;

         if (totalList != null && !totalList.isEmpty()) {
             int count = 0;
             for (productDTO dto : totalList) {
                 Map<String, Object> dataMap = objectMapper.convertValue(dto, Map.class);
                 
                 // 🥊 이미지 경로 보정 (상품은 p_image, 숙소는 s_image 등 필드 확인)
                 // 만약 숙소 데이터인데 p_image가 비어있다면 처리해주는 로직
                 if (dto.getP_image() == null && "STAY".equals(dto.getType())) {
                     // 숙소 DTO에서 이미지를 가져와 p_image 필드에 강제로 넣어줌 (검색용 통합 필드)
                     dataMap.put("p_image", dto.getP_image()); 
                 } else {
                     dataMap.put("p_image", dto.getP_image());
                 }

                 IndexRequest request = new IndexRequest("priceo_total")
                     .id(dto.getType() + "_" + dto.getP_no())
                     .source(dataMap)
                     .setRefreshPolicy(WriteRequest.RefreshPolicy.IMMEDIATE);
                 
                 client.index(request, RequestOptions.DEFAULT);
                 count++;
             }
             System.out.println(">>> [ES] 통합 인덱스(priceo_total) 수혈 완료! 총 " + count + "건 반영 🥊");
         } else {
             System.out.println(">>> [ES] 가져올 데이터가 없습니다.");
         }
     } catch (Exception e) {
         System.err.println(">>> [ES] 통합 인덱스 갱신 실패: " + e.getMessage());
         e.printStackTrace();
     }
 }

    /* =========================
       5. 삭제 및 즉시 반영
       ========================= */
    public void deleteProductAndRefreshTotal(int p_no) {
        try {
            client.delete(new DeleteRequest("product", String.valueOf(p_no))
                    .setRefreshPolicy(WriteRequest.RefreshPolicy.IMMEDIATE), RequestOptions.DEFAULT);
            client.delete(new DeleteRequest("product", "PRD_" + p_no)
                    .setRefreshPolicy(WriteRequest.RefreshPolicy.IMMEDIATE), RequestOptions.DEFAULT);
            client.delete(new DeleteRequest("priceo_total", "PRODUCT_" + p_no)
                    .setRefreshPolicy(WriteRequest.RefreshPolicy.IMMEDIATE), RequestOptions.DEFAULT);

            refreshTotalIndex();
            System.out.println(">>> [ES] 상품 완전 삭제 완료: ID = " + p_no);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void deleteStayAndRefreshTotal(int s_no) {
        try {
            client.delete(new DeleteRequest("stay", String.valueOf(s_no))
                    .setRefreshPolicy(WriteRequest.RefreshPolicy.IMMEDIATE), RequestOptions.DEFAULT);
            client.delete(new DeleteRequest("priceo_total", "STAY_" + s_no)
                    .setRefreshPolicy(WriteRequest.RefreshPolicy.IMMEDIATE), RequestOptions.DEFAULT);

            refreshTotalIndex();
            System.out.println(">>> [ES] 숙소 완전 삭제 완료: ID = " + s_no);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /* =========================
       6. 등록/수정 즉시 반영 (실시간 동기화)
       ========================= */
    public void saveProductToElastic(productDTO dto) {
        try {
            Map<String, Object> dataMap = objectMapper.convertValue(dto, Map.class);
            dataMap.put("p_image", dto.getP_image()); 
            
            IndexRequest request = new IndexRequest("product")
                .id(String.valueOf(dto.getP_no()))
                .source(dataMap)
                .setRefreshPolicy(WriteRequest.RefreshPolicy.IMMEDIATE);
            
            client.index(request, RequestOptions.DEFAULT);
            refreshTotalIndex();
            System.out.println(">>> [ES] 상품 실시간 반영 완료: " + dto.getP_image());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void saveStayToElastic(stayDTO dto) {
        try {
            Map<String, Object> dataMap = objectMapper.convertValue(dto, Map.class);
            dataMap.put("s_image", dto.getS_image()); 
            
            dataMap.put("min_price", dto.getMin_price());
            
            IndexRequest request = new IndexRequest("stay")
                .id(String.valueOf(dto.getS_no()))
                .source(dataMap)
                .setRefreshPolicy(WriteRequest.RefreshPolicy.IMMEDIATE);
            
            client.index(request, RequestOptions.DEFAULT);
            refreshTotalIndex();
            System.out.println(">>> [ES] 숙소 실시간 반영 완료: " + dto.getS_image());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}