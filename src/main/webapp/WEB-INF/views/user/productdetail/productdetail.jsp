<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>주문/예약 상세 보기</title>
      <style>
       body { background-color: #f8f9fa; font-family: 'Pretendard', sans-serif; color: #333; }
       .container { max-width: 800px; margin: 40px auto; padding: 0 20px; }
       h2 { font-weight: 700; margin-bottom: 30px; }
       .info-card { background: white; border-radius: 12px; padding: 24px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 30px; }
       .info-card h4 { margin-top: 0; color: #333; border-bottom: 2px solid #f1f1f1; padding-bottom: 15px; margin-bottom: 20px; font-size: 1.1em; }
       .info-grid {
          display: grid;
          grid-template-columns: 140px 1fr; /* 라벨 너비를 조금 더 여유있게 고정 */
          gap: 16px 0;                    /* 세로 간격을 넓혀서 더 시원하게 */
          font-size: 15px;
          align-items: center;            /* 세로 중앙 맞춤 */
      }
       .label {
          color: #888;
          font-weight: 600;               /* 폰트 두께 살짝 추가 */
          position: relative;
          padding-left: 10px;
      }
      /* 라벨 앞에 작은 점 포인트를 주면 훨씬 정돈되어 보입니다 */
      .label::before {
          content: '';
          position: absolute;
          left: 0;
          top: 50%;
          transform: translateY(-50%);
          width: 3px;
          height: 3px;
          background-color: #ccc;
          border-radius: 50%;
      }
       .product-card { background: white; border-radius: 12px; display: flex; align-items: center; padding: 20px; margin-bottom: 16px; box-shadow: 0 2px 4px rgba(0,0,0,0.03); }
       .product-img { width: 90px; height: 90px; border-radius: 8px; object-fit: cover; margin-right: 20px; border: 1px solid #eee; }
       .product-info { flex: 1; }
       .product-name { font-size: 17px; font-weight: 700; margin-bottom: 6px; }
       .product-status { display: inline-block; padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: 700; margin-bottom: 8px; }
       .status-blue { background: #e7f3ff; color: #007bff; }    
       .status-red { background: #ffebee; color: #e53e3e; }     
       .total-section { text-align: right; padding: 30px; background: white; border-radius: 12px; margin-top: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
       .btn-list {  background-color: #1e3a8a !important; /* 사용자님이 원하시는 색상 */
       color: #fff !important;
       border: none;
       cursor: pointer;
       transition: 0.3s;}
       .btn-cancel { background: #fff; color: #e53e3e; border: 1px solid #e53e3e; padding: 12px 24px; border-radius: 8px; cursor: pointer; font-weight: 600; margin-top: 20px; margin-right: 8px; }
      .btn-exchange { background: #fff; color: #007bff; border: 1px solid #007bff; padding: 12px 24px; border-radius: 8px; cursor: pointer; font-weight: 600; margin-top: 20px; margin-right: 8px; }
        .status-label { display: block; margin-top: 20px; font-weight: 700; font-size: 15px; }
   </style>
   <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
<%@ include file="/WEB-INF/views/header.jsp" %>

    <div class="container">
       <h2>${master.OM_TYPE eq 'STAY' ? '예약 상세 내역' : '주문 상세 내역'}</h2>
   
       <div class="info-card">
           <h4>${master.OM_TYPE eq 'STAY' ? '예약자 정보' : '배송지 정보'}</h4>
           <div class="info-grid">
               <div class="label">${master.OM_TYPE eq 'STAY' ? '예약자' : '수신인'}</div>
                <div>${master.OM_NAME != null ? master.OM_NAME : master.om_name}</div>
               
                <div class="label">연락처</div>
                <div>${master.OM_TEL != null ? master.OM_TEL : master.om_tel}</div>
               
               <c:if test="${master.OM_TYPE ne 'STAY'}">
                   <div class="label">주소</div>
                    <div>${master.OM_ADDR} ${master.OM_DETAIL_ADDR}</div>
               </c:if>
               
               <c:if test="${master.OM_TYPE eq 'STAY'}">
                   <div class="label">이용일정</div>
                   <div style="font-weight: bold; color: #007bff;">
                        ${fn:substring(master.SD_CHECKIN, 0, 10)} ~ ${fn:substring(master.SD_CHECKOUT, 0, 10)}
                    </div>
               </c:if>
               
               <div class="label">결제일</div>
                <div><fmt:formatDate value="${master.OM_DATE != null ? master.OM_DATE : master.om_date}" pattern="yyyy-MM-dd" /></div>
           </div>
       </div>
   
       <h4 style="margin-bottom: 15px; font-size: 1.1em;">
            ${master.OM_TYPE eq 'STAY' ? '예약 객실 정보' : '주문 상품 (' += details.size() += ')'}
        </h4>

      <c:forEach var="item" items="${details}">
          <div class="product-card">
                <c:choose>
                    <c:when test="${master.OM_TYPE eq 'STAY'}">
                        <img src="/stay/${item.P_IMAGE != null ? item.P_IMAGE : item.p_image}" class="product-img" 
                             onerror="this.onerror=null; this.src='/img/no-image.png';">
                    </c:when>
                    <c:otherwise>
                        <img src="/product/${item.P_IMAGE != null ? item.P_IMAGE : item.p_image}" class="product-img" 
                             onerror="this.onerror=null; this.src='/img/no-image.png';">
                    </c:otherwise>
                </c:choose>
              
                <div class="product-info">
                    <%-- 상태 값 추출 (OM_STATUS 대신 PD_STATE 사용) --%>
                <c:set var="status" value="${item.PD_STATE != null ? item.PD_STATE : item.pd_state}" />
                
                <c:choose>
                    <%-- 1. 취소 관련 상태 (빨간색) --%>
                    <c:when test="${status eq '결제취소' or status eq '취소완료'}">
                        <div class="product-status status-red">취소완료</div>
                    </c:when>
            
                    <%-- 2. 교환 관련 상태 (주황색) --%>
                    <c:when test="${status eq '교환신청' or status eq '교환완료'}">
                        <div class="product-status status-orange" style="background: #fff3e0; color: #ef6c00;">${status}</div>
                    </c:when>
                    
                    <%-- 3. 배송 관련 (초록색) --%>
                    <c:when test="${status eq '배송완료' or status eq '배송중'}">
                        <div class="product-status status-green" style="background: #e8f5e9; color: #2e7d32;">${status}</div>
                    </c:when>
                    
                    <%-- 4. 그 외 (파란색) --%>
                    <c:otherwise>
                        <div class="product-status status-blue">
                            ${master.OM_TYPE eq 'STAY' ? '예약완료' : (status != null ? status : '결제완료')}
                        </div>
                    </c:otherwise>
                </c:choose>
                  
                  <div class="product-name">
                        ${master.OM_TYPE eq 'STAY' ? (master.SR_NAME != null ? master.SR_NAME : master.sr_name) : (item.P_NAME != null ? item.P_NAME : item.p_name)}
                    </div>
                  <div class="product-price">
                       <c:choose>
                             <c:when test="${master.OM_TYPE eq 'STAY'}">1박 기준 예약 건</c:when>
                             <c:otherwise>
                                 <fmt:formatNumber value="${item.P_PRICE != null ? item.P_PRICE : item.p_price}" pattern="#,###" />원 · 
                                 ${item.PD_COUNT != null ? item.PD_COUNT : item.pd_count}개
                             </c:otherwise>
                         </c:choose>
                  </div>
              </div>
              <div style="text-align: right; font-weight: 800; font-size: 18px; color: #333;">
                    <c:choose>
                        <c:when test="${master.OM_TYPE eq 'STAY'}">
                            <fmt:formatNumber value="${master.OM_TOTAL != null ? master.OM_TOTAL : master.om_total}" pattern="#,###" />원
                        </c:when>
                        <c:otherwise>
                            <fmt:formatNumber value="${(item.P_PRICE != null ? item.P_PRICE : item.p_price) * (item.PD_COUNT != null ? item.PD_COUNT : item.pd_count)}" pattern="#,###" />원
                        </c:otherwise>
                    </c:choose>
              </div>
          </div>
      </c:forEach>
   
        <div class="total-section">
          <span style="font-size: 15px; color: #888; font-weight: 500;">최종 결제 금액</span>
          <div style="font-size: 28px; font-weight: 900; color: #e53e3e; margin: 8px 0;">
              <fmt:formatNumber value="${master.OM_TOTAL != null ? master.OM_TOTAL : master.om_total}" pattern="#,###" />원
          </div>
      
          <%-- 통합 상태 판단 (첫 번째 아이템의 PD_STATE 기준) --%>
          <c:set var="dStatus" value="${details[0].PD_STATE != null ? details[0].PD_STATE : details[0].pd_state}" />
          <c:set var="isCancelled" value="${dStatus eq '결제취소' or dStatus eq '취소완료'}" />
      
          <c:choose>
              <%-- 1. 취소된 상태일 때 --%>
              <c:when test="${isCancelled}">
                  <span class="status-label" style="color: #e53e3e; font-weight: 800;">
                      해당 내역은 [취소완료] 처리되었습니다.
                  </span>
              </c:when>
      
              <%-- 2. 정상 결제/예약완료 상태일 때 --%>
            <c:when test="${dStatus eq '결제완료' or dStatus eq '예약완료' or empty dStatus}">
                <div style="margin-bottom: 15px;">
                    <span class="status-label" style="color: #007bff; font-weight: 800;">
                        [${master.OM_TYPE eq 'STAY' ? '예약완료' : '결제완료'}] 
                        ${master.OM_TYPE eq 'STAY' ? '예약이 확정되었습니다.' : '상품 준비가 시작되었습니다.'}
                    </span>
                </div>
                <button type="button" class="btn-cancel" onclick="cancelPay('${master.OM_PAYNO != null ? master.OM_PAYNO : master.om_payno}', ${master.OM_NO != null ? master.OM_NO : master.om_no})">
                    ${master.OM_TYPE eq 'STAY' ? '예약 취소' : '결제 취소'}
                </button>
                <%-- [수정] 여기 있던 교환 버튼 삭제 (아직 배송 전이므로) --%>
            </c:when>
            
            <%-- 3. 기타 상태 (배송중, 배송완료, 교환신청 등) --%>
            <c:otherwise>
                <c:set var="textColor" value="#007bff" />
                <c:if test="${dStatus eq '배송완료' or dStatus eq '배송중'}"><c:set var="textColor" value="#2e7d32" /></c:if>
                <c:if test="${dStatus eq '교환신청' or dStatus eq '교환완료'}"><c:set var="textColor" value="#ef6c00" /></c:if>
                
                <span class="status-label" style="color: ${textColor};">현재 [${dStatus}] 상태입니다.</span>
                
                <%-- [추가] 배송완료 상태일 때만 교환 버튼 노출 --%>
                <c:if test="${dStatus eq '배송완료' and master.OM_TYPE ne 'STAY'}">
                    <div style="margin-top: 10px;">
                        <button type="button" class="btn-exchange" onclick="requestExchange(${master.OM_NO != null ? master.OM_NO : master.om_no})">상품 교환 신청</button>
                    </div>
                </c:if>
            </c:otherwise>
          </c:choose>
          
          <div style="margin-top: 20px;">
              <button class="btn-list" style="padding: 12px 30px; border-radius: 8px; font-weight: bold; margin-top: 10px;"
              onclick="location.href='/orderlist?m_no=${master.m_no != null ? master.m_no : master.M_NO}'">목록으로 돌아가기</button>
          </div>
      </div>
   </div>
<%@ include file="/WEB-INF/views/user/member/mfaqChat.jsp" %>
<%@ include file="/WEB-INF/views/footer.jsp" %>
   <script>
   function cancelPay(om_payno, om_no) {
       const msg = "${master.OM_TYPE eq 'STAY' ? '예약을 취소하시겠습니까? 취소 시 해당 날짜의 예약이 다시 열립니다.' : '정말 결제를 취소하시겠습니까?'}";
       if(!confirm(msg)) return;
       $.ajax({
           url: "/orderCancel",
           type: "POST",
           data: { om_payno: om_payno, om_no: om_no },
           success: function(res) {
               if(res.trim() === "success") {
                   alert("취소 처리가 정상적으로 완료되었습니다.");
                   location.reload();
               } else { alert("취소 실패: " + res); }
           },
            error: function() { alert("서버 통신 중 오류가 발생했습니다."); }
       });
   }
   function requestExchange(om_no) {
       if(!confirm("해당 주문에 대해 교환 신청을 하시겠습니까?")) return;
       location.href = "/orderExchangeForm?om_no=" + om_no;
   }
   </script>
</body>
</html>