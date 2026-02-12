package com.priceo.service;

import org.springframework.stereotype.Service;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;


@Service
public class OpenAIService {

    private static final String API_KEY = "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";
    private static final String API_URL = "https://api.openai.com/v1/chat/completions";

    public String askGPT(String question) {

        OkHttpClient client = new OkHttpClient();
        
        String json = """
        {
          "model": "gpt-3.5-turbo",
          "messages": [
            { "role": "system", "content": "너는 PRICEO 고객센터 챗봇이다. 친절하고 짧게 답변해라. 모르는 질문이 나오면 우선 너의 지식을 통해서 답변하고 그래도 정보가 불충분하면 '해당 내용은 정확한 안내가 필요합니다. 담당자에게 문의 메일을 보내드릴까요?'라고 답변해라." },
            { "role": "user", "content": "%s" }
          ]
        }
        """.formatted(question);

        Request request = new Request.Builder()
            .url(API_URL)
            .post(RequestBody.create(json, MediaType.parse("application/json")))
            .addHeader("Authorization", "Bearer " + API_KEY)
            .build();

        try (Response response = client.newCall(request).execute()) {

            if (!response.isSuccessful()) {
                System.out.println("GPT 호출 실패: " + response.code());
                return null; // ✅ 실패는 null로 (컨트롤러가 처리)
            }

            String body = response.body().string();
            System.out.println("GPT RAW RESPONSE:\n" + body);

            String marker = "\"content\":\"";
            int start = body.indexOf(marker);
            if (start == -1) return null;

            start += marker.length();
            int end = body.indexOf("\"", start);
            if (end == -1) return null;

            String content = body.substring(start, end).replace("\\n", "\n");
            return content; // GPT가 준 답변 그대로

        } catch (Exception e) {
            e.printStackTrace();
            return null; // 예외도 null
        }
    }
    
    
}