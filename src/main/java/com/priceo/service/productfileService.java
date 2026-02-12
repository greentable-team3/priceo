package com.priceo.service;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class productfileService {

	    // 파일을 저장할 외부 경로 (예: C 드라이브 아래 upload 폴더)
	    // 실제 서버(Linux)라면 "/home/user/upload/" 처럼 작성합니다.
	    private final String uploadPath = "C:/product/";

	    public String upload(MultipartFile file) {
	        if (file == null || file.isEmpty()) return null;

	        // 호출될 때마다 새로운 UUID를 생성해야 파일명이 절대 겹치지 않습니다.
	        String uuid = UUID.randomUUID().toString();
	        String extension = file.getOriginalFilename().substring(file.getOriginalFilename().lastIndexOf("."));
	        
	        // 이 파일만의 고유한 이름 생성
	        String savedFilename = uuid + extension; 

	        File targetFile = new File(uploadPath, savedFilename);

	        if (!targetFile.getParentFile().exists()) {
	            targetFile.getParentFile().mkdirs();
	        }

	        try {
	            file.transferTo(targetFile); // 실제 저장
	            return savedFilename;        // 저장된 "그" 이름을 반환
	        } catch (IOException e) {
	            e.printStackTrace();
	            return null;
	        }
	    }
}

