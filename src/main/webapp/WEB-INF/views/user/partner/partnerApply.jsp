<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>



<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>입점 문의</title>
<style>
    /* 1. 기본 레이아웃 및 헤더 간섭 방지 */
    body {
        background-color: #f8f9fa;
        font-family: 'Pretendard', -apple-system, sans-serif;
        margin: 0;
        padding: 0;
        display: flex;
        flex-direction: column;
        min-height: 100vh;
    }

    /* 헤더 깨짐 방지 */
    header { display: block !important; width: 100% !important; }

    .apply-page-wrapper {
        flex: 1;
        display: flex;
        justify-content: center;
        padding: 60px 20px;
        box-sizing: border-box;
    }

    /* 2. 입점 문의 카드 박스 */
    .form-box {
        width: 100%;
        max-width: 550px;
        background: #fff;
        padding: 45px;
        border-radius: 16px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
        box-sizing: border-box;
    }

    .form-box h2 {
        font-size: 26px;
        font-weight: 800;
        color: #1e3a8a; /* 네이비 포인트 */
        text-align: center;
        margin-top: 0;
        margin-bottom: 35px;
    }

    /* 3. 폼 요소 스타일 */
    form label {
        display: block;
        font-size: 14px;
        font-weight: 600;
        color: #333;
        margin-bottom: 8px;
        margin-top: 15px;
    }

    form label span {
        color: #e63946; /* 필수 표시 별표 */
    }

    input[type="text"],
    input[type="email"],
    select,
    textarea {
        width: 100%;
        padding: 12px 15px;
        border: 1px solid #ddd;
        border-radius: 8px;
        font-size: 15px;
        outline: none;
        box-sizing: border-box;
        transition: border-color 0.2s;
    }

    input:focus, select:focus, textarea:focus {
        border-color: #1e3a8a;
    }

    textarea {
        resize: none;
        line-height: 1.5;
    }

    /* 4. 제출 버튼 (네이비 #1e3a8a 고정) */
    button[type="submit"] {
        width: 100%;
        padding: 16px;
        background-color: #1e3a8a !important; /* 네이비 고정 */
        color: #fff !important;
        border: none;
        border-radius: 8px;
        font-size: 16px;
        font-weight: 700;
        cursor: pointer;
        margin-top: 30px;
        transition: opacity 0.2s;
    }

    button[type="submit"]:hover {
        opacity: 0.9;
    }

    /* 연락처 전용 스타일 (추가 여백 조절) */
    .phone-group {
        margin-bottom: 5px;
    }
</style>
</head>
<body>

<%@ include file="/WEB-INF/views/header.jsp" %>

<div class="apply-page-wrapper">
    <div class="form-box">
        <h2>브랜드 입점 문의</h2>

        <form method="post" action="/partner/apply" name="partnerApply">

            <label>브랜드명</label>
            <input type="text" name="pa_brand" placeholder="브랜드명을 입력하세요" required>

            <label>담당자 이름</label>
            <input type="text" name="pa_name" placeholder="담당자 성함을 입력하세요" required>
            
            <div class="phone-group">
                <label>연락처 <span>*</span></label>
                <input
                    type="text"
                    id="phone"
                    placeholder="-없이 숫자만 입력하세요"
                    maxlength="13"
                    oninput="formatPhone(this)"
                    required
                >
            </div>
            
            <input type="hidden" name="pa_tel" id="pa_tel">  

            <label>이메일</label>
            <input type="email" name="pa_email" placeholder="example@email.com" required>

            <label>입점 유형</label>
            <select name="pa_type" required>
                <option value="">유형을 선택하세요</option>
                <option value="푸드">푸드</option>
                <option value="전자기기">전자기기</option>
                <option value="숙소">숙소</option>
                <option value="뷰티">뷰티</option>
            </select>

            <label>문의 내용</label>
            <textarea name="pa_content" rows="6" placeholder="문의하실 내용을 상세히 적어주세요" required></textarea>

            <button type="submit">입점 문의 신청</button>

        </form>
    </div>
</div>
<%@ include file="/WEB-INF/views/user/member/mfaqChat.jsp" %>
<%@ include file="/WEB-INF/views/footer.jsp" %>
<script>
    function formatPhone(input) {
        let numbers = input.value.replace(/\D/g, "");
    
        if (numbers.length > 11) {
            numbers = numbers.slice(0, 11);
        }
    
        let formatted = "";
    
        if (numbers.length <= 3) {
            formatted = numbers;
        } else if (numbers.length <= 7) {
            formatted = numbers.slice(0, 3) + "-" + numbers.slice(3);
        } else {
            formatted =
                numbers.slice(0, 3) +
                "-" +
                numbers.slice(3, 7) +
                "-" +
                numbers.slice(7);
        }
    
        input.value = formatted;
        document.partnerApply.pa_tel.value = formatted;
    }
</script>

</body>
</html>