package com.priceo.service;

import org.springframework.stereotype.Service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;

@Service
public class PushService {


	public void sendPush(int m_no, String token, String title, String body, String imageUrl, int p_no) {
        if (token == null || token.isBlank()) return;

        // 이미지 캐싱 방지 로직 유지
        String freshImageUrl = (imageUrl != null && !imageUrl.isBlank()) 
                ? imageUrl + "?v=" + System.currentTimeMillis() : imageUrl;

        try {
            Message message = Message.builder()
                .setNotification(Notification.builder()
                    // 🥊 숙소용과 같은 구조: title이 있으면 앞에 말머리 붙이고, 없으면 기본 문구!
                    .setTitle(title != null ? "[신규 상품 등록!] " + title : "신규 상품 등록!")
                    // 🥊 body가 있으면 그대로 쓰고, 없으면 기본 문구!
                    .setBody(body != null ? body : "지금 바로 새로운 상품을 확인해보세요!")
                    .setImage(freshImageUrl)
                    .build())
                
                // 이동 경로 설정
                .putData("url", "/pdetail?p_no=" + p_no) 
                
                .setToken(token)
                .build();

            FirebaseMessaging.getInstance().send(message);
            System.out.println("✅ [상품 FCM 성공] 상품번호: " + p_no + " | 제목: " + title);
            
        } catch (FirebaseMessagingException e) {
            System.err.println("❌ [상품 FCM 실패] 상품번호: " + p_no);
            e.printStackTrace();
        }
    }

    // 🥊 2. [수정 완료] 숙소용 알림 - 이동 URL을 /stayDetail로 변경!
    public void sendStayPush(int m_no, String token, String title, String body, String imageUrl, int s_no) {
        if (token == null || token.isBlank()) return;
        try {
            Message message = Message.builder()
                .setNotification(Notification.builder()
                    .setTitle(title != null ? title : "신규 숙소 등록!")
                    .setBody(body != null ? body : "멋진 숙소가 등록되었습니다!")
                    .setImage(imageUrl)
                    .build())
                // 🥊 여기를 /sdetail에서 /stayDetail로 고쳤습니다!
                .putData("url", "/stayDetail?s_no=" + s_no) 
                .setToken(token)
                .build();

            FirebaseMessaging.getInstance().send(message);
            System.out.println("✅ [숙소 FCM 성공] 숙소번호: " + s_no + " | 경로: /stayDetail");
        } catch (FirebaseMessagingException e) {
            e.printStackTrace();
        }
    }
}
