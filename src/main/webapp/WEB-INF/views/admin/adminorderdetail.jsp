<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>


<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>관리자 주문 상세 관리</title>
    <meta name="_csrf" content="${_csrf.token}"/>
    <meta name="_csrf_header" content="${_csrf.headerName}"/>
   	<style>
	    body { background-color: #f1f5f9; font-family: 'Pretendard', sans-serif; color: #333; }
	    .container { 
		    max-width: 1100px;
	        margin: 60px auto; /* 상단 여백 확보 */
	        background: #fff;
	        padding: 40px;
	        border-radius: 15px;
	        box-shadow: 0 10px 30px rgba(0,0,0,0.05); }
	    h2 { font-weight: 700; margin-bottom: 30px; display: flex; justify-content: space-between; align-items: center; }
	    .logo-area a {
	        text-decoration: none;
	        color: #00b894;
	        font-weight: 800;
	        font-size: 20px;
	        letter-spacing: -1px;
	    }
        .info-card { background: white; border-radius: 12px; padding: 24px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 30px; }
	    .info-card h4 { margin-top: 0; color: #333; border-bottom: 2px solid #f1f1f1; padding-bottom: 15px; margin-bottom: 20px; font-size: 1.1em; }
	    .info-grid { display: grid; grid-template-columns: 120px 1fr; gap: 12px; font-size: 15px; }
	    .label { color: #888; font-weight: 500; }
	    .product-card { background: white; border-radius: 12px; display: flex; align-items: center; padding: 20px; margin-bottom: 16px; box-shadow: 0 2px 4px rgba(0,0,0,0.03); }
	    .product-img { width: 90px; height: 90px; border-radius: 8px; object-fit: cover; margin-right: 20px; border: 1px solid #eee; }
	    .product-info { flex: 1; }
	    .product-name { font-size: 17px; font-weight: 700; margin-bottom: 6px; }
	    .product-status { display: inline-block; padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: 700; margin-bottom: 8px; }
	    .status-blue { background: #e7f3ff; color: #007bff; }    
	    .status-red { background: #ffebee; color: #e53e3e; }     
        .status-orange { background: #fff3e0; color: #ef6c00; }
        .status-green { background: #e8f5e9; color: #2e7d32; }
	    .total-section { text-align: right; padding: 30px; background: white; border-radius: 12px; margin-top: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
         /* 하단 목록 버튼 스타일 */
		.btn-list {
			background-color: #fff;
		    color: #00b894;
		    border: 1px solid #00b894;
		    padding: 12px 30px;
		    border-radius: 8px;
		    font-size: 14px;
		    font-weight: 600;
		    cursor: pointer;
		    transition: all 0.2s ease;
		}
		.btn-list:hover {
	        background-color: #00b894;
	        color: #fff;
	    }
        .btn-approve { background: #2e7d32; color: white; padding: 10px 20px; border: none; border-radius: 8px; cursor: pointer; font-weight: 600; margin-top: 10px; }
        .exchange-box { background: #fffcf9; border: 1px dashed #ef6c00; padding: 20px; border-radius: 8px; margin-top: 15px; text-align: left; }
        .exchange-img { width: 150px; border-radius: 6px; cursor: pointer; margin-top: 10px; border: 1px solid #ddd; }
        .status-label { display: block; margin-top: 20px; font-weight: 700; font-size: 16px; }
	</style>
</head>
<body>
<%@ include file="/WEB-INF/views/header.jsp" %>

    <%-- 쿼리 결과(Map)의 키값(pd_state 등)을 변수에 할당 --%>
    <c:set var="oNo" value="${order.om_no}" />
	<c:set var="oType" value="${order.om_type}" />
	<c:set var="oTotal" value="${order.om_total}" />
    <c:set var="curStatus" value="${order.pd_state}" />

	 <div class="container">
	 <div class="logo-area">
    	<a href="/adminhome">PRICEO ADMIN</a>
     </div>
	    <h2>
            ${oType eq 'STAY' ? '예약 상세 내역' : '주문 상세 내역'}
        </h2>
	
	    <div class="info-card">
	        <h4>${oType eq 'STAY' ? '예약자 및 이용 정보' : '주문 및 배송지 정보'}</h4>
	        <div class="info-grid">
	            <div class="label">결제자</div>
                <div>${order.m_name}</div>
                
                <div class="label">${oType eq 'STAY' ? '예약자' : '수령인'}</div>
                <div>${order.receiver_name}</div>
                
                <div class="label">연락처</div>
                <div>${order.om_tel}</div>
	            
	            <c:choose>
                    <c:when test="${oType eq 'STAY'}">
                        <div class="label">이용일정</div>
                        <div style="font-weight: bold; color: #007bff;">
                            ${fn:substring(order.sd_checkin, 0, 10)} ~ ${fn:substring(order.sd_checkout, 0, 10)}
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="label">배송지</div>
                        <div>${order.om_addr} ${order.om_detail_addr}</div>
                    </c:otherwise>
                </c:choose>
	            
	            <div class="label">결제일</div>
				<div>${fn:substring(order.om_date, 0, 10)}</div>
	        </div>
	    </div>
	
	    <h4 style="margin-bottom: 15px; font-size: 1.1em; color: #888;">상세 품목</h4>

		<c:forEach var="item" items="${items}">
		    <div class="product-card">
                <img src="/${oType eq 'STAY' ? 'stay' : 'product'}/${item.p_image}" class="product-img" onerror="this.src='/img/no-image.png';">
		        
                <div class="product-info">
				    <c:choose>
				        <c:when test="${item.pd_state eq '결제취소' or item.pd_state eq '취소완료'}">
				            <div class="product-status status-red">취소완료</div>
				        </c:when>
				        <c:when test="${item.pd_state eq '교환신청' or item.pd_state eq '교환완료'}">
				            <div class="product-status status-orange">${item.pd_state}</div>
				        </c:when>
				        <c:when test="${item.pd_state eq '배송완료' or item.pd_state eq '배송중'}">
				            <div class="product-status status-green">${item.pd_state}</div>
				        </c:when>
				        <c:otherwise>
				            <div class="product-status status-blue">${oType eq 'STAY' ? '예약완료' : '결제완료'}</div>
				        </c:otherwise>
				    </c:choose>
		            
		            <div class="product-name">${item.p_name}</div>
		            <div class="product-price">
		                 <c:choose>
                             <c:when test="${oType eq 'STAY'}">숙소 예약 건</c:when>
                             <c:otherwise>
                                 <fmt:formatNumber value="${item.p_price}" pattern="#,###" />원 · ${item.pd_count}개
                             </c:otherwise>
                         </c:choose>
		            </div>
		        </div>
		        <div style="text-align: right; font-weight: 800; font-size: 18px; color: #333;">
                    <c:choose>
                        <c:when test="${oType eq 'STAY'}"><fmt:formatNumber value="${oTotal}" pattern="#,###" />원</c:when>
                        <c:otherwise><fmt:formatNumber value="${item.p_price * item.pd_count}" pattern="#,###" />원</c:otherwise>
                    </c:choose>
		        </div>
		    </div>
		</c:forEach>
	
        <div class="total-section">
		    <span style="font-size: 15px; color: #888; font-weight: 500;">최종 결제 금액</span>
		    <div style="font-size: 28px; font-weight: 900; color: #e53e3e; margin: 8px 0;">
		        <fmt:formatNumber value="${oTotal}" pattern="#,###" />원
		    </div>
		
            <%-- 하단 통합 안내 문구 (무한 굴레 탈출 로직) --%>
		    <c:choose>
		        <c:when test="${curStatus eq '결제취소' or curStatus eq '취소완료'}">
		            <span class="status-label" style="color: #e53e3e;">해당 내역은 [취소완료] 처리되었습니다.</span>
		        </c:when>
                
                <c:when test="${curStatus eq '배송중' or curStatus eq '배송완료'}">
                    <span class="status-label" style="color: #2e7d32;">현재 [${curStatus}] 상태입니다.</span>
                </c:when>

                <c:when test="${curStatus eq '교환신청' or curStatus eq '교환완료'}">
                    <span class="status-label" style="color: #ef6c00;">현재 [${curStatus}] 상태입니다.</span>
                </c:when>
		
		        <c:otherwise>
                    <span class="status-label" style="color: #007bff;">
                        [${oType eq 'STAY' ? '예약완료' : '결제완료'}] ${oType eq 'STAY' ? '예약이 확정되었습니다.' : '상품 준비가 시작되었습니다.'}
                    </span>
		        </c:otherwise>
		    </c:choose>

            <%-- 교환 사유 정보 (관리자 전용) --%>
		    <c:if test="${not empty order.e_reason}">
                <div class="exchange-box">
                    <h5 style="margin: 0 0 10px 0; color: #ef6c00;">🔄 교환/반품 요청 정보</h5>
                    <div style="font-size: 14px; text-align: left;">
                        <strong>사유:</strong> ${order.e_reason}<br>
                        <c:if test="${not empty order.e_image}">
                            <img src="/exchange/${order.e_image}" class="exchange-img" onclick="window.open(this.src)">
                        </c:if>
                    </div>
                    <%-- 교환 신청 상태일 때만 승인 버튼 노출 --%>
                    <c:if test="${curStatus eq '교환신청'}">
                        <button type="button" class="btn-approve" onclick="processExchange(${oNo}, '교환완료')">교환 승인 완료 처리</button>
                    </c:if>
                </div>
		    </c:if>
		    
		    <div style="margin-top: 20px;">
		        <input type="button" value="목록으로 돌아가기" class="btn-list" onclick="location.href='${pageContext.request.contextPath}/adminorderlist'">
		        <input type="button" value="관리자홈" class="btn-list" onclick="location.href='${pageContext.request.contextPath}/adminhome'">
		    </div>
		    
		</div>
    </div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    function processExchange(omNo, status) {
        if(!confirm("해당 건을 '교환완료' 상태로 변경하시겠습니까?")) return;
        $.ajax({
            url: "/updateStatus",
            type: "POST",
            data: { om_no: omNo, pd_state: status },
            success: function(res) {
                if(res.trim() === "success") { 
                    alert("처리가 완료되었습니다."); 
                    location.reload(); 
                } else { 
                    alert("처리 실패: " + res); 
                }
            }
        });
    }
</script>
</body>
</html>