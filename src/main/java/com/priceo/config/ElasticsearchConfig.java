package com.priceo.config;

import org.apache.http.HttpHost;
import org.elasticsearch.client.RestClient;
import org.elasticsearch.client.RestHighLevelClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.elasticsearch.core.ElasticsearchOperations;
import org.springframework.data.elasticsearch.core.ElasticsearchRestTemplate;

@Configuration
public class ElasticsearchConfig {

    @Bean
    public RestHighLevelClient customClient() {
        // 복잡한 setDefaultHeaders 싹 다 지웠습니다. 
        // 7.10.1 서버에는 그냥 생으로 붙는게 가장 확실합니다.
        return new RestHighLevelClient(
            RestClient.builder(new HttpHost("localhost", 9200, "http"))
        );
    }

    @Bean(name = "elasticsearchOperations")
    public ElasticsearchOperations elasticsearchOperations() {
        return new ElasticsearchRestTemplate(customClient());
    }
}