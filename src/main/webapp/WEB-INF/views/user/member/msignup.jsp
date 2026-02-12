<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>회원가입 - Priceo</title>
    
    <!-- 카카오 우편 번호 서비스 API, 유효성 검사, Ajax -->
    <script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="/js/Member.js"></script>
    <style>
	.signup-container {
	    max-width: 550px;
	    /* margin: 0 auto; 를 아래처럼 수정하세요 */
	    margin: 60px auto; /* 위아래 60px 여백을 주어 공백을 확보합니다 */
	    background: #fff;
	    padding: 40px;
	    border-radius: 16px;
	    box-shadow: 0 10px 30px rgba(0,0,0,0.08);
	}

    .form-title {
        font-size: 24px;
        font-weight: 700;
        color: #333;
        margin-bottom: 30px;
        text-align: center;
        border-bottom: 2px solid #2d3436;
        padding-bottom: 10px;
        display: inline-block;
    }

    .title-wrapper { text-align: center; }

    /* 각 입력 섹션 스타일 */
    .form-section {
        margin-bottom: 25px;
    }

    .form-section label {
        display: block;
        font-size: 14px;
        font-weight: 600;
        color: #555;
        margin-bottom: 8px;
    }

    .form-section label span {
        color: #ff4757; /* 필수 입력 표시 */
    }

    /* 입력창 공통 스타일 */
    input[type="text"],
    input[type="password"],
    input[type="email"] {
        width: 100%;
        padding: 12px 15px;
        border: 1px solid #ddd;
        border-radius: 8px;
        font-size: 15px;
        box-sizing: border-box;
        transition: all 0.3s;
    }

    input:focus {
        border-color: #0984e3;
        outline: none;
        box-shadow: 0 0 0 3px rgba(9, 132, 227, 0.1);
    }

    /* 버튼과 인풋이 같이 있는 레이아웃 */
    .input-with-btn {
        display: flex;
        gap: 8px;
        margin-bottom: 8px;
    }

    /* 보조 버튼 (중복검사, 주소검색 등) */
    .btn-sub {
        background-color: #1e3a8a;
        color: #fff;
        border: none;
        padding: 0 15px;
        border-radius: 8px;
        cursor: pointer;
        font-size: 13px;
        white-space: nowrap;
        transition: 0.3s;
    }

    .btn-sub:hover { background-color: #000; }

    /* 하단 메인 버튼 */
    .btn-submit {
        width: 100%;
        padding: 16px;
        background-color: #1e3a8a;
        color: #fff;
        border: none;
        border-radius: 8px;
        font-size: 18px;
        font-weight: 700;
        cursor: pointer;
        margin-top: 20px;
        transition: 0.3s;
    }

    .btn-submit:hover {
        background-color: #0873c4;
        transform: translateY(-1px);
    }

    /* 하단 보조 링크 영역 */
    .footer-btns {
        margin-top: 25px;
        text-align: center;
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 15px;
        color: #ccc;
    }

    .footer-btns button {
        background: none;
        border: none;
        color: #888;
        cursor: pointer;
        font-size: 14px;
        text-decoration: underline;
    }

    /* 유효성 메시지 */
    #idMsg, #pwMsg, #auth-msg {
        font-size: 12px;
        display: block;
        margin-top: 5px;
    }
</style>
</head>

<body>
<%@ include file="/WEB-INF/views/header.jsp" %>
<div class="signup-container">
    <div class="title-wrapper">
        <div class="form-title">회원가입</div>
    </div>

    <form action="/write" method="post" name="msignup" id="msignup" onsubmit="return check();">
        <input type="hidden" name="m_addr" id="m_addr_hidden">

        <div class="form-section">
            <label>아이디 <span>*</span></label>
            <div class="input-with-btn">
                <input type="text" name="m_id" id="m_id" oninput="resetIdCheck()" placeholder="아이디를 입력해주세요" required>
                <button type="button" class="btn-sub" onclick="checkId();">중복검사</button>
            </div>
            <span id="idMsg"></span>
        </div>

        <div class="form-section">
            <label>비밀번호 <span>*</span></label>
            <input type="password" name="m_passwd" placeholder="비밀번호 입력" required style="margin-bottom: 10px;">
            <label>비밀번호 확인 <span>*</span></label>
            <input type="password" name="m_passwd2" oninput="checkpasswd();" placeholder="비밀번호 재입력" required>
            <span id="pwMsg"></span>
        </div>

        <div class="form-section">
            <div style="display: flex; gap: 15px;">
                <div style="flex: 1;">
                    <label>이름 <span>*</span></label>
                    <input type="text" name="m_name" placeholder="실명을 입력하세요" required>
                </div>
                <div style="flex: 1;">
                    <label>닉네임 <span>*</span></label>
                    <input type="text" name="m_nickname" placeholder="활동 닉네임">
                </div>
            </div>
        </div>
        
        <div class="form-section">
            <label>연락처 <span>*</span></label>
            <input type="text" id="phone" placeholder="-없이 숫자만 입력하세요" maxlength="13" oninput="formatPhone(this)" required>
            <input type="hidden" name="m_tel" id="m_tel">  
        </div>

        <div class="form-section">
            <label>배송 주소 <span>*</span></label>
            <div class="input-with-btn">
                <input type="text" id="postcode" placeholder="우편번호" readonly>
                <button type="button" class="btn-sub" onclick="execDaumPostcode()">주소 검색</button>
            </div>
            <input type="text" id="roadAddress" placeholder="도로명 주소" readonly style="margin-bottom: 8px;">
            <input type="text" id="detailAddress" placeholder="상세 주소를 입력해주세요">
        </div>

        <div class="form-section">
            <label>이메일 <span>*</span></label>
            <div class="input-with-btn">
                <input type="email" name="m_email" id="m_email" placeholder="example@email.com" required>
                <button type="button" id="send-btn" class="btn-sub" onclick="sendJoinEmail();">인증요청</button>
            </div>
        </div>

        <div id="auth-section" class="form-section" style="display:none;">
            <label>인증번호 입력</label>
            <div class="input-with-btn">
                <input type="text" id="auth_code" placeholder="6자리 숫자">
                <button type="button" id="verify-btn" class="btn-sub" onclick="verifyEmailCode();">확인</button>
            </div>
            <span id="auth-msg"></span>
        </div>

        <button type="submit" class="btn-submit">가입하기</button>
        
        <div class="footer-btns">
            <button type="reset">다시 작성</button>
            <span>|</span>
            <button type="button" onclick="history.back()">뒤로 가기</button>
        </div>
    </form>
     <%@ include file="/WEB-INF/views/user/member/mfaqChat.jsp" %>
</div>
<%@ include file="/WEB-INF/views/footer.jsp" %>
</body>
 
</html>
