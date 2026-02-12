<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>로그인 - Priceo</title>
    <style>
    body {
        background-color: #f8f9fa;
        font-family: 'Pretendard', -apple-system, sans-serif;
        margin: 0;
        display: flex;
        flex-direction: column;
        min-height: 100vh;
    }

    /* 로그인 컨테이너 */
    .login-wrapper {
        width: 100%;
        max-width: 400px;
        margin: auto;
        padding: 40px;
        background: #fff;
        border-radius: 12px;
        box-shadow: 0 10px 25px rgba(0,0,0,0.05);
        box-sizing: border-box;
    }

    .login-header {
        text-align: center;
        margin-bottom: 30px;
    }

    .login-header .home-link {
        display: inline-block;
        text-decoration: none;
        color: #888;
        font-size: 14px;
        margin-bottom: 10px;
    }

    .login-header h3 {
        font-size: 26px;
        color: #333;
        margin: 0;
        letter-spacing: -0.5px;
    }

    /* 입력 폼 */
    .form-group {
        margin-bottom: 20px;
    }

    .form-group label {
        display: block;
        font-size: 14px;
        font-weight: 600;
        color: #555;
        margin-bottom: 8px;
    }

    .form-group input {
        width: 100%;
        padding: 12px 15px;
        border: 1px solid #ddd;
        border-radius: 8px;
        font-size: 15px;
        box-sizing: border-box;
        transition: border-color 0.3s;
    }

    .form-group input:focus {
        border-color: #1e3a8a;
        outline: none;
    }

    /* 에러 메시지 */
    .error-msg {
        color: #ff4757;
        font-size: 13px;
        margin-bottom: 15px;
        text-align: center;
    }

    /* 버튼 영역 */
    .login-btn-group {
        display: flex;
        flex-direction: column;
        gap: 10px;
        margin-bottom: 20px;
    }

    .btn {
        width: 100%;
        padding: 14px;
        border-radius: 8px;
        font-size: 16px;
        font-weight: 600;
        cursor: pointer;
        border: none;
        transition: all 0.3s;
    }

    .btn-login {
        background-color: #1e3a8a;
        color: #fff;
    }

    .btn-login:hover {
        background-color: #1e3a8a;
        transform: translateY(-1px);
    }

    .btn-signup {
        background-color: #fff;
        color: #333;
        border: 1px solid #ddd;
    }

    .btn-signup:hover {
        background-color: #f8f9fa;
    }

    /* 하단 링크 */
    .find-links {
        text-align: center;
    }

    .find-links a {
        color: #888;
        font-size: 14px;
        text-decoration: none;
    }

    .find-links a:hover {
        text-decoration: underline;
    }
    
    .error-message {
        color: red;
    }

    /* 🥊 소셜 로그인 기강 잡기 섹션 */
    .social-login-container {
        display: flex;
        flex-direction: column; /* 세로 정렬 */
        gap: 10px;              /* 버튼 사이 간격 */
        align-items: center;    /* 가운데 정렬 */
        margin-top: 20px;
        margin-bottom: 25px;
    }

    .social-btn {
        width: 100%;           /* 부모 너비 따라가기 */
        display: flex;
        justify-content: center;
    }

    .social-btn img {
        width: 100%;           
        max-width: 320px;      /* 카톡 기본 너비 */
        height: 48px;          /* 🥊 높이 강제 고정 (위쪽 로그인 버튼들과 통일) */
        object-fit: fill;      /* 🥊 비율 상관없이 높이 꽉 채우기 */
        border-radius: 8px;    /* 곡률 통일 */
    }
    
	.google-rect-final {
	    display: flex;
	    align-items: center;
	    width: 100%;
	    max-width: 320px;    /* 카카오 버튼 너비와 일치 */
	    height: 48px;         /* 카카오 버튼 높이와 일치 */
	    background-color: #ffffff;
	    border: 1px solid #dadce0;
	    border-radius: 8px;   /* 🥊 카카오처럼 살짝만 둥글게. 완전 네모는 0px */
	    text-decoration: none;
	    margin: 0 auto;
	    overflow: hidden;
	    box-sizing: border-box;
	}
	
	.google-icon-wrapper {
	    display: flex;
	    align-items: center;
	    justify-content: center;
	    width: 46px;          /* 아이콘 영역 */
	    height: 100%;
	}
	
	.google-icon-wrapper img {
	    width: 18px;
	    height: 18px;
	}
	
	.google-text {
	    flex-grow: 1;
	    text-align: center;
	    padding-right: 46px;  /* 아이콘 너비만큼 오른쪽 여백 줘서 글자 가운데 정렬 */
	    color: #3c4043;
	    font-size: 15px;
	    font-weight: 600;
	    font-family: 'Pretendard', sans-serif;
	}
	
	.google-rect-final:hover {
	    background-color: #f8f9fa;
	    border-color: #d2d4d7;
	}
</style>
</head>

<body>
    <%@ include file="/WEB-INF/views/header.jsp" %>
    <div class="login-wrapper">
        <div class="login-header">
            <a href="/" class="home-link">홈으로 돌아가기</a>
            <h3>로그인</h3>
        </div>

        <form name="mloginForm" method="post" action="/loginProc">
            <div class="form-group">
                <label>아이디</label>
                <input type="text" name="username" placeholder="아이디를 입력하세요" required autofocus>
            </div>

            <div class="form-group">
                <label>비밀번호</label>
                <input type="password" name="password" placeholder="비밀번호를 입력하세요" required>
            </div>

            <c:if test="${param.error eq 'true'}">
                <div class="error-msg">
                    아이디 또는 비밀번호가 틀렸습니다.
                </div>
            </c:if>

            <div class="login-btn-group">
                <button type="submit" class="btn btn-login">로그인</button>
                <button type="button" class="btn btn-signup" onclick="location.href='/msignup'">회원가입</button>
            </div>

            <div class="social-login-container">
                <a href="/oauth2/authorization/kakao" class="social-btn">
                    <img src="/image/kakao_login_medium_wide.png" alt="카카오 로그인">
                </a>

				<a href="/oauth2/authorization/google" class="google-rect-final">
				    <div class="google-icon-wrapper">
				        <svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" style="width: 20px; height: 20px; display: block;">
				            <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"></path>
				            <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"></path>
				            <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"></path>
				            <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"></path>
				        </svg>
				    </div>
				    <span class="google-text">Google 계정으로 로그인</span>
				</a>
			  </div>

            <div class="find-links">
                <a href="/mfindIdForm">아이디/비밀번호 찾기</a>
            </div>
        </form>
    </div>
    <%@ include file="/WEB-INF/views/user/member/mfaqChat.jsp" %>
</body>
</html>