<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>주문 내역 확인</title>
<style>
    body { background-color: #f8f9fa; font-family: 'Pretendard', sans-serif; }
    .history-container {
        max-width: 1000px;
        margin: 50px auto;
        padding: 40px;
        background: #fff;
        border-radius: 15px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.05);
    }
    .history-header {
        text-align: center;
        margin-bottom: 40px;
        padding-bottom: 20px;
        border-bottom: 2px solid #333;
    }
    .order-table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 30px;
    }
    .order-table th {
        background: #f8f9fa;
        padding: 18px 10px;
        border-bottom: 2px solid #dee2e6;
        font-weight: bold;
        font-size: 14px;
        color: #555;
    }
    .order-table td {
        padding: 18px 10px;
        border-bottom: 1px solid #f1f1f1;
        text-align: center;
        font-size: 15px;
    }

    /* 상태 배지 스타일 */
    .status-badge {
        display: inline-block;
        padding: 5px 14px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: bold;
    }
    .status-blue { background: #e7f3ff; color: #007bff; }    
    .status-orange { background: #fff3e0; color: #ef6c00; }  
    .status-red { background: #ffebee; color: #e53e3e; }     
    .status-green { background: #e8f5e9; color: #2e7d32; }   

    .btn-detail {
        background-color: #fff;
        color: #444;
        border: 1px solid #ddd;
        padding: 7px 16px;
        border-radius: 8px;
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s;
    }
    .btn-detail:hover {
        background-color: #f8f9fa;
        border-color: #bbb;
    }
    
    .btn-home {
        display: block;
        width: 220px;
        margin: 0 auto;
        padding: 15px;
        background: #1e3a8a;
        color: #fff;
        text-align: center;
        text-decoration: none;
        border-radius: 8px;
        font-weight: bold;
        transition: background 0.2s;
    }
    .btn-home:hover { background: #1e3a8a; }

    /* 숙소명 서브 텍스트 스타일 */
    .sub-info { font-size: 12px; color: #888; margin-top: 4px; }
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/header.jsp" %>
    <div class="history-container">
        <div class="history-header">
            <h2>나의 주문/예약 내역</h2>
            <p style="color: #777; margin-top: 10px;">고객님이 이용하신 소중한 내역입니다.</p>
        </div>

        <table class="order-table">
            <thead>
                <tr>
                    <th>주문번호</th>
                    <th>결제일자</th>
                    <th>상품/숙소 정보</th>
                    <th>총 결제금액</th>
                    <th>진행상태</th>
                    <th>조회</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="order" items="${olist}">
                	<c:set var="oType" value="${order.OM_TYPE != null ? order.OM_TYPE : order.om_type}" />
                    <tr>
                        <td><strong>#${order.OM_NO != null ? order.OM_NO : order.om_no}</strong></td>
                        <td>
						    <%-- 문자열을 10자리(yyyy-MM-dd)까지만 잘라서 출력 --%>
						    <c:set var="rawDate" value="${order.OM_DATE != null ? order.OM_DATE : order.om_date}" />
						    ${fn:substring(rawDate, 0, 10)}
						</td>
                        <td style="text-align: left; padding-left: 20px;">
                            <c:choose>
                                <c:when test="${oType eq 'STAY'}">
								    <span style="margin-right:5px;">🏨</span>
								    <strong>${order.SR_NAME != null ? order.SR_NAME : order.sr_name}</strong>
								    <c:set var="checkin" value="${order.SD_CHECKIN != null ? order.SD_CHECKIN : order.sd_checkin}" />
								    <%-- fn:substring을 사용하여 10자리(yyyy-MM-dd)까지만 정확히 자릅니다 --%>
								    <div class="sub-info">체크인: ${fn:substring(checkin, 0, 10)}</div>
								</c:when>
                                <c:otherwise>
                                    <span style="margin-right:5px;">📦</span>
                                    <strong>Priceo 상품 주문</strong>
                                    <div class="sub-info">수령인: ${order.OM_NAME != null ? order.OM_NAME : order.om_name}</div>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td style="color: #333; font-weight: bold;">
                            <fmt:formatNumber value="${order.OM_TOTAL != null ? order.OM_TOTAL : order.om_total}" pattern="#,###"/>원
                        </td>
                        <td>
						    <%-- 1. 변수 정리 (실제 데이터 필드인 PD_STATE만 사용) --%>
						    <c:set var="pState" value="${order.PD_STATE != null ? order.PD_STATE : order.pd_state}" />
						
						    <c:choose>
						        <%-- [1순위] 취소 상태 확인 (가장 중요) --%>
						        <c:when test="${pState eq '결제취소' or pState eq '취소완료'}">
						            <span class="status-badge status-red">취소완료</span>
						        </c:when>
						
						        <%-- [2순위] 교환 상태 확인 (주황색) --%>
						        <c:when test="${pState eq '교환신청' or pState eq '교환완료'}">
						            <span class="status-badge status-orange">${pState}</span>
						        </c:when>
						
						        <%-- [3순위] 배송 상태 확인 (초록색) --%>
						        <c:when test="${pState eq '배송완료' or pState eq '배송중'}">
						            <span class="status-badge status-green">${pState}</span>
						        </c:when>
						
						        <%-- [4순위] 숙소 예약이면서 정상인 경우 (파란색) --%>
						        <c:when test="${oType eq 'STAY'}">
						            <span class="status-badge status-blue">예약완료</span>
						        </c:when>
						
						        <%-- [기본] 일반 상품 결제완료 등 (파란색) --%>
						        <c:otherwise>
						            <span class="status-badge status-blue">${not empty pState ? pState : '결제완료'}</span>
						        </c:otherwise>
						    </c:choose>
						</td>
                        <td>
                            <button type="button" class="btn-detail" 
                                    onclick="location.href='/orderdetail?om_no=${order.OM_NO != null ? order.OM_NO : order.om_no}'">상세보기</button>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty olist}">
                    <tr>
                        <td colspan="6" style="padding: 100px 0; color: #999;">
                            최근 주문 및 예약 내역이 없습니다.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>

        <div style="margin-top: 40px;">
            <a href="/" class="btn-home">계속 쇼핑하기</a>
        </div>
    </div>
<%@ include file="/WEB-INF/views/user/member/mfaqChat.jsp" %>
<%@ include file="/WEB-INF/views/footer.jsp" %>
</body>
</html>