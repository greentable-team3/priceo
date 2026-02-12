package com.priceo.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.priceo.dto.imagefileDTO;

@Mapper
public interface imagefileDAO {
	// 1. 등록: 숙소/상품 등록 시 이미지 정보 저장
    int insertImage(imagefileDTO imgDto);

    // 2. 조회: 상세 페이지 출력 시, 혹은 삭제 전 파일명 확인용
    List<imagefileDTO> selectImagesByRef(imagefileDTO imgDto);

    // 3. 삭제: 숙소/상품 삭제 시 해당 데이터만 골라서 삭제
    int deleteImagesByRef(imagefileDTO imgDto);
}
