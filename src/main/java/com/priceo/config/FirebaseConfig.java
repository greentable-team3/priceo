package com.priceo.config;

import java.io.InputStream;

import javax.annotation.PostConstruct;

import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;

@Configuration
public class FirebaseConfig {

    @PostConstruct
    public void init() {
        try {
            // ⭐ resources 폴더 기준
            InputStream serviceAccount =
                new ClassPathResource(
                    "priceo-9b9f4-firebase-adminsdk-fbsvc-0da252ed85.json"
                ).getInputStream();

            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();

            if (FirebaseApp.getApps().isEmpty()) {
                FirebaseApp.initializeApp(options);
                System.out.println("Firebase 초기화 완료");
            }

        } catch (Exception e) {
            System.out.println("Firebase 초기화 실패");
            e.printStackTrace();
        }
    }
}