<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>객실 등록</title>
<style>
    /* 1. 기본 초기화 및 배경 */
    body {
        background-color: #f1f5f9;
        margin: 0;
        padding: 0;
        min-height: 100vh;
        display: flex;
        flex-direction: column;
    }

    /* 2. 본문 영역 중앙 정렬 */
    main {
        flex: 1;
        display: flex;
        justify-content: center;
        align-items: flex-start; /* 헤더 바로 아래부터 자연스럽게 배치 */
        padding: 50px 20px;
    }

    /* 3. 등록 카드 컨테이너 (우측 상품등록 폼과 동일 규격) */
    .register-card {
        width: 100%;
        max-width: 900px; /* 상품등록 폼 크기에 맞춤 */
        background-color: #ffffff;
        padding: 60px 80px;
        border-radius: 15px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.03); /* 부드러운 그림자 */
        position: relative;
    }

    /* 4. PRICEO ADMIN 로고 텍스트 추가 (선택사항) */
    .logo-area a {
        text-decoration: none;
        color: #00b894;
        font-weight: 800;
        font-size: 20px;
        letter-spacing: -1px;
    }


    /* 5. 상단 타이틀 영역 */
    .title-area {
        text-align: center;
        margin-bottom: 50px;
    }

    .title-area h2 {
        font-size: 24px;
        font-weight: 700;
        margin-bottom: 12px;
        color: #333;
    }

    .title-underline {
        width: 35px;
        height: 3px;
        background-color: #00c4a7;
        margin: 0 auto 25px auto;
    }

    .info-text {
        font-size: 14px;
        color: #888;
    }

    /* 6. 테이블 스타일링 (라인 제거 및 간결한 구성) */
    table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 40px;
    }

    th {
        background-color: #fbfbfb;
        color: #444;
        font-size: 14px;
        font-weight: 600;
        text-align: left;
        padding: 22px 25px;
        width: 200px;
        border-bottom: 1px solid #f2f2f2;
    }

    td {
        padding: 15px 25px;
        border-bottom: 1px solid #f2f2f2;
    }

    /* 7. 입력 필드 (상품등록 폼과 동일한 라운드와 보더색) */
    input[type="text"], 
    input[type="number"] {
        width: 100%;
        padding: 12px 18px;
        border: 1px solid #dee2e6;
        border-radius: 8px;
        box-sizing: border-box;
        font-size: 14px;
        color: #495057;
        transition: all 0.2s ease;
    }

    input::placeholder {
        color: #adb5bd;
    }

    input:focus {
        outline: none;
        border-color: #00c4a7;
        box-shadow: 0 0 0 3px rgba(0, 196, 167, 0.1);
    }

    .unit-text {
        font-size: 14px;
        color: #444;
        margin-left: 10px;
        white-space: nowrap;
    }

    /* 8. 버튼 그룹 (상품등록하기 / 다시쓰기 / 관리자홈) */
    .btn-group {
        display: flex;
        justify-content: center;
        gap: 12px;
        margin-top: 30px;
    }

    .btn-submit {
        background-color: #00c4a7; /* PRICEO Mint */
        color: #ffffff;
        border: none;
        padding: 14px 35px;
        border-radius: 8px;
        font-weight: 700;
        font-size: 15px;
        cursor: pointer;
        transition: background 0.2s;
    }

    .btn-submit:hover {
        background-color: #00b096;
    }

    .btn-reset {
        background-color: #e9ecef;
        color: #495057;
        border: none;
        padding: 14px 25px;
        border-radius: 8px;
        font-weight: 500;
        font-size: 15px;
        cursor: pointer;
    }

    .btn-home {
        background-color: #ffffff;
        color: #00c4a7;
        border: 1.5px solid #00c4a7;
        padding: 13px 25px;
        border-radius: 8px;
        font-weight: 600;
        font-size: 15px;
        cursor: pointer;
        transition: all 0.2s;
    }

    .btn-home:hover {
        background-color: #00c4a7;
        color: #ffffff;
    }
</style>
</head>

<body>
<%@ include file="/WEB-INF/views/header.jsp" %>

    <main>
        <div class="register-card">
	        <div class="logo-area">
	            <a href="/adminhome">PRICEO ADMIN</a>
	        </div>

            <div class="title-area">
                <h2>객실 등록</h2>
                <div class="title-underline"></div>
                <p class="info-text">선택하신 숙소 내에 새로운 객실 타입을 추가합니다.</p>
            </div>

            <form action="${pageContext.request.contextPath}/roomInsert" method="post">
                <input type="hidden" name="s_no" value="${param.s_no}">

                <table>
                    <tr>
                        <th>객실 타입명</th>
                        <td><input type="text" name="sr_name" placeholder="상품 이름을 입력하세요" required></td>
                    </tr>
                    <tr>
                        <th>기준 인원</th>
                        <td>
                            <div style="display: flex; align-items: center;">
                                <input type="number" name="sr_people" min="1" max="20" placeholder="숫자만 입력" required>
                                <span class="unit-text">명</span>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th>평일 가격 (₩)</th>
                        <td>
                            <div style="display: flex; align-items: center;">
                                <input type="number" name="sr_lowprice" step="1000" placeholder="숫자만 입력" required>
                                <span class="unit-text">원</span>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th>주말 가격 (₩)</th>
                        <td>
                            <div style="display: flex; align-items: center;">
                                <input type="number" name="sr_highprice" step="1000" placeholder="숫자만 입력" required>
                                <span class="unit-text">원</span>
                            </div>
                        </td>
                    </tr>
                </table>

                <div class="btn-group">
                    <input type="submit" value="상품 등록하기" class="btn-submit">
                    <input type="reset" value="다시 쓰기" class="btn-reset">
                    <input type="button" value="관리자홈" class="btn-home" onclick="location.href='${pageContext.request.contextPath}/adminhome'">
                </div>
            </form>
        </div>
    </main>
</body>
</html>