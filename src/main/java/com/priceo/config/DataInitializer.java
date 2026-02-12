package com.priceo.config;

import java.util.List;
import java.util.Map;

import org.elasticsearch.action.index.IndexRequest;
import org.elasticsearch.action.index.IndexResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.RestHighLevelClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.priceo.dao.productDAO;
import com.priceo.dao.reviewDAO;
import com.priceo.dao.stayDAO;
import com.priceo.dto.productDTO;
import com.priceo.dto.reviewDTO;
import com.priceo.dto.stayDTO;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired private productDAO pDao;
    @Autowired private stayDAO sDao;
    @Autowired private RestHighLevelClient client; 
    @Autowired private reviewDAO rDao;
    
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void run(String... args) throws Exception {
        System.out.println("==========================================");
        System.out.println(">>> [ES] 엘라스틱서치 동기화 프로세스 시작");
        System.out.println("==========================================");

        try {
            // 1. 숙소 데이터 동기화
            List<stayDTO> sList = sDao.selectStayList();
            
            if (sList == null || sList.isEmpty()) {
                System.err.println(">>> [경고] DB에서 숙소 데이터를 가져오지 못했습니다. (List가 비어있음)");
            } else {
                System.out.println(">>> [확인] DB 숙소 데이터 개수: " + sList.size());
                for (stayDTO dto : sList) {
                    // ID가 null이면 ES가 거부하므로 체크
                    if (dto.getS_no() == null) continue;

                    IndexRequest request = new IndexRequest("stay")
                        .id(String.valueOf(dto.getS_no()))
                        .source(objectMapper.convertValue(dto, Map.class));
                    
                    IndexResponse response = client.index(request, RequestOptions.DEFAULT);
                    System.out.println(">>> [숙소 저장] ID: " + dto.getS_no() + " | 결과: " + response.getResult());
                }
            }

         // 2. 상품 데이터 동기화 (수정 완료!)
            // 🥊 [수정포인트] getPopularList() 대신 getOnlyProductData()를 호출하세요!
            List<productDTO> pList = pDao.getOnlyProductData(); 
            
            if (pList == null || pList.isEmpty()) {
                System.err.println(">>> [경고] DB에서 상품 데이터를 가져오지 못했습니다.");
            } else {
                System.out.println(">>> [확인] DB 순수 상품 데이터 개수: " + pList.size());
                for (productDTO dto : pList) {
                    // 🥊 [추가 보안] 여기서도 혹시 모를 STAY 데이터를 한 번 더 걸러줍니다.
                    if (dto.getP_no() == 0 || "STAY".equals(dto.getType())) continue;

                    IndexRequest request = new IndexRequest("product")
                        .id(String.valueOf(dto.getP_no()))
                        .source(objectMapper.convertValue(dto, Map.class));
                    
                    IndexResponse response = client.index(request, RequestOptions.DEFAULT);
                    System.out.println(">>> [상품 저장] ID: " + dto.getP_no() + " | 결과: " + response.getResult());
                }
            }

            // 3. 리뷰 데이터 동기화
            List<reviewDTO> rList = rDao.getReviewList();
            
            if (rList == null || rList.isEmpty()) {
                System.err.println(">>> [경고] DB에서 리뷰 데이터를 가져오지 못했습니다. (List가 비어있음)");
            } else {
                System.out.println(">>> [확인] DB 리뷰 데이터 개수: " + rList.size());
                for (reviewDTO dto : rList) {
                    // ID가 null이면 ES가 거부하므로 체크
                   if (dto.getR_no() == null) continue;

                    IndexRequest request = new IndexRequest("review")
                        .id(String.valueOf(dto.getR_no()))
                        .source(objectMapper.convertValue(dto, Map.class));
                    
                    IndexResponse response = client.index(request, RequestOptions.DEFAULT);
                    System.out.println(">>> [리뷰 저장] ID: " + dto.getR_no() + " | 결과: " + response.getResult());
                }
            }
            
            System.out.println("==========================================");
            System.out.println(">>> [ES] 모든 동기화 작업 완료!");
            System.out.println("==========================================");

        } catch (Exception e) {
            System.err.println(">>> [ES] 치명적 오류 발생!");
            System.err.println(">>> 에러 메시지: " + e.getMessage());
            e.printStackTrace();
        }
    } 
    
    
    
}