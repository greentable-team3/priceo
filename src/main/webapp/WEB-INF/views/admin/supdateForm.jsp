<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>숙소 정보 수정 | PRICEO ADMIN</title>
<style>
    /* 1. 기본 테마 설정 - 우측 양식과 동일한 색상값 추출 */
    :root {
        --primary-mint: #00c4a7; /* PRICEO 시그니처 민트 */
        --bg-gray: #f1f5f9;      /* 관리자 배경 그레이 */
        --border-light: #f1f3f5;
        --text-main: #333333;
        --text-muted: #868e96;
    }

    body {
        background-color: var(--bg-gray);
        margin: 0;
        padding: 0;
        font-family: 'Pretendard', 'Malgun Gothic', sans-serif;
    }

    /* 2. 관리자 카드 컨테이너 - 우측 폼과 동일한 그림자 및 여백 */
    .admin-card {
        background: #ffffff;
        width: 100%;
        max-width: 850px;
        margin: 60px auto;
        padding: 60px 80px;
        border-radius: 15px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.03);
        box-sizing: border-box;
    }

    /* 3. 헤더 영역 - 로고 폰트 및 중앙 정렬 최적화 */
    .admin-header {
        text-align: center;
        margin-bottom: 50px;
    }
    
    .admin-logo {
        color: var(--primary-mint);
        font-weight: 900;
        font-size: 20px;
        display: block;
        margin-bottom: 30px;
        letter-spacing: -0.5px;
        text-align: left; /* 이미지처럼 로고는 왼쪽 정렬 시 상단 배치 */
    }

    h3 {
        font-size: 24px;
        font-weight: 700;
        color: var(--text-main);
        margin: 0;
        padding-bottom: 12px;
        display: inline-block;
        position: relative;
    }
    
    /* 제목 하단 민트색 선 */
    h3::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 50%;
        transform: translateX(-50%);
        width: 35px;
        height: 3px;
        background-color: var(--primary-mint);
    }

    /* 4. 테이블 형태 레이아웃 - 상품등록 양식처럼 깔끔하게 */
    .edit-table {
        width: 100%;
        margin-top: 40px;
        border-top: 1px solid var(--border-light);
    }

    .row {
        display: flex;
        border-bottom: 1px solid var(--border-light);
    }

    .label-cell {
        width: 180px;
        background-color: #fbfbfb; /* 우측 폼 라벨 배경색 */
        padding: 22px 25px;
        font-weight: 600;
        color: #495057;
        font-size: 14px;
        display: flex;
        align-items: center;
        flex-shrink: 0;
    }

    .content-cell {
        flex: 1;
        padding: 20px 30px;
        display: flex;
        flex-direction: column;
        justify-content: center;
        background-color: #fff;
    }

    /* 5. 이미지 미리보기 및 파일 필드 */
    .img-preview {
        width: 200px;
        border-radius: 8px;
        border: 1px solid #dee2e6;
        margin-bottom: 15px;
    }

    .stay-name {
        font-size: 16px;
        color: #212529;
        font-weight: 700;
    }

    .sub-text {
        font-size: 13px;
        color: #adb5bd;
        margin-left: 8px;
    }

    input[type="file"] {
        font-size: 13px;
        border: 1px solid #dee2e6;
        padding: 8px;
        border-radius: 5px;
        width: 100%;
        max-width: 400px;
    }

    /* 6. 하단 버튼 그룹 - 우측 폼 버튼 스타일 복제 */
    .btn-group {
        display: flex;
        justify-content: center;
        gap: 12px;
        margin-top: 40px;
    }

    input[type="submit"], input[type="button"] {
        padding: 13px 35px;
        border-radius: 8px;
        font-size: 15px;
        font-weight: 700;
        cursor: pointer;
        transition: all 0.2s ease;
        border: none;
    }

    /* 수정 완료 버튼 (Mint 배경) */
    input[type="submit"] {
        background-color: var(--primary-mint);
        color: #ffffff;
    }

    input[type="submit"]:hover {
        background-color: #00b096;
    }

    /* 취소 버튼 (White + Mint 테두리) */
    input[type="button"] {
        background-color: #ffffff;
        color: var(--primary-mint);
        border: 1.5px solid var(--primary-mint);
        padding: 11.5px 35px; /* 보더 두께만큼 패딩 미세 조정 */
    }

    input[type="button"]:hover {
        background-color: var(--primary-mint);
        color: #ffffff;
    }

    /* 안내 텍스트 라벨링 */
    .label-hint {
        font-size: 13px;
        color: var(--text-muted);
        margin-bottom: 8px;
        font-weight: 600;
    }
</style>
</head>
<body>

    <%@ include file="/WEB-INF/views/header.jsp" %>

    <div class="admin-card">
        <div class="admin-header">
            <span class="admin-logo">PRICEO ADMIN</span>
            <h3>숙소 정보 수정</h3>
        </div>

        <form action="${pageContext.request.contextPath}/stayUpdate" method="post" enctype="multipart/form-data">
            <input type="hidden" name="s_no" value="${dto.s_no}">
            <input type="hidden" name="s_image" value="${dto.s_image}">

            <div class="edit-table">
                <div class="row">
                    <div class="label-cell">숙소명</div>
                    <div class="content-cell">
                        <span class="stay-name">${dto.s_name}</span>
                        <span class="sub-text">(수정 불가)</span>
                    </div>
                </div>

                <div class="row">
                    <div class="label-cell">대표 이미지</div>
                    <div class="content-cell">
                        <c:if test="${not empty dto.s_image}">
                            <div style="margin-bottom: 10px; font-size: 14px; color: #666; font-weight: 600;">현재 이미지</div>
                            <img src="${pageContext.request.contextPath}/stay/${dto.s_image}" class="img-preview">
                        </c:if>
                        <div style="margin-bottom: 8px; font-size: 14px; color: #666; font-weight: 600;">변경 시 선택</div>
                        <input type="file" name="imageFile">
                    </div>
                </div>
            </div>
            
            <div class="btn-group">
                <input type="submit" value="수정 완료">
                <input type="button" value="취소" onclick="history.back()">
            </div>
        </form>
    </div>

</body>
</html>