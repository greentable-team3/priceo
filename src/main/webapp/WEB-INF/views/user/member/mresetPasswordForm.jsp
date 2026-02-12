<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>비밀번호 재설정</title>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        /* 1. 레이아웃 및 헤더 간섭 방지 */
        body {
            background-color: #f8f9fa;
            font-family: 'Pretendard', -apple-system, sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        .reset-pw-main {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 50px 20px;
            box-sizing: border-box;
        }

        /* 2. 재설정 카드 박스 */
        .reset-pw-card {
            width: 100%;
            max-width: 440px;
            padding: 40px;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.06);
            box-sizing: border-box;
        }

        .reset-pw-card h2 {
            font-size: 26px;
            font-weight: 800;
            color: #1e3a8a;
            text-align: center;
            margin-top: 0;
            margin-bottom: 30px;
        }

        /* 3. 폼 요소 스타일 - 아이디 칸 너비 100% 적용 */
        .form-group {
            margin-bottom: 20px;
            width: 100%;
        }

        .form-group label {
            display: block;
            font-size: 14px;
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
        }

        /* 아이디와 새 비밀번호 등 단독 입력창을 꽉 차게 설정 */
        .full-width-input {
            width: 100% !important;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 15px;
            outline: none;
            box-sizing: border-box;
            transition: border-color 0.2s;
        }

        .input-row {
            display: flex;
            gap: 8px;
            width: 100%;
        }

        /* 이메일/인증번호용 입력창 (옆에 버튼이 있는 경우) */
        .row-input {
            flex: 1;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 15px;
            outline: none;
            box-sizing: border-box;
        }

        input:focus {
            border-color: #1e3a8a;
        }

        /* 4. 버튼 스타일 (네이비 #1e3a8a 고정) */
        button {
            padding: 12px 18px;
            background-color: #1e3a8a !important;
            color: #fff !important;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            white-space: nowrap;
        }

        .full-btn {
            width: 100%;
            margin-top: 10px;
            padding: 15px;
            font-size: 16px;
        }

        /* 5. 기타 요소 */
        #auth-msg {
            font-size: 13px;
            margin-top: 8px;
            color: #e63946;
        }

        hr {
            border: 0;
            border-top: 1px solid #eee;
            margin: 30px 0 20px;
        }

        .back-link-wrapper {
            text-align: center;
        }

        .back-link {
            font-size: 14px;
            color: #888;
            text-decoration: none;
        }

        /* [보정] 헤더 깨짐 방지 */
        header { display: block !important; }
    </style>
</head>

<body>

<%@ include file="/WEB-INF/views/header.jsp" %>

<div class="reset-pw-main">
    <div class="reset-pw-card">
        <h2>비밀번호 재설정</h2>

        <form id="mresetPwForm">
            <div class="form-group">
                <label>아이디</label>
                <input type="text" id="m_id" name="m_id" class="full-width-input" placeholder="아이디를 입력하세요" required>
            </div>

            <div class="form-group">
                <label>이메일</label>
                <div class="input-row">
                    <input type="email" id="m_email" name="m_email" class="row-input" placeholder="이메일을 입력하세요" required>
                    <button type="button" id="send-btn" onclick="sendFindPwEmail();">인증번호 발송</button>
                </div>
            </div>

            <div id="auth-section" class="form-group" style="display:none;">
                <label>인증번호</label>
                <div class="input-row">
                    <input type="text" id="auth_code" class="row-input" placeholder="6자리 숫자">
                    <button type="button" id="verify-btn" onclick="verifyEmailCode();">인증 확인</button>
                </div>
                <div id="auth-msg"></div>
            </div>

            <div id="password-reset-section" style="display:none;">
                <div class="form-group">
                    <label>새 비밀번호</label>
                    <input type="password" id="new_pw" class="full-width-input" placeholder="8자 이상 입력하세요">
                </div>

                <div class="form-group">
                    <label>새 비밀번호 확인</label>
                    <input type="password" id="new_pw2" class="full-width-input" placeholder="다시 한번 입력하세요">
                </div>

                <button type="button" class="full-btn" onclick="changePassword();">비밀번호 변경</button>
            </div>
        </form>

        <hr>

        <div class="back-link-wrapper">
            <a href="/mloginForm" class="back-link">로그인 페이지로 돌아가기</a>
        </div>
    </div>
</div>
<%@ include file="/WEB-INF/views/footer.jsp" %>
<script src="/js/Member.js"></script>

</body>
</html>