<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>검색 결과 | PRICEO</title>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
/* 🥊 [추가] Sticky Footer를 위한 필수 설정 */
html, body {
    height: 100%;
    margin: 0;
}

body {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
}

/* 🥊 [수정] 메인 컨텐츠 영역이 남는 공간을 다 차지하도록 flex: 1 추가 */
.content-container {
    max-width: 1200px;
    margin: 0 auto;
    width: 100%;
    flex: 1; /* 이 설정이 푸터를 아래로 밀어냅니다 */
}

/* ===== 기존 제품 카드 스타일 그대로 유지 ===== */
.section-title { font-size: 22px; font-weight: 800; margin: 40px 0 20px; }
.product-grid { display: flex; flex-wrap: wrap; gap: 20px; }
.product-card { width: calc(25% - 15px); cursor: pointer; }
.img-box { width: 100%; aspect-ratio: 1 / 1; overflow: hidden; border-radius: 12px; background-color: #f5f5f5; position: relative; }
.img-box img { width: 100%; height: 100%; object-fit: cover; }
.badge-PRODUCT { position: absolute; top: 10px; left: 10px; background-color: #1e3a8a; color: white; padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: bold; z-index: 10; }
.badge-STAY { position: absolute; top: 10px; left: 10px; background-color: #ff5a5f; color: white; padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: bold; z-index: 10; }
.info-box { padding: 12px 5px; }
.product-name { font-size: 15px; font-weight: 600; margin-bottom: 6px; line-height: 1.4; }
.price-box { font-size: 18px; font-weight: 800; }
.menu-box { padding: 20px; border: 1px solid #e5e7eb; border-radius: 10px; margin-top: 20px; }
.menu-box a { color: #1e3a8a; font-weight: 700; }

/* 🥊 챗봇 버튼 설정 */
#faq-float-btn {
    display: block !important;
    visibility: visible !important;
    z-index: 9999999 !important;
    position: fixed !important;
    bottom: 20px !important;
    right: 20px !important;
}
</style>
</head>

<body>
<%@ include file="/WEB-INF/views/header.jsp" %>

<main class="content-container">
    <h2 style="margin-top:40px;">🔍 "<c:out value='${q}'/>" 검색 결과</h2>

<%-- 🎁 상품 섹션 --%>
<c:if test="${not empty productList}">
    <div class="section-title">🎁 상품</div>
    <div class="product-grid">
        <c:forEach var="p" items="${productList}">
            <div class="product-card" onclick="location.href='/pdetail?p_no=${p.p_no}'">
                <%-- 1. 이미지 박스 (위) --%>
                <div class="img-box">
                    <span class="badge-PRODUCT">상품</span>
                    <c:choose>
                        <%-- 아까 찾은 thumb 명찰 사용 🥊 --%>
                        <c:when test="${not empty p.thumb}">
                            <img src="/product/${p.thumb.trim()}">
                        </c:when>
                        <c:when test="${not empty p.p_image}">
                            <img src="/product/${p.p_image.trim()}">
                        </c:when>
                        <c:otherwise>
                            <img src="/product/no_image.png" alt="이미지 없음">
                        </c:otherwise>
                    </c:choose>
                </div>

                <%-- 2. 정보 박스 (아래) --%>
                <%-- 🥊 여기서 중요: info-box가 img-box 바깥, 하지만 product-card 안쪽에 있어야 합니다! --%>
                <div class="info-box">
                    <p style="font-weight:600; margin-top:10px; margin-bottom:5px; color:#333;">${p.p_name}</p>
                    <p style="font-weight:800; font-size:18px; color:#000;">
                        <fmt:formatNumber value="${p.p_price}" pattern="#,###"/>원
                    </p>
                </div>
            </div> <%-- product-card 닫기 --%>
        </c:forEach>
    </div>
</c:if>

<%-- 🏨 숙소 섹션 - 이름 & 가격 조합 --%>
<c:if test="${not empty stayList}">
    <div class="section-title">🏨 숙소</div>
    <div class="product-grid">
        <c:forEach var="s" items="${stayList}">
            <div class="product-card" onclick="location.href='/stayDetail?s_no=${s.s_no}'">
                <div class="img-box">
                    <span class="badge-STAY">숙소</span>
                    <c:choose>
                        <c:when test="${not empty s.s_image}">
                            <img src="/stay/${s.s_image.trim()}">
                        </c:when>
                        <c:otherwise>
                            <img src="/stay/no_image.png">
                        </c:otherwise>
                    </c:choose>
                </div>
                
                <div class="info-box">
                    <%-- 1. 숙소 이름 (굵고 깔끔하게) --%>
                    <div style="font-weight:700; font-size:16px; margin-top:10px; margin-bottom:5px; color:#222;">
                        ${s.s_name}
                    </div>
                    
                    <%-- 2. 숙소 가격 (min_price) --%>
                    <div style="font-weight:800; font-size:18px; color:#000;">
                        <c:choose>
                            <c:when test="${not empty s.min_price}">
                                <fmt:formatNumber value="${s.min_price}" pattern="#,###"/>원~
                            </c:when>
                            <c:otherwise>가격 정보 없음</c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
</c:if>

    <%-- 결과 없음 --%>
    <c:if test="${empty productList and empty stayList}">
        <p style="margin:60px 0; text-align:center; color:#999;">검색 결과가 없습니다.</p>
    </c:if>
</main>

<div id="autocompleteList" style="display: none;"></div>

<%@ include file="/WEB-INF/views/user/member/mfaqChat.jsp" %>
<%@ include file="/WEB-INF/views/footer.jsp" %>

<script>
$(document).ready(function() {
    const input = document.getElementById("searchInput");
    const listBox = document.getElementById("autocompleteList");
    if (input && listBox) {
        document.body.appendChild(listBox);
        const updatePosition = () => {
            const rect = input.getBoundingClientRect();
            listBox.style.top = (rect.bottom + window.scrollY) + 'px';
            listBox.style.left = (rect.left + 25) + 'px';
            listBox.style.width = (rect.width - 25) + 'px';
        };
        
        input.addEventListener("input", function() {
            const keyword = this.value.trim();
            if (!keyword) { $(listBox).hide(); return; }
            $.when(
                $.ajax({ url: "/stay/autocomplete", data: { q: keyword } }),
                $.ajax({ url: "/product/autocomplete", data: { q: keyword } })
            ).done(function(stayRes, productRes) {
                const stays = stayRes[0] || [];
                const products = productRes[0] || [];
                if (stays.length === 0 && products.length === 0) { $(listBox).hide(); return; }
                let html = "";
                stays.forEach(item => { html += `<div class="auto-item" style="padding:12px 20px; cursor:pointer; background:white;">🏨 \${item}</div>`; });
                products.forEach(item => { html += `<div class="auto-item" style="padding:12px 20px; cursor:pointer; background:white;">🎁 \${item}</div>`; });
                listBox.innerHTML = html;
                updatePosition();
                $(listBox).show();
                $('.auto-item').off('click').on('click', function() {
                    const txt = $(this).text().replace(/🏨|🎁/g, '').trim();
                    input.value = txt;
                    location.href = "/search?keyword=" + encodeURIComponent(txt);
                });
            });
        });
        window.addEventListener('scroll', updatePosition);
        window.addEventListener('resize', updatePosition);
    }
});
</script>
</body>
</html>