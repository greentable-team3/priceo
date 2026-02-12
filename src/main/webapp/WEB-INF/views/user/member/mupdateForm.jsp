<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<c:set var="telArr" value="${fn:split(update.m_tel, '-')}" />

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>정보 수정</title>
    <style>
    body {
        background-color: #f8f9fa;
        font-family: 'Pretendard', -apple-system, sans-serif;
        margin: 0;
        padding: 0;
    }

    .update-container {
        max-width: 600px;
        margin: 50px auto;
        background: #fff;
        padding: 40px;
        border-radius: 12px;
        box-shadow: 0 8px 20px rgba(0,0,0,0.05);
    }

    h2 {
        font-size: 24px;
        color: #333;
        margin-top: 0;
        margin-bottom: 10px;
        text-align: center;
    }

    .back-to-main {
        display: block;
        text-align: center;
        text-decoration: none;
        color: #888;
        font-size: 14px;
        margin-bottom: 30px;
    }

    hr {
        border: 0;
        border-top: 1px solid #eee;
        margin-bottom: 30px;
    }

    /* 입력 그룹 */
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

    .form-group label span {
        color: #ff4757;
    }

    input[type="text"],
    input[type="password"],
    input[type="email"] {
        width: 100%;
        padding: 12px;
        border: 1px solid #ddd;
        border-radius: 8px;
        font-size: 15px;
        box-sizing: border-box;
        transition: border-color 0.3s;
    }

    input[readonly] {
        background-color: #f1f1f1;
        cursor: not-allowed;
    }

    input:focus {
        border-color: #333;
        outline: none;
    }

    /* 주소 섹션 특화 */
    .address-group {
        display: flex;
        gap: 10px;
        margin-bottom: 10px;
    }

    .address-group input {
        flex: 1;
    }

    .btn-search {
        background-color: #1e3a8a;
        color: #fff;
        border: none;
        padding: 0 15px;
        border-radius: 8px;
        cursor: pointer;
        font-size: 14px;
        white-space: nowrap;
    }

    #pwMsg {
        font-size: 13px;
        margin-top: 5px;
    }

    /* 하단 버튼 영역 */
    .button-area {
        display: flex;
        gap: 10px;
        margin-top: 40px;
    }

    .btn {
        flex: 1;
        padding: 15px;
        border-radius: 8px;
        font-size: 16px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s;
        border: none;
    }

    .btn-cancel { background-color: #eee; color: #666; }
    .btn-reset { background-color: #f8f9fa; color: #888; border: 1px solid #ddd; }
    .btn-submit {  background-color: #1e3a8a; color: #fff;}

    .btn:hover { opacity: 0.9; transform: translateY(-1px); }
</style>
</head>

<body>
<%@ include file="/WEB-INF/views/header.jsp" %>

<div class="update-container">
    <h2>정보 수정</h2>
    <a href="/" class="back-to-main">메인으로 돌아가기</a>
    
    <hr>

    <form action="/update" method="post" name="mupdateForm">
        <input type="hidden" name="m_no" value="${update.m_no}">
        <input type="hidden" name="m_authority" value="${update.m_authority}">
        <input type="hidden" name="old_passwd" value="${update.m_passwd}">
        <input type="hidden" name="old_addr" value="${update.m_addr}">
        <input type="hidden" name="m_addr">

        <div class="form-group">
            <label>아이디</label>
            <input type="text" value="${update.m_id}" readonly>
        </div>

        <div class="form-group">
            <label>새 비밀번호</label>
            <input type="password" name="m_passwd" placeholder="변경 시에만 입력">
        </div>

        <div class="form-group">
            <label>비밀번호 확인</label>
            <input type="password" name="m_passwd2" oninput="checkpasswd();" placeholder="비밀번호 재입력">
            <div id="pwMsg"></div>
        </div>

        <div class="form-group">
            <label>이름</label>
            <input type="text" name="m_name" value="${update.m_name}">
        </div>

        <div class="form-group">
            <label>닉네임</label>
            <input type="text" name="m_nickname" value="${update.m_nickname}">
        </div>

		<div class="form-group">
		    <label>주소</label>
		    <div class="address-group">
		        <input type="text" id="postcode" placeholder="우편번호" readonly 
		               value="${fn:substringBefore(fn:substringAfter(update.m_addr, '('), ')')}">
		        <button type="button" class="btn-search" onclick="execDaumPostcode()">주소 검색</button>
		    </div>
		    
		    <input type="text" id="roadAddress" name="road_Address" placeholder="도로명 주소" readonly 
		           style="margin-bottom: 10px;">
		    
		    <input type="text" id="detailAddress" placeholder="상세 주소">
		</div>

        <div class="form-group">
            <label>이메일</label>
            <input type="email" name="m_email" value="${update.m_email}">
        </div>

        <div class="form-group">
            <label>연락처 <span>*</span></label>
            <input
                type="text"
                id="phone"
                placeholder="-없이 숫자만 입력하세요"
                maxlength="13"
                oninput="formatPhone(this)"
                value="${update.m_tel}"
            >
            <input type="hidden" name="m_tel" value="${update.m_tel}">  
        </div>

        <div class="button-area">
            <button type="button" class="btn btn-cancel" onclick="location.href='/myinfo'">취소</button>
            <button type="reset" class="btn btn-reset">초기화</button>
            <button type="button" class="btn btn-submit" onclick="check()">정보 수정 완료</button>
        </div>
    </form>
</div>
<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script src="/js/Update.js"></script>
<%@ include file="/WEB-INF/views/footer.jsp" %>
<%@ include file="/WEB-INF/views/user/member/mfaqChat.jsp" %>
</body>
</html>
