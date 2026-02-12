<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>




<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>주문서 작성</title>
<style>
        /* 1. 기본 레이아웃 및 헤더 간섭 방지 */
        body {
            background-color: #f8f9fa;
            font-family: 'Pretendard', -apple-system, sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        /* 헤더 깨짐 강제 방지 */
        header { display: block !important; width: 100% !important; }

        .order-page-wrapper {
            flex: 1;
            display: flex;
            justify-content: center;
            padding: 60px 20px;
        }

        /* 2. 주문 정보 카드 박스 */
        .order-card {
            width: 100%;
            max-width: 800px;
            background: #fff;
            padding: 50px;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
            box-sizing: border-box;
        }

        .order-card h2 {
            font-size: 28px;
            font-weight: 800;
            color: #333;
            margin-top: 0;
            margin-bottom: 30px;
            border-bottom: 2px solid #f1f1f1;
            padding-bottom: 15px;
        }

        /* 가입자 정보 동일 체크박스 */
        .same-info-check {
            margin-bottom: 25px;
            font-size: 15px;
            color: #666;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        /* 3. 테이블 형태 입력 레이아웃 */
        .order-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
        }

        .order-table th {
            width: 150px;
            text-align: left;
            padding: 20px 15px;
            background-color: #fcfcfc;
            border-bottom: 1px solid #eee;
            font-size: 15px;
            color: #333;
        }

        .order-table td {
            padding: 15px;
            border-bottom: 1px solid #eee;
        }

        /* 입력 필드 공통 */
        input[type="text"], 
        input[type="tel"], 
        select {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 14px;
            box-sizing: border-box;
            outline: none;
            transition: border-color 0.2s;
        }

        input:focus, select:focus {
            border-color: #1e3a8a;
        }

        /* 주소 입력란 특수 레이아웃 */
        .address-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .address-row {
            display: flex;
            gap: 10px;
        }

        /* 4. 버튼 스타일 (네이비 #1e3a8a 고정) */
        .btn-navy {
            background-color: #1e3a8a !important;
            color: #fff !important;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: opacity 0.2s;
        }

        /* 주소 검색 버튼 */
        .btn-addr-search {
            padding: 0 20px;
            white-space: nowrap;
        }

        /* 하단 결제하기 큰 버튼 */
        .btn-payment {
            width: 100%;
            padding: 20px;
            font-size: 18px;
            margin-top: 40px;
        }

        button:hover {
            opacity: 0.9;
        }

        /* 5. 결제 금액 표시 */
        .total-price-area {
            text-align: right;
            margin-top: 30px;
            font-size: 18px;
            font-weight: 600;
        }

        .total-price-area span {
            color: #e63946;
            font-size: 24px;
            margin-left: 10px;
        }
    </style>
<script src="https://cdn.iamport.kr/v1/iamport.js"></script>
</head>

<style>
    /* 1. 기본 레이아웃 및 헤더 간섭 방지 */
    body {
        background-color: #f8f9fa;
        font-family: 'Pretendard', -apple-system, sans-serif;
        margin: 0;
        padding: 0;
        display: flex;
        flex-direction: column;
        min-height: 100vh;
    }

    /* 헤더 깨짐 방지 */
    header { display: block !important; width: 100% !important; }

    .order-page-wrapper {
        flex: 1;
        display: flex;
        justify-content: center;
        padding: 60px 20px;
        box-sizing: border-box;
    }

    /* 2. 주문 정보 카드 박스 */
    .order-card {
        width: 100%;
        max-width: 800px;
        background: #fff;
        padding: 40px;
        border-radius: 16px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
        box-sizing: border-box;
    }

    .order-card h2 {
        font-size: 26px;
        font-weight: 800;
        color: #333;
        margin-top: 0;
        margin-bottom: 20px;
        padding-bottom: 15px;
    }

    /* 가입자 정보 동일 체크박스 영역 */
    .same-info-wrapper {
        padding: 15px 0;
        margin-bottom: 10px;
        font-size: 15px;
        color: #666;
        display: flex;
        align-items: center;
        gap: 8px;
        border-bottom: 1px solid #f1f1f1;
    }

    /* 3. 테이블 형태 입력 레이아웃 */
    .table-form {
        width: 100%;
        border-collapse: collapse;
        margin-top: 10px;
    }

    .table-form th {
        width: 140px;
        text-align: left;
        padding: 20px 10px;
        background-color: #fcfcfc;
        border-bottom: 1px solid #eee;
        font-size: 15px;
        color: #333;
    }

    .table-form td {
        padding: 15px 10px;
        border-bottom: 1px solid #eee;
    }

    /* 입력 필드 공통 */
    .table-form input[type="text"], 
    .table-form select {
        width: 100%;
        padding: 12px 15px;
        border: 1px solid #ddd;
        border-radius: 8px;
        font-size: 14px;
        box-sizing: border-box;
        outline: none;
        transition: border-color 0.2s;
    }

    .table-form input:focus, .table-form select:focus {
        border-color: #1e3a8a;
    }

    /* 주소 검색 버튼 (네이비 고정) */
    .btn-navy-sm {
        width: 100px;
        padding: 12px;
        background-color: #1e3a8a !important;
        color: #fff !important;
        border: none;
        border-radius: 8px;
        font-weight: 600;
        cursor: pointer;
        white-space: nowrap;
        font-size: 14px;
    }

    /* 하단 결제하기 큰 버튼 (네이비 고정) */
    .pay-btn {
        width: 100%;
        padding: 18px;
        background-color: #1e3a8a !important;
        color: #fff !important;
        border: none;
        border-radius: 8px;
        font-size: 18px;
        font-weight: 700;
        cursor: pointer;
        margin-top: 40px;
        transition: opacity 0.2s;
    }

    .pay-btn:hover, .btn-navy-sm:hover {
        opacity: 0.9;
    }

    /* 결제 금액 섹션 */
    .total-price-section h3 {
        margin: 0;
        font-size: 20px;
        color: #333;
    }

    .total-price-section span {
        color: #e63946 !important; /* 금액은 빨간색 유지 */
        font-size: 26px;
        font-weight: 800;
        margin-left: 5px;
    }
</style>

<body>
<%@ include file="/WEB-INF/views/header.jsp" %>

<div class="order-page-wrapper">
    <div class="order-card">
        <h2>${om_type == 'STAY' ? '숙소 예약 정보 입력' : '주문 정보 입력'}</h2>
        
        <div class="same-info-wrapper">
		    <input type="checkbox" id="same_as_user" onclick="copyUserInfo()"> 
		    <label for="same_as_user">가입자 정보와 동일</label>
		</div>

        <form action="/orderProcess" method="post" id="orderForm">
            <input type="hidden" name="m_no" value="${not empty loginMember ? loginMember.m_no : m_no}">
            <input type="hidden" name="om_total" value="${totalSum}">
            <input type="hidden" name="om_payno" id="om_payno" value="">
            <input type="hidden" name="om_type" value="${om_type == null ? 'product' : 'STAY'}">

            <c:choose>
                <%-- [1. 숙소 예약 전용 로직] --%>
                <c:when test="${om_type == 'STAY'}">
                    <input type="hidden" name="sr_no" value="${room.sr_no}">
                    <input type="hidden" name="sd_checkin" value="${checkIn}">
                    <input type="hidden" name="sd_checkout" value="${checkOut}">
                    <input type="hidden" name="sd_name" id="sd_name">
                    <input type="hidden" name="om_addr" value="">
                    <input type="hidden" name="om_request" value="">

                    <table class="table-form">
                        <tr>
                            <th>예약자명</th>
                            <td><input type="text" name="om_name" id="om_name" required placeholder="예약자 성함"></td>
                        </tr>
                        <tr>
                            <th>연락처</th>
                            <td><input type="text" name="om_tel" id="om_tel" required placeholder="010-0000-0000" oninput="autoHyphen(this)"
                            maxlength="13"></td>
                        </tr>
                        <tr>
                            <th>예약 객실</th>
                            <td><strong>${room.sr_name}</strong> (1박 2일)</td>
                        </tr>
                        <tr>
                            <th>이용 기간</th>
                            <td>${checkIn} (입실) ~ ${checkOut} (퇴실)</td>
                        </tr>
                    </table>
                </c:when>

                <%-- [2. 기존 상품 주문 로직 유지] --%>
                <c:otherwise>
                    <table class="table-form">
                        <tr>
                            <th>수신인</th>
                            <td><input type="text" name="om_name" id="om_name" required placeholder="받으실 분 성함"></td>
                        </tr>
                        <tr>
                            <th>연락처</th>
                            <td><input type="text" name="om_tel" id="om_tel" required placeholder="010-0000-0000" oninput="autoHyphen(this)"
                            maxlength="13" ></td>
                        </tr>
                        <tr>
                            <th>배송지</th>
                            <td>
                                <div style="display: flex; align-items: center; gap: 8px; width: 100%;">
                                    <input type="text" name="om_addr" id="om_addr" placeholder="배송 주소를 입력하세요" readonly>
                                    <button type="button" onclick="execDaumPostcode()" class="btn-navy-sm">
                                        주소 검색
                                    </button>
                                </div>
                                <div style="margin-top: 8px; width: 100%;">
                                    <input type="text" name="om_detail_addr" id="om_detail_addr" placeholder="상세 주소를 입력하세요">
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th>요청사항</th>
                            <td>
                                <select id="requestSelect" name="om_request">
                                    <option value="해당없음">-- 요청사항 선택 --</option>
                                    <option value="배송 전 연락바랍니다.">배송 전 연락바랍니다.</option>
                                    <option value="부재 시 경비실에 맡겨주세요.">부재 시 경비실에 맡겨주세요.</option>
                                    <option value="부재 시 문 앞에 놓아주세요.">부재 시 문 앞에 놓아주세요.</option>
                                    <option value="택배함에 넣어주세요.">택배함에 넣어주세요.</option>
                                </select>
                            </td>
                        </tr>
                    </table>
                </c:otherwise>
            </c:choose>

            <div class="total-price-section" style="margin-top: 30px; text-align: right;">
                <h3>최종 결제 금액: <span><fmt:formatNumber value="${totalSum}" pattern="#,###" />원</span></h3>
            </div>

            <button type="submit" class="pay-btn" onclick="requestPay(event)">결제하기</button>
        </form>
    </div>
</div>

	<%@ include file="/WEB-INF/views/user/member/mfaqChat.jsp" %>
	<%@ include file="/WEB-INF/views/footer.jsp" %>
	<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<script>
    var IMP = window.IMP; 
    if (IMP) { IMP.init("imp86172254"); }

    const user_Name = "${loginMember.m_name}" || "";
    const user_Tel = "${loginMember.m_tel}" || "";
    const user_FullAddr = "${loginMember.m_addr}" || ""; 

    function copyUserInfo() {
        const isChecked = document.getElementById('same_as_user').checked;
        
        // 대상 필드 가져오기
        const nameField = document.getElementById('om_name');
        const telField = document.getElementById('om_tel');
        const addrField = document.getElementById('om_addr');
        const detailField = document.getElementById('om_detail_addr');

        if (isChecked) {
            // [1] 이름과 연락처 입력 (숙소/상품 공통)
            if (nameField) nameField.value = user_Name;
            if (telField) telField.value = user_Tel;

            // [2] 주소 처리 (상품 주문일 때만 실행)
            // addrField가 화면에 존재할 때만 로직을 수행하도록 체크합니다.
            if (addrField && user_FullAddr && user_FullAddr.trim() !== "") {
                const addrParts = user_FullAddr.trim().split(" ");
                
                if (addrParts.length > 1) {
                    addrParts.pop(); // 마지막 단어("5층") 제거
                    addrField.value = addrParts.join(" ");
                } else {
                    addrField.value = user_FullAddr;
                }
                
                // 상세주소 필드가 있으면 비워줌
                if (detailField) detailField.value = ""; 
            }
        } else {
            // [3] 체크 해제 시 모두 초기화
            if (nameField) nameField.value = "";
            if (telField) telField.value = "";
            if (addrField) addrField.value = "";
            if (detailField) detailField.value = "";
        }
    }

    
    function execDaumPostcode() {
        new daum.Postcode({
            oncomplete: function(data) {
                var addr = (data.userSelectedType === 'R') ? data.roadAddress : data.jibunAddress;
                document.getElementById("om_addr").value = addr;
                document.getElementById("om_detail_addr").focus();
            }
        }).open();
    }

    function requestPay(event) {
        event.preventDefault();

        const name = document.getElementById('om_name').value;
        const tel = document.getElementById('om_tel').value;
        const omType = "${om_type}";

        // 숙소일 때는 주소 체크를 건너뜀
        if(omType !== 'STAY') {
            const addr = document.getElementById('om_addr').value;
            if(!name || !tel || !addr) {
                alert("정보를 모두 입력해주세요.");
                return;
            }
        } else {
            if(!name || !tel) {
                alert("예약자 정보를 입력해주세요.");
                return;
            }
            // 숙소 상세용 이름 복사
            document.getElementById('sd_name').value = name;
        }

        const newOrderNo = "ORD_" + new Date().getTime();

        IMP.request_pay({
            pg: "nice.iamport02m", 
            pay_method: "card",
            merchant_uid: newOrderNo,
            name: omType === 'STAY' ? "${room.sr_name} 예약" : "Priceo 상품 결제",
            amount: parseInt("${totalSum}"), 
            buyer_name: name,
            buyer_tel: tel
        }, function (rsp) {
            if (rsp.success) {
                document.getElementById("om_payno").value = rsp.merchant_uid;
                document.getElementById("orderForm").submit();
            } else {
                alert("결제 실패: " + rsp.error_msg);
            }
        }); 
    }
    
    
 	// 연락처 자동 하이픈 함수
    function autoHyphen(target) {
        target.value = target.value
            .replace(/[^0-9]/g, '') // 숫자가 아닌 문자 제거
            .replace(/^(\d{2,3})(\d{3,4})(\d{4})$/, `$1-$2-$3`) // 패턴 맞추기
            .replace(/--/g, '-'); // 연속된 하이픈 방지
    }
</script>
</body>
</html>