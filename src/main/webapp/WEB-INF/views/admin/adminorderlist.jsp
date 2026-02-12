<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>


<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 주문 관리</title>
<style>
    body { background-color: #f1f5f9; font-family: 'Pretendard', sans-serif; }
    .admin-container { max-width: 1200px; margin: 40px auto; padding: 30px; background: #fff; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
    h2 { margin-bottom: 30px; color: #333; font-weight: 700; }
    .admin-table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
    .admin-table th { background: #f8f9fa; padding: 15px; border-bottom: 2px solid #dee2e6; font-size: 14px; }
    .admin-table td { padding: 15px; border-bottom: 1px solid #eee; text-align: center; font-size: 14px; vertical-align: middle; }
	
	.logo-area a {
        text-decoration: none;
        color: #00b894;
        font-weight: 800;
        font-size: 20px;
        letter-spacing: -1px;
    }

    /* 상태 배지 */
    .status-badge { display: inline-block; padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; }
    .status-blue { background: #e7f3ff; color: #007bff; }    
    .status-orange { background: #fff3e0; color: #ef6c00; }  
    .status-red { background: #ffebee; color: #e53e3e; }     
    .status-green { background: #e8f5e9; color: #2e7d32; }   

    /* 버튼 스타일 (기존 스타일 유지) */
    .btn-action { padding: 6px 12px; border-radius: 6px; border: 1px solid #ddd; cursor: pointer; font-size: 13px; font-weight: 600; transition: all 0.2s; margin: 2px; }
    .btn-delivery { background: #007bff; color: #fff; border-color: #007bff; }
    .btn-complete { background: #28a745; color: #fff; border-color: #28a745; }
    .btn-detail { background: #fff; color: #333; border: 1px solid #ccc; text-decoration: none; display: inline-block; }
    
    .sub-info { font-size: 12px; color: #888; margin-top: 4px; }
    
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
    
    /* 버튼 배치 정렬 */
	.btn-group {
	    display: flex;
	    justify-content: center;
	    gap: 15px;
	}
	
	
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/header.jsp" %>

    <div class="admin-container">
    <div class="logo-area">
    	<a href="/adminhome">PRICEO ADMIN</a>
    </div>
    <h2>📦 전체 주문/예약 관리 (관리자)</h2>
    <table class="admin-table">
        <thead>
            <tr>
                <th>주문번호</th>
                <th>주문일시</th>
                <th>주문자</th>
                <th>상품/숙소 정보</th>
                <th>결제금액</th>
                <th>주문상태</th>
                <th>관리액션</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="order" items="${orderList}">
                <%-- [핵심] 기존의 대문자 키 값과 소문자 키 값을 모두 허용하여 데이터 유실 방지 --%>
                <c:set var="oNo" value="${order.OM_NO != null ? order.OM_NO : order.om_no}" />
                <c:set var="oType" value="${order.OM_TYPE != null ? order.OM_TYPE : order.om_type}" />
                <c:set var="pState" value="${order.PD_STATE != null ? order.PD_STATE : order.pd_state}" />
                
                <tr>
                    <td><strong>#${oNo}</strong></td>
                    <td>${order.OM_DATE != null ? order.OM_DATE : order.om_date}</td>
                    <td>${order.M_NAME != null ? order.M_NAME : order.m_name}</td>
                    
                    <td style="text-align: left; padding-left: 15px;">
                        <c:choose>
                            <c:when test="${oType eq 'STAY'}">
                                🏨 <strong>${order.SR_NAME != null ? order.SR_NAME : order.sr_name}</strong>
                                <div class="sub-info">숙소 예약 건</div>
                            </c:when>
                            <c:otherwise>
                                📦 <strong>Priceo 일반 상품</strong>
                                <div class="sub-info">배송 상품</div>
                            </c:otherwise>
                        </c:choose>
                    </td>

                    <td style="font-weight: bold;">
                        <fmt:formatNumber value="${(order.OM_TOTAL != null ? order.OM_TOTAL : order.om_total) + 0}" pattern="#,###"/>원
                    </td>

                    <td>
                        <c:choose>
                            <c:when test="${pState eq '교환신청' or pState eq '취소신청' or pState eq '교환완료' or pState eq '결제취소' or pState eq '취소완료'}">
                                <span class="status-badge ${(pState eq '결제취소' or pState eq '취소완료') ? 'status-red' : 'status-orange'}">${pState}</span>
                            </c:when>
                            <c:when test="${pState eq '배송완료' or pState eq '배송중'}">
                                <span class="status-badge status-green">${pState}</span>
                            </c:when>
                            <c:otherwise>
                                <span class="status-badge status-blue">${not empty pState ? pState : (oType eq 'STAY' ? '예약완료' : '결제완료')}</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    
                    <td>
                        <%-- [기존 기능 완벽 유지] 상품 주문 건에 대한 배송 관리 버튼 --%>
                        <c:if test="${oType ne 'STAY'}">
                            <c:choose>
                                <%-- 상태가 '결제완료'이거나 비어있을 때 배송시작 버튼 노출 --%>
                                <c:when test="${pState eq '결제완료' or empty pState}">
                                    <button type="button" class="btn-action btn-delivery" onclick="changeStatus(${oNo}, '배송중')">배송시작</button>
                                </c:when>
                                <%-- 상태가 '배송중'일 때 배송완료 버튼 노출 --%>
                                <c:when test="${pState eq '배송중'}">
                                    <button type="button" class="btn-action btn-complete" onclick="changeStatus(${oNo}, '배송완료')">배송완료</button>
                                </c:when>
                            </c:choose>
                        </c:if>
                        
                        <%-- 상세보기 주소 유지 --%>
                        <a href="/adminorderdetail?om_no=${oNo}" class="btn-action btn-detail">상세보기</a>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
    <div class="btn-group" style="margin-top: 30px; text-align: center;">
        <input type="button" value="관리자홈" class="btn-list" onclick="location.href='${pageContext.request.contextPath}/adminhome'">
    </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        <%-- 기존에 사용하시던 스크립트 기능 그대로 유지 --%>
        function changeStatus(omNo, status) {
            if(confirm("상태를 '" + status + "'로 변경하시겠습니까?")) {
                $.ajax({
                    url: "/updateStatus", 
                    type: "POST",
                    data: { om_no: omNo, pd_state: status },
                    success: function(res) {
                        if(res.trim() === "success") {
                            alert("변경되었습니다.");
                            location.reload();
                        } else { alert("실패: " + res); }
                    },
                    error: function() { alert("통신 중 에러가 발생했습니다."); }
                });
            }
        }
    </script>   
</body>
</html>