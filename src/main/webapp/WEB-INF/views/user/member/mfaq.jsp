<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>PRICEO 메인</title>

<!-- ================= PUSH (절대 건들지 말 것) ================= -->
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="/js/Push.js"></script>

<!-- ================= STYLE ================= -->
<style>



/* ===== FOOTER ===== */
footer {
    /* 배경색을 참고 사이트처럼 연한 회색으로 변경 */
    background-color: #f8f9fa; 
    border-top: 1px solid #e9ecef;
    /* 위아래 여백을 더 넓혀서 안정감 부여 */
    padding: 80px 0; 
    font-family: 'Pretendard', sans-serif;
    color: #333;
}

.footer-container {
    max-width: 1200px;
    margin: 0 auto;
    display: flex;
    justify-content: space-between;
    padding: 0 40px;
}

/* 왼쪽: 회사 정보 영역 */
.footer-left {
    flex: 2;
}

.footer-logo {
    font-size: 30px; /* 로고 크기 살짝 키움 */
    font-weight: 900;
    letter-spacing: -1.5px;
    margin-bottom: 25px;
    color: #212529;
}

.company-info {
    font-size: 13px;
    line-height: 1.8;
    color: #6c757d; /* 배경색에 맞춰 텍스트 가독성 조정 */
}

.company-info span {
    margin-right: 15px;
}

.copyright {
    margin-top: 25px;
    font-size: 13px;
    color: #adb5bd;
}

/* 오른쪽: 고객센터 & 버튼 */
.footer-right {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 20px; /* 간격 최적화 */
    text-align: left;
}

.info-title {
    font-size: 14px;
    font-weight: 700;
    margin-bottom: 5px;
    color: #495057;
}

/* 고객센터 번호 */
.cs-number {
    font-size: 26px; /* 번호 강조 */
    font-weight: 800;
    margin-bottom: 5px;
    color: #212529;
}

.footer-btns {
    display: flex;
    gap: 10px;
    /* 마진을 15px에서 25px로 늘려 버튼과 시간 사이 간격을 확보합니다 */
    margin-top: 10px;
    margin-bottom: 10px; 
}

.cs-hours {
    font-size: 13px;
    color: #868e96;
    line-height: 1.8; /* 줄 간격도 살짝 넓혀서 가독성을 높였습니다 */
}

.footer-btn {
    display: inline-block;
    background-color: #1e3a8a;
    color: #fff !important;
    padding: 12px 18px; /* 버튼 도톰하게 */
    border-radius: 6px;
    font-size: 13px;
    font-weight: 600;
    text-align: center;
    text-decoration: none;
    transition: all 0.2s;
    flex: 1;
}

.footer-btn:hover {
    background-color: #0056b3;
    transform: translateY(-2px); /* 호버 시 살짝 들리는 효과 */
}

/* 자주 묻는 질문 버튼 */
.btn-faq {
    background-color: #6c757d; /* 차분한 그레이 */
}

.btn-faq:hover {
    background-color: #495057;
}

/* 1. 기본 레이아웃 및 배경 */
    body {
        background-color: #f8f9fa;
        font-family: 'Pretendard', -apple-system, sans-serif;
        margin: 0;
        padding: 0;
        display: flex;
        flex-direction: column;
        min-height: 100vh;
    }

    /* 헤더 보호 */
    header { display: block !important; width: 100% !important; }

    /* 2. FAQ 컨테이너 */
    .faq-container {
        width: 100%;
        max-width: 900px;
        margin: 60px auto;
        padding: 0 20px;
        box-sizing: border-box;
        flex: 1;
    }

    .faq-title {
        font-size: 32px;
        font-weight: 800;
        color: #1e3a8a; /* 네이비 포인트 */
        margin-bottom: 40px;
        text-align: center;
    }

    /* 3. FAQ 아이템 (카드 스타일) */
    .faq-item {
        background: #fff;
        border-radius: 12px;
        padding: 25px 30px;
        margin-bottom: 20px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.04);
        transition: transform 0.2s, box-shadow 0.2s;
        border-left: 5px solid #1e3a8a; /* 좌측 네이비 라인 포인트 */
    }

    .faq-item:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(0,0,0,0.08);
    }

    .question {
        font-size: 18px;
        font-weight: 700;
        color: #333;
        margin-bottom: 12px;
        display: flex;
        align-items: center;
    }

    /* Q 아이콘 추가 */
    .question::before {
        content: 'Q.';
        color: #1e3a8a;
        margin-right: 12px;
        font-size: 20px;
    }

    .answer {
        font-size: 15px;
        color: #666;
        line-height: 1.8;
        padding-left: 32px; /* Q 아이콘 너비만큼 여백 */
    }

    .answer b {
        color: #1e3a8a; /* 강조 텍스트 네이비색 */
    }

</style>

</head>
<body>
<%@ include file="/WEB-INF/views/header.jsp" %>



<!-- ================= FAQ CONTENT ================= -->
<div class="faq-container">
    <div class="faq-title">자주 묻는 질문</div>

    <div class="faq-item">
        <div class="question">입점 신청은 어떻게 하나요?</div>
        <div class="answer">
            홈페이지 상단 메뉴의 <b>입점 문의</b> 페이지에서 신청하실 수 있습니다.
        </div>
    </div>

    <div class="faq-item">
        <div class="question">입점 승인까지 얼마나 걸리나요?</div>
        <div class="answer">
            입점 신청 후 평균적으로 <b>3~5영업일</b> 정도 소요됩니다.
        </div>
    </div>

    <div class="faq-item">
        <div class="question">입점 비용이 있나요?</div>
        <div class="answer">
            기본 입점 비용은 없으며, 상품 판매 시 수수료만 발생합니다.
        </div>
    </div>

    <div class="faq-item">
        <div class="question">개인 사업자도 입점 가능한가요?</div>
        <div class="answer">
            네, 개인 사업자와 법인 사업자 모두 입점이 가능합니다.
        </div>
    </div>

    <div class="faq-item">
        <div class="question">승인 결과는 어디서 확인하나요?</div>
        <div class="answer">
            관리자 검토 완료 후 등록하신 이메일로 승인 결과를 안내드립니다.
        </div>
    </div>
</div>
<!-- ================= FAQ CONTENT END ================= -->


<!-- ================= FAQ 챗봇 (공통) ================= -->
<jsp:include page="/WEB-INF/views/user/member/mfaqChat.jsp" /> 
<!-- ================= FAQ 챗봇 END ================= -->



<!-- ================= FOOTER END ================= -->


<%@ include file="/WEB-INF/views/footer.jsp" %>

</body>
</html>