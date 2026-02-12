<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>내 정보</title>
    <style>
    /* 마이페이지 전체 컨테이너 */
.mypage-container {
    max-width: 800px; /* 너무 넓지 않게 조정하여 가독성 높임 */
    margin: 50px auto;
    padding: 0 20px;
    font-family: 'Pretendard', -apple-system, sans-serif;
}

.mypage-header {
    text-align: center;
    margin-bottom: 40px;
}

.mypage-header h3 {
    font-size: 28px;
    letter-spacing: 2px;
    color: #333;
    margin-bottom: 10px;
}

/* 유저 환영 카드 */
.welcome-card {
    background: #f8f9fa;
    padding: 30px;
    border-radius: 12px;
    text-align: center;
    margin-bottom: 30px;
}

.welcome-card h4 {
    margin: 0;
    font-size: 20px;
    color: #222;
}

.welcome-card span {
    color: #1e3799; /* 포인트 컬러 */
    font-weight: bold;
}

/* 정보 테이블 스타일링 */
.info-table {
    width: 100%;
    border-collapse: collapse;
    background: #fff;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 4px 15px rgba(0,0,0,0.05);
    margin-bottom: 40px;
}

.info-table th, .info-table td {
    padding: 20px;
    border-bottom: 1px solid #f1f1f1;
    text-align: left;
}

.info-table th {
    background-color: #fafafa;
    width: 30%;
    color: #666;
    font-weight: 600;
}

.info-table td {
    color: #333;
}

.info-table tr:last-child th, 
.info-table tr:last-child td {
    border-bottom: none;
}

/* 버튼 그룹 */
.action-buttons {
    display: flex;
    gap: 15px;
    justify-content: center;
    margin-bottom: 20px;
}

.btn {
    display: inline-block;
    padding: 12px 30px;
    border-radius: 8px;
    text-decoration: none;
    font-size: 15px;
    font-weight: 600;
    transition: all 0.3s ease;
}

.btn-update {
    background-color: #1e3a8a;
    color: #fff;
}

.btn-update:hover {
    background-color: #1e3a8a;
    transform: translateY(-2px);
}

.btn-delete {
    background-color: #fff;
    color: #ff4757;
    border: 1px solid #ff4757;
}

.btn-delete:hover {
    background-color: #ff4757;
    color: #fff;
}

.home-link {
    text-align: center;
    margin-top: 30px;
}

.home-link a {
    color: #888;
    text-decoration: underline;
    font-size: 14px;
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/header.jsp" %>

<%-- 본문 영역 --%>
<main class="mypage-container">
    <div class="mypage-header">
        <h3>MY INFO</h3>
    </div>

    <div class="welcome-card">
        <h4><span>${member.m_name}</span>님, 환영합니다!</h4>
    </div>

    <table class="info-table">
        <tr>
            <th>회원번호</th>
            <td>${member.m_no}</td>
        </tr>
        <tr>
            <th>아이디</th>
            <td>${member.m_id}</td>
        </tr>
        <tr>
            <th>이름</th>
            <td>${member.m_name}</td>
        </tr>
        <tr>
            <th>전화번호</th>
            <td>${member.m_tel}</td>
        </tr>
    </table>

    <div class="action-buttons">
        <a href="/mpasswordCheckForm?m_no=${m_no}&mode=update" class="btn btn-update">회원 정보 수정</a>
        <a href="/mpasswordCheckForm?m_no=${m_no}&mode=delete" class="btn btn-delete">회원 탈퇴</a>
    </div>

    <div class="home-link">
        <a href="/main">홈으로 돌아가기</a>
    </div>
</main>
<%@ include file="/WEB-INF/views/footer.jsp" %>
<%@ include file="/WEB-INF/views/user/member/mfaqChat.jsp" %>
<script>
function handleLogout() {
    const auth = "${sessionScope.m_authority}";
    if (auth === "KAKAO") {
        const restApiKey = "2d3fdb24faa5714d6045ec8a349c7b57";
        const redirectUri = encodeURIComponent("http://localhost:8080/logout");
        location.href =
            "https://kauth.kakao.com/oauth/logout?client_id="
            + restApiKey
            + "&logout_redirect_uri="
            + redirectUri;
    } else {
        location.href = "/logout";
    }
}
</script>

</body>
</html>
