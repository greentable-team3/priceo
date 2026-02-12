package com.priceo.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import org.springframework.stereotype.Service;

@Service
public class portoneService {
    private final String API_KEY = "7546558688651174";
    private final String API_SECRET = "PVSC09Om6vRc3lQYq0ANPlUiURhx5PcrrfWhigST0OomwjfY5jv4PaZ7O4bOm9N0CN4hyctsZjtq95Gq";

    public String getToken() throws Exception {
        System.out.println("1. 토큰 요청 시작..."); // 로그 추가
        URL url = new URL("https://api.iamport.kr/users/getToken");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);

        String jsonInput = "{\"imp_key\": \"" + API_KEY + "\", \"imp_secret\": \"" + API_SECRET + "\"}";

        System.out.println("2. 포트원 연결 시도 중..."); // 로그 추가
        try (OutputStream os = conn.getOutputStream()) {
            os.write(jsonInput.getBytes("utf-8"));
        }

        int responseCode = conn.getResponseCode();
        if (responseCode == 200) {
            System.out.println("3. 토큰 발급 성공!"); // 로그 추가
            BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            String line;
            StringBuilder response = new StringBuilder();
            while ((line = br.readLine()) != null) response.append(line);
            
            String res = response.toString();
            return res.split("\"access_token\":\"")[1].split("\"")[0];
        } else {
            System.out.println("3. 토큰 발급 실패! 응답코드: " + responseCode); // 로그 추가
            return null;
        }
    }

    public boolean refund(String token, String merchant_uid, String reason) throws Exception {
        System.out.println("4. 환불 요청 시작... 주문번호: " + merchant_uid);
        URL url = new URL("https://api.iamport.kr/payments/cancel");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setRequestProperty("Authorization", token);
        conn.setDoOutput(true);

        String jsonInput = "{\"merchant_uid\": \"" + merchant_uid + "\", \"reason\": \"" + reason + "\"}";

        try (OutputStream os = conn.getOutputStream()) {
            os.write(jsonInput.getBytes("utf-8"));
        }

        int resCode = conn.getResponseCode();
        if (resCode == 200) {
            System.out.println("5. 환불 성공!");
            return true;
        } else {
            System.out.println("5. 환불 실패! 응답코드: " + resCode);
            return false;
        }
    }
}