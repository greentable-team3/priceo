<%@ page language="java" contentType="text/html; charset=UTF-8" 
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>숙소목록</title>
<style>


    /* 전체 그리드 컨테이너 */
    .product-grid {
        display: flex;
        flex-wrap: wrap; 
        gap: 30px 20px; 
        max-width: 1200px;
        margin: 0 auto;
        padding: 40px 20px;
        justify-content: flex-start;
    }

    /* 숙소 카드 스타일 */
    .product-card {
        width: calc(33.333% - 14px); /* 한 줄에 3개 배치 (상품 목록 양식) */
        cursor: pointer;
        transition: transform 0.2s ease;
    }

    /* 모바일 대응 */
    @media (max-width: 900px) {
        .product-card { width: calc(50% - 10px); }
    }

    /* 이미지 박스: 둥근 모서리 강조 */
    .img-box {
        width: 100%; /* 너비를 꽉 채움 */
        aspect-ratio: 1 / 1; 
        overflow: hidden;
        border-radius: 20px; /* 이미지의 둥근 모서리 크게 적용 */
        background-color: #fff;
        margin-bottom: 12px;
    }

    .img-box img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.3s;
    }
	
	.product-card:hover .img-box img {
        transform: scale(1.05); /* 호버 시 이미지가 살짝 커짐 */
    }
	
    /* 텍스트 정보 영역 */
    .info-box {
        padding: 5px 2px;
        text-align: left;
    }

    /* 주소 라벨 */
    .address-label {
        color: #888;
        font-size: 13px;
        margin-bottom: 4px;
        display: block;
    }

    /* 숙소명 */
    .product-name {
        font-size: 16px;
        font-weight: 700;
        margin: 5px 0;
        color: #222;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    /* 가격 정보 */
    .price-box {
        font-size: 18px;
        font-weight: 800;
        color: #000;
        display: flex;
        align-items: baseline;
        gap: 2px;
    }
    
    .price-box span {
        font-size: 14px;
        font-weight: 500;
    }

    /* 조회수 */
    .view-count {
        margin-top: 5px;
        font-size: 13px;
        color: #555;
        display: flex;
        align-items: center;
        gap: 4px;
    }
    
    /* 하단 버튼 그룹 (민트색 양식) */
    .btn-group {
        display: flex;
        justify-content: center;
        gap: 15px;
        margin-top: 30px;
        margin-bottom: 60px;
    }    
	
    .btn-list {
        background-color: #fff;
        color: #00c4a7;
        border: 1px solid #00c4a7;
        padding: 12px 30px;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s ease;
    }
	
    .btn-list:hover {
        background-color: #00c4a7;
        color: #fff;
    }
</style>
</head>
<body>
	<div class="product-grid">
	    <c:choose>
	        <c:when test="${not empty list}">
	            <c:forEach items="${list}" var="dto">
	                <div class="product-card" onclick="location.href='${pageContext.request.contextPath}/stayDetail?s_no=${dto.s_no}'">
	                    
	                    <div class="img-box">
	                        <c:choose>
	                            <c:when test="${not empty dto.s_image}">
	                                <img src="${pageContext.request.contextPath}/stay/${dto.s_image}" alt="${dto.s_name}">
	                            </c:when>
	                            <c:otherwise>
	                                <div style="width:100%; height:100%; display:flex; align-items:center; justify-content:center; color:#ccc; font-size:12px; background:#f8f8f8;">No Image</div>
	                            </c:otherwise>
	                        </c:choose>
	                    </div>
	
	                    <div class="info-box">
	                        <span class="address-label">[${dto.s_addr}]</span>
	                        <div class="product-name">${dto.s_name}</div>
	                        <div class="price-box">
	                            <c:choose>
	                                <c:when test="${dto.min_price > 0}">
	                                    <fmt:formatNumber value="${dto.min_price}" pattern="#,###" /><span>원~</span>
	                                </c:when>
	                                <c:otherwise>
	                                    <span>가격 준비중</span>
	                                </c:otherwise>
	                            </c:choose>
	                        </div>
	                        <div class="view-count">🔥 ${dto.s_view}</div>
	                    </div>
	                </div>
	            </c:forEach>
	        </c:when>
	        <c:otherwise>
	            <div style="width:100%; text-align:center; padding:100px 0; color:#999;">등록된 숙소가 없습니다.</div>
	        </c:otherwise>
	    </c:choose>
	</div>
	<sec:authorize access="hasAuthority('ADMIN')">
    <div class="btn-group" style="flex-basis: 100%; display: flex; justify-content: center; gap: 15px; margin: 40px 0; clear: both;">
        <input type="button" value="새 숙소 등록" class="btn-list" 
               onclick="location.href='/stayInsertForm'" 
               style="background-color: #fff; color: #00c4a7; border: 1px solid #00c4a7; padding: 12px 30px; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer;">
        
        <input type="button" value="관리자홈" class="btn-list" 
               onclick="location.href='${pageContext.request.contextPath}/adminhome'"
               style="background-color: #fff; color: #00c4a7; border: 1px solid #00c4a7; padding: 12px 30px; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer;">
    </div>
	</sec:authorize>
</body>
</html>