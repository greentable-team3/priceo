package com.priceo.service;

import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.data.elasticsearch.core.ElasticsearchOperations;
import org.springframework.data.elasticsearch.core.mapping.IndexCoordinates;

import com.priceo.dao.stayDAO; 
import com.priceo.dto.stayDTO;
import com.priceo.search.StayDocument;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class StayService {

    private final stayDAO stayDao;
    private final ElasticsearchOperations elasticsearchOperations;

    @Transactional
    public void registerStay(stayDTO dto) {
        stayDao.insertStay(dto);
        syncToElastic(dto);
    }

    @Transactional
    public void updateStay(stayDTO dto) {
        stayDao.updateStay(dto);
        syncToElastic(dto);
    }

    @Transactional
    public void removeStay(int s_no) {
        stayDao.deleteStay(s_no);
        elasticsearchOperations.delete(String.valueOf(s_no), IndexCoordinates.of("stay"));
    }

    // 단건 동기화
    private void syncToElastic(stayDTO dto) {
        StayDocument doc = StayDocument.builder()
                .s_no(dto.getS_no().longValue())
                .s_name(dto.getS_name())
                .s_addr(dto.getS_addr()) // 🥊 s_address -> s_addr로 수정
                .s_view(dto.getS_view()) // 조회수 연동
                .s_image(dto.getS_image())
                // 🥊 가격(s_price)은 Document에 없으므로 과감히 삭제!
                .build();
        
        elasticsearchOperations.save(doc, IndexCoordinates.of("stay"));
    }

    // 전수 동기화
    @Transactional
    public void syncAllStays() {
        List<stayDTO> dbList = stayDao.selectStayList(); 
        if (dbList == null) return;

        for (stayDTO dto : dbList) {
            StayDocument doc = StayDocument.builder()
                    .s_no(dto.getS_no().longValue())
                    .s_name(dto.getS_name())
                    .s_addr(dto.getS_addr())
                    .s_view(dto.getS_view())
                    .s_image(dto.getS_image())
                    .build();
            
            elasticsearchOperations.save(doc, IndexCoordinates.of("stay"));
        }
        System.out.println("숙소 데이터 동기화 완료! (가격 제외)");
    }
}