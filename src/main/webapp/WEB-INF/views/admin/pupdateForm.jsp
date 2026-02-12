<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>상품 수정 | PRICEO ADMIN</title>
<style>
    /* 1. 기본 테마 설정 */
    :root {
        --primary-color: #00bfa5;
        --bg-color: #f1f5f9;
        --label-bg: #f9f9f9;
        --border-color: #eeeeee;
        --text-dark: #333333;
    }

    body {
        background-color: var(--bg-color); /* 배경색은 그대로 유지 */
        font-family: 'Noto Sans KR', sans-serif;
        margin: 0;
        padding: 0;
        /* display: flex 삭제 (헤더 정렬 방해 제거) */
    }

    /* 2. 관리자 카드 컨테이너 (여백 및 정렬 수정) */
    .admin-card {
        background: #ffffff;
        width: 100%;
        max-width: 800px;
        margin: 50px auto; /* 헤더 아래로 여백을 주고 가로 중앙 정렬 */
        padding: 50px;
        border-radius: 15px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.05);
        box-sizing: border-box; /* 패딩이 너비에 포함되도록 설정 */
    }

    /* 3. 헤더 영역 */
    .admin-header {
        text-align: center;
        margin-bottom: 40px;
    }
    
    .admin-logo {
        color: var(--primary-color);
        font-weight: 900;
        font-size: 20px;
        display: block;
        margin-bottom: 30px;
        letter-spacing: -0.5px;
        text-align: left; /* 이미지처럼 로고는 왼쪽 정렬 시 상단 배치 */
    }

    h3 {
        font-size: 26px;
        color: var(--text-dark);
        margin: 0;
        position: relative;
        display: inline-block;
        padding-bottom: 10px;
    }
    
    h3::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 50%;
        transform: translateX(-50%);
        width: 45px;
        height: 3px;
        background-color: var(--primary-color);
    }

    /* 4. 테이블 형태의 폼 레이아웃 */
    .edit-table {
        width: 100%;
        border-top: 1px solid var(--border-color);
        margin-top: 30px;
    }

    .row {
        display: flex;
        border-bottom: 1px solid var(--border-color);
    }

    .label-cell {
        width: 200px;
        background-color: var(--label-bg);
        display: flex;
        align-items: center;
        padding: 25px;
        font-weight: 600;
        color: #555;
        font-size: 15px;
        border-right: 1px solid var(--border-color);
        flex-shrink: 0; /* 라벨 너비 고정 */
    }

    .content-cell {
        flex: 1;
        display: flex;
        align-items: center;
        padding: 20px 30px;
    }

    /* 5. 이미지 및 입력창 스타일 */
    .img-preview {
        width: 220px;
        border-radius: 8px;
        border: 1px solid #ddd;
    }

    input[type="number"] {
        width: 100%;
        max-width: 300px;
        padding: 12px 15px;
        border: 1px solid #ddd;
        border-radius: 6px;
        font-size: 16px;
        outline: none;
    }

    input[type="number"]:focus {
        border-color: var(--primary-color);
    }

    .unit-text {
        margin-left: 12px;
        color: #777;
    }

    /* 6. 하단 버튼 그룹 */
    .btn-group {
        display: flex;
        justify-content: center;
        gap: 15px;
        margin-top: 40px;
    }

    button {
        padding: 14px 45px;
        border-radius: 8px;
        font-size: 16px;
        font-weight: 600;
        cursor: pointer;
        border: none;
        transition: all 0.2s;
    }

    .btn-submit { background-color: var(--primary-color); color: #fff; }
    .btn-submit:hover { background-color: #00a892; }
    .btn-back { background-color: #fff; color: var(--primary-color); border: 1.5px solid var(--primary-color); }
    .btn-back:hover { background-color: #f0fdfa; }
</style>

<script>
    // 기존 기능 유지
    function check(){
        let p = document.product;
        let Expprice=/^[0-9]*$/;
        
        if(!p.p_price.value || !Expprice.test(p.p_price.value)){ 
            alert("가격을 숫자로 입력해주세요."); 
            p.p_price.value = ""; 
            p.p_price.focus(); 
            return false; 
        }
        
        p.submit();
    }
</script>
</head>
<body>
<%@ include file="/WEB-INF/views/header.jsp" %>
    <div class="admin-card">
        <div class="admin-header">
            <span class="admin-logo">PRICEO ADMIN</span>
            <h3>상품 수정</h3>
        </div>

        <form name="product" action="/pupdate" method="post"> 
            <input type="hidden" name="p_no" value="${dto.p_no}">
            
            <div class="edit-table">
                <div class="row">
                    <div class="label-cell">현재 대표 이미지</div>
                    <div class="content-cell">
                        <img src="/product/${dto.p_image}" alt="대표 이미지" class="img-preview">
                    </div>
                </div>

                <div class="row">
                    <div class="label-cell">상품명</div>
                    <div class="content-cell">
                        <strong style="font-size: 17px; color: #333;">${dto.p_name}</strong>
                    </div>
                </div>

                <div class="row">
                    <div class="label-cell">판매 가격 (₩)</div>
                    <div class="content-cell">
                        <input type="number" id="p_price" name="p_price" value="${dto.p_price}">
                        <span class="unit-text">원</span>
                    </div>
                </div>
            </div>

            <div class="btn-group">
                <button type="button" class="btn-submit" onclick="check()">수정 완료</button>
                <button type="button" class="btn-back" onclick="history.back()">뒤로가기</button>
            </div>
        </form>
    </div>

</body>
</html>