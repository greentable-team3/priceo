package com.priceo.service;

import java.util.Random;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    // 인증번호 메일
    public String sendAuthMail(String toEmail, String type) {

        Random random = new Random();
        String authKey = String.valueOf(random.nextInt(888888) + 111111);

        String subject = "[priceO] 인증번호 안내입니다.";
        String messageBody = "안녕하세요! priceO!입니다.\n\n";

        if ("join".equals(type)) {
            subject = "[priceO] 회원가입 인증번호입니다.";
            messageBody += "회원가입을 위한 인증번호는 [" + authKey + "] 입니다.";
        } else if ("reset".equals(type)) {
            subject = "[priceO] 비밀번호 재설정 인증번호입니다.";
            messageBody += "비밀번호 재설정을 위한 인증번호는 [" + authKey + "] 입니다.";
        }

        messageBody += "\n해당 번호를 인증창에 입력해주세요.";

        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(toEmail);
        message.setSubject(subject);
        message.setText(messageBody);
        message.setFrom("ytaeug43@gmail.com"); // 문의 메일을 받을 관리자 이메일 주소

        mailSender.send(message);
        return authKey;
    }

    // 챗봇 FAQ 문의 메일
    public void sendFaqMail(String to, String subject, String question) {

        // 문의 내용 방어 처리
        if (question == null || question.trim().isEmpty()) {
            question = "(사용자가 입력한 문의 내용이 비어 있습니다)";
        }

        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to);
        message.setSubject(subject);
        message.setFrom("ytaeug43@gmail.com"); // ⭐ 이 줄이 핵심
        message.setText(
            "FAQ 챗봇을 통해 접수된 문의입니다.\n\n" +
            "문의 내용:\n" + question
        );

        mailSender.send(message);
    }
}