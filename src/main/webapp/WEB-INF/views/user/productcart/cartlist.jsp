<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>장바구니 목록</title>
<style>
	body { background-color: #f8f9fa; font-family: 'Pretendard', sans-serif; }
    .cart-container {
        max-width: 1000px;
        margin: 50px auto;
        padding: 20px;
        background: #fff;
        border-radius: 15px;
        box-shadow: 0 5px 20px rgba(0,0,0,0.05);
    }
    .cart-header {
        text-align: center;
        margin-bottom: 30px;
        border-bottom: 2px solid #333;
        padding-bottom: 15px;
    }
    .cart-table {
        width: 100%;
        border-collapse: collapse;
    }
    .cart-table th {
        background: #f8f9fa;
        padding: 15px;
        border-bottom: 1px solid #ddd;
    }
    .cart-table td {
        padding: 15px;
        border-bottom: 1px solid #eee;
        text-align: center;
        vertical-align: middle;
    }
    .product-img {
        width: 80px;
        height: 80px;
        object-fit: cover;
        border-radius: 5px;
    }
    .total-section {
        margin-top: 30px;
        padding: 25px;
        background: #fcfcfc;
        border-radius: 10px;
        text-align: right;
        border: 1px solid #eee;
    }
    .btn-delete {
        padding: 5px 10px;
        background: #fff;
        border: 1px solid #ff4d4d;
        color: #ff4d4d;
        border-radius: 3px;
        cursor: pointer;
    }
    .btn-delete:hover { background: #ff4d4d; color: #fff; }
    .btn-order {
        width: 200px;
        height: 50px;
        background: #1e3a8a;
        color: #fff;
        border: none;
        border-radius: 5px;
        font-size: 18px;
        font-weight: bold;
        cursor: pointer;
        margin-top: 20px;
    }
    .qty-btn {
        width: 25px;
        height: 25px;
        border: 1px solid #ddd;
        background: #fff;
        cursor: pointer;
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
</style>
<script>
    function deleteCart(pc_no) {
        if(confirm("해당 상품을 장바구니에서 삭제하시겠습니까?")) {
            location.href = "/cartdelete?pc_no=" + pc_no;
        }
    }
    
    function updateQty(pc_no, gap, currentQty) {
        let newQty = parseInt(currentQty) + gap;
        
        if(newQty < 1) {
            alert("최소 수량은 1개입니다.");
            return;
        }
        if(newQty > 5) {
            alert("최대 5개까지만 구매 가능합니다.");
            return;
        }
        location.href = "/cartupdate?pc_no=" + pc_no + "&pc_count=" + newQty;
    }
    
    function goOrderForm() {
        // 1. 화면에 출력된 '총 주문 금액' 숫자를 읽어옵니다. (콤마 제거)
        // 아래 2번 단계에서 추가할 ID를 사용합니다.
        const totalText = document.getElementById("finalTotalSum").innerText;
        const totalValue = parseInt(totalText.replace(/,/g, "")); 
        
        // 2. 0원인지 체크
        if (!totalValue || totalValue === 0) {
            alert("장바구니에 상품이 없습니다.");
            return;
        }

        if (confirm("주문을 진행하시겠습니까?")) {
            // 정의서 컬럼명 om_total에 맞춰 전송
            location.href = "/orderform?om_total=" + totalValue;
        }
    }
</script>
</head>
<body>
<%@ include file="/WEB-INF/views/header.jsp" %>
    <div class="cart-container">
        <div class="cart-header">
            <h2>장바구니 목록</h2>
        </div>

        <table class="cart-table">
            <thead>
                <tr>
                    <th>이미지</th>
                    <th>상품명</th>
                    <th>판매가</th>
                    <th>합계</th>
                    <th>수량수정</th>
                    <th>비고</th>
                </tr>
            </thead>
            <tbody>
                <c:set var="totalSum" value="0" />
                
                <c:forEach var="cart" items="${clist}">
                    <tr>
                        <td><img src="/product/${cart.p_image}" class="product-img"></td>
                        <td style="text-align: left; font-weight: bold;">${cart.p_name}</td>
                        <td><fmt:formatNumber value="${cart.p_price}" pattern="#,###" />원</td>
                        <td style="font-weight: bold; color: #e74c3c;">
                            <fmt:formatNumber value="${cart.p_price * cart.pc_count}" pattern="#,###" />원
                        </td>
                        <td>
                            <div style="display: flex; align-items: center; justify-content: center; gap: 8px;">
                                <button type="button" class="qty-btn" onclick="updateQty('${cart.pc_no}', -1, '${cart.pc_count}')">-</button>
                                <span style="min-width: 20px; font-weight: bold;">${cart.pc_count}</span>
                                <button type="button" class="qty-btn" onclick="updateQty('${cart.pc_no}', 1, '${cart.pc_count}')">+</button>
                            </div>
                        </td>
                        <td>
                            <button type="button" class="btn-delete" onclick="deleteCart('${cart.pc_no}')">삭제</button>
                        </td>
                    </tr>
                    <c:set var="totalSum" value="${totalSum + (cart.p_price * cart.pc_count)}" />
                </c:forEach>
                
                <c:if test="${empty clist}">
                    <tr>
                        <td colspan="6" style="padding: 100px 0; color: #888;">장바구니에 담긴 상품이 없습니다.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>

        <c:if test="${not empty clist}">
            <div class="total-section">
                <span style="font-size: 16px; color: #888;">총 주문 금액</span><br>
                <strong style="font-size: 28px; color: #333;" id="finalTotalSum">
                    <fmt:formatNumber value="${totalSum}" pattern="#,###" />
                </strong><span style="font-size: 20px; font-weight: bold;"> 원</span>
                <br>
                <button type="button" class="btn-order" onclick="goOrderForm()">주문하기</button>
            </div>
        </c:if>
        
        
        <div style="margin-top: 17px;">
            <a href="/" class="btn-home">계속 쇼핑하기</a>
        </div>
    </div>
<%@ include file="/WEB-INF/views/user/member/mfaqChat.jsp" %>
<%@ include file="/WEB-INF/views/footer.jsp" %>
</body>
</html>