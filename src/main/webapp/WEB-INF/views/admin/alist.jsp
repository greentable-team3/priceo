<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>프라이스오 | 회원 관리 시스템</title>
<style>
    body {
        background-color: #f1f5f9; /* 관리자 공통 배경색 */
        font-family: 'Pretendard', -apple-system, sans-serif;
        margin: 0;
        padding: 0;
    }
    
	.logo-area a {
        text-decoration: none;
        color: #00b894;
        font-weight: 800;
        font-size: 20px;
        letter-spacing: -1px;
    }
	

    /* 화면 중앙 카드 레이아웃 */
    .admin-container {
        max-width: 1100px;
        margin: 60px auto;
        background: #ffffff;
        padding: 40px;
        border-radius: 20px;
        box-shadow: 0 10px 40px rgba(0,0,0,0.03);
    }

    h2 {
        color: #2d3436;
        font-size: 24px;
        margin-bottom: 30px;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    /* 테이블 디자인 (리뷰 관리와 통일) */
    .admin-table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 10px;
        font-size: 14px;
    }

    .admin-table thead th {
        background-color: #f9fbf9;
        color: #888;
        font-weight: 600;
        padding: 18px 10px;
        border-bottom: 1px solid #00b894; /* 관리자 포인트 그린 */
        text-align: center;
    }

    .admin-table tbody td {
        padding: 20px 10px;
        border-bottom: 1px solid #f1f1f1;
        text-align: center;
        vertical-align: middle;
        color: #555;
    }

    /* 아이디/이름 강조 */
    .member-id {
        font-weight: 700;
        color: #333;
    }

    /* 연락처 텍스트 스타일 */
    .contact-info {
        font-size: 13px;
        color: #999;
        line-height: 1.5;
    }

	 /* 행(Row) 호버 효과 */
    .admin-table tbody tr:hover {
        background-color: #fcfdfc;
    }
    
    /* 삭제 버튼 (리뷰 관리의 '삭제' 버튼 스타일 계승) */
    .btn-delete {
        background-color: #fff;
        color: #ff7675; /* 부드러운 빨간색 */
        border: 1px solid #ffccd5;
        padding: 6px 14px;
        border-radius: 8px;
        font-size: 12px;
        font-weight: 600;
        cursor: pointer;
        text-decoration: none;
        display: inline-block;
        transition: all 0.2s ease;
    }

    .btn-delete:hover {
        background-color: #fff5f5;
        border-color: #ff7675;
    }

    /* 하단 버튼 그룹 */
    .btn-group {
        margin-top: 30px;
        text-align: center;
    }

    .btn-list {
        background-color: #fff;
        color: #00b894;
        border: 1px solid #00b894;
        padding: 10px 25px;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: 0.2s;
    }

    .btn-list:hover {
        background-color: #00b894;
        color: #fff;
    }
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/header.jsp" %>
    <div class="admin-container">
   	<div class="logo-area">
    	<a href="/adminhome">PRICEO ADMIN</a>
    </div>
        <h2>👤 전체 회원 관리</h2>
        
        <table class="admin-table">
            <thead>
                <tr>
                    <th>번호</th>
                    <th>아이디</th>
                    <th>이름</th>
                    <th>이메일 / 전화번호</th>
                    <th>배송 주소</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="m" items="${member}">
                    <tr>
                        <td>${m.m_no}</td>
                        <td class="member-id">${m.m_id}</td>
                        <td>${m.m_name}</td>
                        <td class="contact-info">
                            ${m.m_email}<br>
                            ${m.m_tel}
                        </td>
                        <td style="text-align: center;">${m.m_addr}</td>
                        <td>
                            <a href="/delete?m_no=${m.m_no}&mode=delete"
                               class="btn-delete"
                               onclick="return confirm('${m.m_id} 회원을 강제 탈퇴 처리하시겠습니까?')">
                               삭제
                            </a>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty member}">
                    <tr>
                        <td colspan="6">등록된 회원이 없습니다.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>

        <div class="btn-group">
            <input type="button" value="관리자홈" class="btn-list" onclick="location.href='${pageContext.request.contextPath}/adminhome'">
        </div>
    </div>
</body>
</html>
