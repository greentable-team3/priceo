package com.priceo.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 상품 사진
        registry.addResourceHandler("/product/**")
                .addResourceLocations("file:///C:/product/");
        // 상품_리뷰사진
        registry.addResourceHandler("/productreview/**") 
        .addResourceLocations("file:///C:/productreview/");  
        // 상품_교환사진
        registry.addResourceHandler("/exchange/**")
                .addResourceLocations("file:///C:/exchange/");
        // 숙소 사진
        registry.addResourceHandler("/stay/**")
                .addResourceLocations("file:///C:/stay/"); 
        // 숙소_리뷰 사진
        registry.addResourceHandler("/stayreview/**")
                .addResourceLocations("file:///C:/stayreview/");
        
        // 푸쉬 알림용 사진
        // 1. 상품 사진
        registry.addResourceHandler("/product/**")
                .addResourceLocations("file:///C:/product/");

        // 2. 나머지 기존 경로들 (그대로 유지)
        registry.addResourceHandler("/productreview/**").addResourceLocations("file:///C:/productreview/");
        registry.addResourceHandler("/exchange/**").addResourceLocations("file:///C:/exchange/");
        registry.addResourceHandler("/stay/**").addResourceLocations("file:///C:/stay/");
        registry.addResourceHandler("/stayreview/**").addResourceLocations("file:///C:/stayreview/");
        
    }
}