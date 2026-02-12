<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>브랜드 입점 신청 내역 상세보기</title>
<style>
    /* 1. 기본 레이아웃 및 배경 */
    body {
        background-color: #f1f5f9;
        font-family: 'Pretendard', -apple-system, sans-serif;
        margin: 0;
        padding: 0;
    }

    .admin-container {
        max-width: 800px;
        margin: 60px auto;
        background: #ffffff;
        padding: 45px;
        border-radius: 20px;
        box-shadow: 0 10px 40px rgba(0,0,0,0.03);
    }

    .logo-area {
        margin-bottom: 15px;
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
        font-size: 24px;
        font-weight: 800;
        margin-bottom: 10px;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    hr {
        border: 0;
        height: 3px;
        background: #00b894;
        width: 40px;
        margin: 0 0 40px 0;
    }

    /* 2. 상세 정보 테이블 스타일 */
    .detail-table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 40px;
    }

    .detail-table th {
        width: 25%;
        text-align: left;
        padding: 20px;
        background-color: #f8fafc;
        color: #64748b;
        font-size: 14px;
        font-weight: 700;
        border-bottom: 1px solid #f1f5f9;
    }

    .detail-table td {
        padding: 20px;
        border-bottom: 1px solid #f1f5f9;
        color: #1e293b;
        font-size: 15px;
        line-height: 1.6;
    }

    /* 문의 내용 영역 별도 스타일 */
    .content-area {
        min-height: 100px;
        white-space: pre-wrap; /* 줄바꿈 유지 */
    }

    /* 3. 상태 표시 배지 */
    .state-text {
        font-weight: 800;
        display: inline-block;
        padding: 4px 12px;
        border-radius: 6px;
        font-size: 13px;
    }
    .state-wait { background: #fff7ed; color: #ea580c; } /* 접수완료 */
    .state-done { background: #f0fdf4; color: #16a34a; } /* 승인완료 */
    .state-refuse { background: #fef2f2; color: #dc2626; } /* 반려 */

    /* 4. 버튼 영역 스타일 */
    .btn-group {
        display: flex;
        justify-content: center;
        gap: 12px;
        padding-top: 20px;
        border-top: 1px solid #f1f5f9;
    }

    button {
        padding: 12px 28px;
        border-radius: 10px;
        font-size: 14px;
        font-weight: 700;
        cursor: pointer;
        transition: all 0.2s;
        border: none;
    }

    /* 승인 버튼 */
    .btn-approve {
        background-color: #00b894;
        color: white;
    }
    .btn-approve:hover { background-color: #009678; }

    /* 반려 버튼 */
    .btn-refuse {
        background-color: #fff;
        color: #ff7675;
        border: 1px solid #ff7675;
    }
    .btn-refuse:hover { background-color: #fef2f2; }

    /* 삭제 버튼 */
    .btn-delete {
        background-color: #ff7675;
        color: white;
    }
    .btn-delete:hover { background-color: #e84118; }

    /* 목록으로 가기 버튼 */
    .btn-list {
        background-color: #f1f5f9;
        color: #64748b;
    }
    .btn-list:hover { background-color: #e2e8f0; }

</style>
<script>
// 기능 코드는 건드리지 않았습니다 (기존 유지)
function updateState(pa_no, pa_state) {
    if (!confirm(pa_state + " 처리하시겠습니까?")) return;
    fetch("/partner/admin/state", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: "pa_no=" + pa_no + "&pa_state=" + pa_state
    }).then(() => { location.reload(); });
}

function deleteApply(pa_no) {
    if (!confirm("해당 입점 문의를 삭제하시겠습니까?")) return;
    fetch("/partner/admin/delete", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: "pa_no=" + pa_no
    }).then(() => {
        alert("삭제되었습니다.");
        location.href = "/partner/partnerApplyList";
    });
}
</script>
</head>
<body>
    <%@ include file="/WEB-INF/views/header.jsp" %>
    
    <div class="admin-container">
        <div class="logo-area">
            <a href="/adminhome">PRICEO ADMIN</a>
        </div>
        <h2>🏢 입점 신청 상세 내역</h2>
        <hr>

        <table class="detail-table">
            <tr>
                <th>브랜드명</th>
                <td style="font-weight: 800;">${partnerApply.pa_brand}</td>
            </tr>
            <tr>
                <th>담당자 정보</th>
                <td>${partnerApply.pa_name} (${partnerApply.pa_tel})</td>
            </tr>
            <tr>
                <th>이메일</th>
                <td>${partnerApply.pa_email}</td>
            </tr>
            <tr>
                <th>입점 유형</th>
                <td>${partnerApply.pa_type}</td>
            </tr>
            <tr>
                <th>문의 내용</th>
                <td><div class="content-area">${partnerApply.pa_content}</div></td>
            </tr>
            <tr>
                <th>처리 상태</th>
                <td>
                    <span class="state-text ${partnerApply.pa_state eq '접수완료' ? 'state-wait' : (partnerApply.pa_state eq '승인완료' ? 'state-done' : 'state-refuse')}">
                        ${partnerApply.pa_state}
                    </span>
                </td>
            </tr>
        </table>

        <div class="btn-group">
            <c:if test="${partnerApply.pa_state eq '접수완료'}">
                <button class="btn-approve" onclick="updateState(${partnerApply.pa_no}, '승인완료')">입점 승인</button>
                <button class="btn-refuse" onclick="updateState(${partnerApply.pa_no}, '반려')">승인 반려</button>
            </c:if>
            <button class="btn-delete" onclick="deleteApply(${partnerApply.pa_no})">기록 삭제</button>
            <button class="btn-list" onclick="location.replace('/partner/partnerApplyList')">목록으로</button>
        </div>
    </div>
</body>
</html>