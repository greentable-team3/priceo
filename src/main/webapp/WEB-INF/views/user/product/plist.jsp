<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<!DOCTYPE html>
<html>
<head>
<!-- ================= PUSH (절대 건들지 말 것) ================= -->
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="/js/Push.js"></script>
<meta charset="UTF-8">
<title>상품목록</title>
<style>


    .product-container {
        display: flex;
        flex-wrap: wrap;
        gap: 30px 20px;
        max-width: 1200px;
        margin: 0 auto;
        padding: 40px 20px;
        background-color: transparent; 
    }
    
    .product-card {
        width: calc(33.333% - 14px);
        cursor: pointer;
        transition: transform 0.2s ease;
    }

    @media (max-width: 900px) {
        .product-card { width: calc(50% - 10px); }
    }

	.product-card:hover .img-box img {
        transform: scale(1.05); /* 호버 시 이미지가 살짝 커짐 */
    }
    
    .img-box {
        width: 100%;
        aspect-ratio: 1 / 1; 
        overflow: hidden;
        border-radius: 20px;
        background-color: #fff;
        margin-bottom: 12px;
    }

    .img-box img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.3s;
    }

    .info-box { padding: 5px 2px; text-align: left; }
    .category-label { color: #888; font-size: 13px; margin-bottom: 4px; display: block; }
    .product-name { font-size: 16px; font-weight: 700; margin: 5px 0; color: #222; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .price-box { font-size: 18px; font-weight: 800; color: #000; display: flex; align-items: baseline; gap: 2px; }
    .view-count { margin-top: 5px; font-size: 13px; color: #555; display: flex; align-items: center; gap: 4px; }

    .btn-group { display: flex; justify-content: center; gap: 15px; margin-top: 30px; margin-bottom: 60px; }    
    .btn-list { background-color: #fff; color: #00c4a7; border: 1px solid #00c4a7; padding: 12px 30px; 
    			border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; transition: all 0.2s ease; }
    .btn-list:hover {
        background-color: #00c4a7;
        color: #fff;
    }
</style>
</head>
<body>

<div class="product-container">
    <c:choose>
        <c:when test="${not empty list}">
            <c:forEach items="${list}" var="dto">
                <div class="product-card" onclick="location.href='/pdetail?p_no=${dto.p_no}'">
                    <div class="img-box"> 
                        <img src="/product/${dto.p_image}" alt="${dto.p_name}">
                    </div>
                    <div class="info-box">
                        <span class="category-label">[${dto.p_category}]</span>
                        <div class="product-name">${dto.p_name}</div>
                        <div class="price-box">
                            <fmt:formatNumber value="${dto.p_price}" pattern="#,###" /><span>원</span>
                        </div>
                        <div class="view-count">🔥 ${dto.p_view}</div>
                    </div>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <div style="width:100%; text-align:center; padding:100px 0; color:#999;">등록된 데이터가 없습니다.</div>
        </c:otherwise>
    </c:choose>     



    <%-- 버튼 그룹을 컨테이너 안으로 넣되, 아래 CSS를 적용하세요 --%>
<sec:authorize access="hasAuthority('ADMIN')">
    <div class="btn-group" style="flex-basis: 100%; display: flex; justify-content: center; gap: 15px; margin: 40px 0; clear: both;">
        <input type="button" value="새 상품 등록" class="btn-list" 
               onclick="location.href='/pinsertForm'" 
               style="background-color: #fff; color: #00c4a7; border: 1px solid #00c4a7; padding: 12px 30px; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer;">
        
        <input type="button" value="관리자홈" class="btn-list" 
               onclick="location.href='${pageContext.request.contextPath}/adminhome'"
               style="background-color: #fff; color: #00c4a7; border: 1px solid #00c4a7; padding: 12px 30px; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer;">
    </div>
</sec:authorize>
</div> 
</body>
</html>