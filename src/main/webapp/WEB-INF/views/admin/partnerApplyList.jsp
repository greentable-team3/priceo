<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>입점 문의 관리</title>

<script>
// 브랜드 입점 문의 승인, 반려
function updateState(pa_no, pa_state) {
    if (!confirm(pa_state + " 처리하시겠습니까?")) return;

    fetch("/partner/admin/state", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded"
        },
        body: "pa_no=" + pa_no + "&pa_state=" + pa_state
    }).then(() => {
        location.reload();
    });
}

// 브랜드 입점 문의 신청 내역 삭제
function deleteApply(pa_no) {
    if (!confirm("해당 입점 문의를 삭제하시겠습니까?")) return;

    fetch("/partner/admin/delete", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded"
        },
        body: "pa_no=" + pa_no
    }).then(() => {
        alert("삭제되었습니다.");
        location.reload();
    });
}
</script>
<style>
    /* 1. 기본 레이아웃 및 배경 (추천 테마 반영) */
    body {
        background-color: #f1f5f9; 
        font-family: 'Pretendard', -apple-system, sans-serif;
        margin: 0;
        padding: 0;
    }

    .admin-container {
        max-width: 1200px;
        margin: 60px auto;
        background: #ffffff;
        padding: 40px;
        border-radius: 20px;
        box-shadow: 0 10px 40px rgba(0,0,0,0.03);
    }

    .logo-area a {
        text-decoration: none;
        color: #00b894;
        font-weight: 800;
        font-size: 20px;
        letter-spacing: -1px;
    }

    h2 {
        color: #1e293b;
        font-size: 26px;
        font-weight: 800;
        margin-bottom: 35px;
        display: flex;
        align-items: center;
        gap: 12px;
    }

    /* 2. 테이블 디자인 보정 */
    .admin-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 14px;
    }

    .admin-table thead th {
        background-color: #f8fafc;
        color: #64748b;
        font-weight: 700;
        padding: 20px 10px;
        border-bottom: 2px solid #00b894;
        text-align: center;
    }

    .admin-table tbody td {
        padding: 18px 10px;
        border-bottom: 1px solid #f1f5f9;
        text-align: center;
        vertical-align: middle;
        color: #334155;
    }

    .brand-name { font-weight: 800; color: #1e293b; }

    /* 3. 상태 배지 */
    .state-badge {
        padding: 5px 12px;
        border-radius: 6px;
        font-size: 12px;
        font-weight: 700;
    }
    .state-wait { background: #fff7ed; color: #ea580c; }
    .state-done { background: #f0fdf4; color: #16a34a; }
    .state-refuse { background: #fef2f2; color: #dc2626; }

    /* 4. 버튼 공통 스타일 */
    button, .btn-detail {
        padding: 8px 14px;
        border-radius: 8px;
        font-size: 12px;
        font-weight: 700;
        cursor: pointer;
        transition: all 0.2s;
        border: 1px solid #e2e8f0;
        background: #fff;
        display: inline-block;
        text-decoration: none;
    }

    /* 관리 버튼들 */
    .btn-approve { border-color: #00b894; color: #00b894; }
    .btn-approve:hover { background: #00b894; color: #fff; }

    .btn-refuse, .btn-delete { border-color: #ff7675; color: #ff7675; }
    .btn-refuse:hover, .btn-delete:hover { background: #ff7675; color: #fff; }

    /* [요구사항] 상세보기 버튼 스타일 (이미지의 주소검색 버튼 느낌 반영) */
    .btn-detail {
        background-color: #f8fafc;
        color: #64748b;
        border: 1px solid #e2e8f0;
        padding: 8px 16px;
    }

    .btn-detail:hover {
        background-color: #1e293b;
        color: #fff;
        border-color: #1e293b;
    }

    /* 5. 하단 관리자홈 버튼 */
    .footer-btn-area {
        margin-top: 40px;
        text-align: center;
    }
    .btn-home {
        background-color: #fff;
        color: #00b894;
        border: 2px solid #00b894;
        padding: 12px 35px;
        border-radius: 10px;
        font-size: 15px;
        font-weight: 700;
        text-decoration: none;
        display: inline-block;
        transition: 0.2s;
    }
    .btn-home:hover { background-color: #00b894; color: #fff; }
</style>
</head>

<body>
<%@ include file="/WEB-INF/views/header.jsp" %>
    <div class="admin-container">
        <div class="logo-area">
            <a href="/adminhome">PRICEO ADMIN</a>
        </div>

        <h2>🏢 입점 문의 관리</h2>

        <table class="admin-table">
            <thead>
                <tr>
                    <th>번호</th>
                    <th>브랜드명</th>
                    <th>담당자</th>
                    <th>연락처</th>
                    <th>유형</th>
                    <th>신청일</th>
                    <th>상태</th>
                    <th>관리</th>
                    <th>상세보기</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="p" items="${list}">
                <tr>
                    <td>${p.pa_no}</td>
                    <td class="brand-name">${p.pa_brand}</td>
                    <td>${p.pa_name}</td>
                    <td>${p.pa_tel}</td>
                    <td>${p.pa_type}</td>
                    <td><fmt:formatDate value="${p.pa_date}" pattern="yyyy-MM-dd HH:mm" /></td>
                    <td>
                        <c:choose>
                            <c:when test="${p.pa_state eq '접수완료'}">
                                <span class="state-badge state-wait">${p.pa_state}</span>
                            </c:when>
                            <c:when test="${p.pa_state eq '승인완료'}">
                                <span class="state-badge state-done">${p.pa_state}</span>
                            </c:when>
                            <c:otherwise>
                                <span class="state-badge state-refuse">${p.pa_state}</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <c:if test="${p.pa_state eq '접수완료'}">
                            <button class="btn-approve" onclick="updateState(${p.pa_no}, '승인완료')">승인</button>
                            <button class="btn-refuse" onclick="updateState(${p.pa_no}, '반려')">반려</button>
                        </c:if>

                        <c:if test="${p.pa_state ne '접수완료'}">
                            <button class="btn-delete" onclick="deleteApply(${p.pa_no})">삭제</button>
                        </c:if>
                    </td>
                    <td>
                    	<a href="partner/admin/partnerApplyDetail?pa_no=${p.pa_no}" class="btn-detail">상세보기</a>
                    </td>
                </tr>
                </c:forEach>
            </tbody>
        </table>

        <div class="footer-btn-area">
            <a href="/adminhome" class="btn-home">관리자홈</a>
        </div>
    </div>
</body>
</html>