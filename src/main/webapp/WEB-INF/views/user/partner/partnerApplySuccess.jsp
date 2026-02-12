<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>입점 문의 완료</title>
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

    .complete-page-wrapper {
        flex: 1;
        display: flex;
        justify-content: center;
        align-items: center; /* 세로 중앙 정렬 */
        padding: 60px 20px;
        box-sizing: border-box;
    }

    /* 2. 완료 안내 카드 박스 */
    .box {
        width: 100%;
        max-width: 500px;
        background: #fff;
        padding: 60px 40px;
        border-radius: 16px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
        text-align: center; /* 텍스트 중앙 정렬 */
        box-sizing: border-box;
    }

    /* 체크 아이콘 스타일 (선택사항: 시각적 효과를 위해 추가) */
    .complete-icon {
        width: 70px;
        height: 70px;
        background-color: #f1f4ff;
        color: #1e3a8a;
        font-size: 40px;
        line-height: 70px;
        border-radius: 50%;
        margin: 0 auto 25px;
    }

    .box h2 {
        font-size: 26px;
        font-weight: 800;
        color: #1e3a8a; /* 네이비 포인트 */
        margin-top: 0;
        margin-bottom: 20px;
    }

    .box p {
        font-size: 16px;
        color: #555;
        line-height: 1.6;
        margin-bottom: 40px;
    }

    .box p strong {
        color: #333;
        font-weight: 700;
    }

    /* 3. 버튼 스타일 (네이비 #1e3a8a 고정) */
    .btn-main {
        display: inline-block;
        width: 100%;
        padding: 16px;
        background-color: #1e3a8a !important; /* 네이비 고정 */
        color: #fff !important;
        text-decoration: none;
        border-radius: 8px;
        font-size: 16px;
        font-weight: 700;
        transition: opacity 0.2s;
        box-sizing: border-box;
    }

    .btn-main:hover {
        opacity: 0.9;
    }
</style>
</head>
<body>

<%@ include file="/WEB-INF/views/header.jsp" %>

<div class="complete-page-wrapper">
    <div class="box">
        <div class="complete-icon">✓</div>

        <h2>입점 문의가 접수되었습니다</h2>
        <p>
            담당자가 내용을 확인한 후<br>
            <strong>승인 또는 반려 결과를 안내</strong>드릴 예정입니다.<br><br>
            빠른 시일 내에 연락드리겠습니다.
        </p>

        <a href="/main" class="btn-main">메인으로 이동</a>
    </div>
</div>
<%@ include file="/WEB-INF/views/user/member/mfaqChat.jsp" %>
<%@ include file="/WEB-INF/views/footer.jsp" %>
</body>
</html>