<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자화면</title>
<style>
    body {
    /* 1. 배경색을 연한 그레이 블루로 변경 (더 안정감 있음) */
    background-color: #f1f5f9; 
    font-family: 'Pretendard', sans-serif;
    margin: 0;
}

.admin-dashboard-container {
    max-width: 1100px;
    margin: 50px auto;
    padding: 0 20px;
}

/* 관리자 대시보드 타이틀 포인트 */
h2.admin-title {
    font-size: 24px;
    font-weight: 700;
    color: #1e293b;
    border-left: 5px solid #1e3a8a; /* 민트색 대신 브랜드 네이비 사용 */
    padding-left: 15px;
    margin-bottom: 40px;
}

/* 카드 스타일 보정 */
.admin-card {
    background: #ffffff;
    border: 1px solid #e2e8f0;
    border-radius: 12px;
    padding: 30px;
    text-align: center;
    transition: all 0.2s ease-in-out;
    /* 그림자를 더 은은하게 변경 */
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
}

.admin-card:hover {
    transform: translateY(-5px);
    /* 호버 시 테두리를 브랜드 네이비로 */
    border-color: #1e3a8a;
    box-shadow: 0 10px 15px -3px rgba(30, 58, 138, 0.1);
}

.admin-card img {
    width: 40px;
    margin-bottom: 15px;
}

.admin-card span {
    display: block;
    font-size: 15px;
    font-weight: 600;
    color: #334155;
}

    .admin-container {
        max-width: 950px;
        margin: 80px auto; /* 상단 여백 80px 확보 */
        padding: 20px;
    }

    .admin-header {
        margin-bottom: 40px;
        border-left: 5px solid #00b894; /* 포인트 컬러: 초록색 */
        padding-left: 15px;
    }

    .admin-header h2 {
        font-size: 28px;
        margin: 0;
        color: #2d3436;
    }

    /* 메뉴 그리드 */
    .admin-menu-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
        gap: 25px;
    }

    /* 메뉴 카드 */
    .menu-card {
        background: #fff;
        padding: 30px 20px;
        border-radius: 15px;
        text-align: center;
        text-decoration: none;
        color: #333;
        font-weight: 600;
        box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        border: 1px solid #e1e8e3;
    }

    .menu-card:hover {
        transform: translateY(-8px);
        box-shadow: 0 15px 30px rgba(0, 184, 148, 0.15); /* 초록색 그림자 효과 */
        border-color: #00b894;
        color: #00b894;
    }

    /* 브랜드 입점 관리 (강조 카드) */
    .menu-card.highlight {
        background-color: #e6f7f4;
        border-color: #00b894;
    }

    .menu-card::before {
        content: '⚙️'; /* 관리자 느낌 아이콘 추가 */
        font-size: 28px;
        margin-bottom: 12px;
        display: block;
    }
    
	    /* 메인홈 바로가기 버튼 전용 아이콘 및 스타일 */
	.menu-card.btn-go-main::before {
	    content: '🏠'; /* 집 모양 아이콘으로 변경 */
	}
	
	.menu-card.btn-go-main {
	    background-color: #f8f9fa; /* 약간 차분한 회색 배경 */
	    border-color: #dee2e6;
	}
	
	.menu-card.btn-go-main:hover {
	    background-color: #fff;
	    border-color: #00b894;
	}
    
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/header.jsp" %>
    <div class="admin-container">
        <div class="admin-header">
            <h2>관리자 대시보드</h2>
        </div>

        <div class="admin-menu-grid">
			<a href="/" class="menu-card btn-go-main">메인홈 바로가기</a>
            <a href="/pinsertForm" class="menu-card">상품 등록</a>
            <a href="/stayInsertForm" class="menu-card highlight">숙소 등록</a>
            <a href="/plist" class="menu-card highlight">상품 목록</a>
            <a href="/stayList" class="menu-card">숙소 목록</a>
            <a href="/adminreviewlist" class="menu-card">리뷰 관리</a>
            <a href="/adminorderlist" class="menu-card">주문/예약 목록</a>
            <a href="/alist" class="menu-card">회원 목록</a>
            <a href="/partner/partnerApplyList" class="menu-card highlight">브랜드 입점 관리</a>
        </div>
    </div>
</body>
</html>