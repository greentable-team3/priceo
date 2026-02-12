package com.priceo.dao;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.priceo.dto.PartnerApplyDTO;

@Mapper
public interface PartnerApplyDAO {
    int insertApply(PartnerApplyDTO dto); // 브랜드 입점 신청
    List<PartnerApplyDTO> getAllApply(); // 브랜드 입점 신청 목록
    int updateState(@Param("pa_no") int pa_no,
                    @Param("pa_state") String pa_state); // 브랜드 입점 승인, 반려
    int deleteApply(@Param("pa_no") int pa_no); // 브랜드 입점 신청 내역 삭제
    PartnerApplyDTO getApply(@Param("pa_no") int pa_no); // 브랜드 신청 내역 상세 보기
}