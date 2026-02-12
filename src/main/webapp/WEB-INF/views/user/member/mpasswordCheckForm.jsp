<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>비밀번호 확인</title>
    <style>
    /* 형님 원본 CSS 그대로 유지 */
    body {
        background-color: #f8f9fa;
        font-family: 'Pretendard', -apple-system, sans-serif;
        margin: 0;
        display: flex;
        flex-direction: column;
        min-height: 100vh;
    }
    .password-check-container {
        width: 100%;
        max-width: 400px;
        margin: auto;
        padding: 40px;
        background: #fff;
        border-radius: 12px;
        box-shadow: 0 8px 20px rgba(0,0,0,0.08);
        text-align: center;
    }
    h3 { font-size: 24px; color: #333; margin-bottom: 15px; }
    p { font-size: 15px; color: #666; line-height: 1.6; margin-bottom: 30px; }
    p strong { color: #333; }
    .input-group { margin-bottom: 25px; }
    input[type="password"] {
        width: 100%;
        padding: 12px 15px;
        border: 1px solid #ddd;
        border-radius: 8px;
        font-size: 15px;
        box-sizing: border-box;
        transition: border-color 0.3s;
    }
    input[type="password"]:focus { border-color: #333; outline: none; }
    .button-group { display: flex; gap: 10px; }
    .btn {
        flex: 1;
        padding: 12px;
        border-radius: 8px;
        font-size: 15px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s;
        border: none;
    }
    .btn-cancel { background-color: #eee; color: #666; }
    .btn-confirm { background-color: #1e3a8a; color: #fff; }
    .error-msg { color: #ff4757; font-size: 14px; margin-top: 15px; }
    
    /* 소셜 탈퇴용 버튼 색상만 추가 */
    .btn-delete { background-color: #ff4757; color: #fff; }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/views/header.jsp" %>

<div class="password-check-container">
    <c:choose>
        <%-- 🥊 소셜 유저(KAKAO 권한) 탈퇴 확인 화면 --%>
        <c:when test="${isSocial}">
            <h3>회원 탈퇴 확인</h3>
            <p>
                소셜 로그인 계정은 별도의 비밀번호가 없습니다.<br>
                <strong>정말 탈퇴하시겠습니까?</strong>
            </p>
            <div class="button-group">
                <button type="button" class="btn btn-cancel" onclick="history.back();">취소</button>
                <button type="button" class="btn btn-delete" onclick="confirmSocialDelete(${member.m_no})">탈퇴 확정</button>
            </div>
        </c:when>

        <%-- 🥊 일반 유저 비밀번호 확인 화면 --%>
        <c:otherwise>
            <h3>비밀번호 확인</h3>
            <p>
                개인정보 보호를 위해 <strong>비밀번호</strong>를<br>
                한번 더 입력해 주시기 바랍니다.
            </p>
            <form name="mpasswordCheckForm" method="post" action="/passwordCheck">
                <input type="hidden" name="m_no" value="${m_no}">
                <input type="hidden" name="mode" value="${mode}">
                <div class="input-group">
                    <input type="password" name="m_passwd" placeholder="비밀번호를 입력하세요" required autofocus>
                </div>
                <div class="button-group">
                    <button type="button" class="btn btn-cancel" onclick="history.back();">취소</button>
                    <button type="submit" class="btn btn-confirm">확인</button>
                </div>
            </form>
        </c:otherwise>
    </c:choose>

    <c:if test="${not empty msg}">
        <p class="error-msg">${msg}</p>
    </c:if>
</div>
<%@ include file="/WEB-INF/views/user/member/mfaqChat.jsp" %>
<script>
function confirmSocialDelete(mNo) {
    if (confirm) {
        // 일반 유저랑 똑같이 /passwordCheck를 타게 하되, 
        // m_passwd 자리에 'OAUTH2_USER' 같은 약속된 값을 던집니다.
        location.href = "/passwordCheck?mode=delete&m_no=" + mNo + "&m_passwd=OAUTH2_USER";
    }
}
</script>
</body>
</html>