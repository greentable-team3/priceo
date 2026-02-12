<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn"%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>아이디 찾기</title>
    <style>
        /* 1. 기본 배경 및 폰트 설정 */
        body {
            font-family: 'Pretendard', sans-serif;
            background-color: #f8f9fa;
            margin: 0;
            padding: 0;
            color: #333;
        }

        /* 2. 본문 영역: 헤더 아래에 위치하며, 화면 높이에 맞춰 중앙 정렬 */
        .page-container {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        .find-id-content {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 50px 20px;
        }

        /* 3. 아이디 찾기 카드 박스 */
        .id-card {
            background: #fff;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.05);
            width: 100%;
            max-width: 400px; /* 박스 너비 고정 */
            text-align: center;
            box-sizing: border-box;
        }

        .id-card h3 {
            font-size: 24px;
            font-weight: 800;
            margin-bottom: 10px;
            color: #1e3a8a;
            margin-top: 0;
        }

        .id-card p {
            font-size: 14px;
            color: #666;
            margin-bottom: 25px;
        }

        /* 4. 입력창 및 버튼 */
        .id-card input[type="email"] {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 15px;
            box-sizing: border-box;
            outline: none;
            transition: border-color 0.2s;
        }

        .id-card input[type="email"]:focus {
            border-color: #1e3a8a;
        }

        .id-card button {
            width: 100%;
            padding: 14px;
            background-color: #1e3a8a !important; /* 네이비 고정 */
            color: #fff !important;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 15px;
            transition: transform 0.1s;
        }

        .id-card button:hover {
            background-color: #1e3a8a !important;
            transform: translateY(-1px);
        }

        /* 5. 결과창 */
        .result-box {
            margin-top: 20px;
            padding: 15px;
            background-color: #f1f4ff;
            border-radius: 8px;
            color: #1e3a8a;
            font-weight: 600;
        }

        .back-link {
            display: inline-block;
            margin-top: 25px;
            font-size: 14px;
            color: #888;
            text-decoration: none;
        }

        .back-link:hover {
            color: #1e3a8a;
            text-decoration: underline;
        }

        /* [핵심 교정] 헤더의 내부 정렬이 벌어지는 것을 방지 */
        header {
            display: block !important; /* 헤더의 flex 설정을 초기화하여 내부 정렬 보존 */
        }
    </style>
</head>
<body>

<div class="page-container">
    <%@ include file="/WEB-INF/views/header.jsp" %>

    <div class="find-id-content">
        <div class="id-card">
            <h3>아이디 찾기</h3>
            <p>가입 시 사용한 이메일을 입력하세요</p>

            <form action="/findId" method="post">
                <div>
                    <input type="email" name="m_email" placeholder="example@email.com" required>
                </div>
                <button type="submit">아이디 확인</button>
            </form>

            <c:if test="${not empty msg}">
                <div class="result-box">${msg}</div>
            </c:if>

            <c:if test="${not empty foundId}">
                <div class="result-box">
                    <c:forEach var="m" items="${idList}">
                        <div>아이디: ${fn:substring(m.m_id, 0, 3)}***</div>
                    </c:forEach>
                </div>

                <button type="button" onclick="location.href='/mresetPasswordForm'">
                    비밀번호 재설정하기
                </button>
            </c:if>

            <a href="/mloginForm" class="back-link">로그인으로 돌아가기</a>
        </div>
    </div>
</div>
<%@ include file="/WEB-INF/views/user/member/mfaqChat.jsp" %>
<%@ include file="/WEB-INF/views/footer.jsp" %>

<script>
let greeted = false;
let waitingMailConfirm = false;
let waitingProductConfirm = false;   // ⭐ 추가
let lastQuestion = "";
let productSearchUrl = "";

function toggleChat() {
    const chat = document.getElementById("faq-chat");
    const body = document.getElementById("chat-body");

    const isOpen = (chat.style.display === "block");
    chat.style.display = isOpen ? "none" : "block";

    if (!isOpen && !greeted) {
        const greet = document.createElement("div");
        greet.innerHTML = `
            <b>PRICEO</b><br><br>
            안녕하세요 PRICEO입니닷!😊<br>
            키워드로 검색해주세요 !<br>
            (예: 회원가입, 로그인, 배송, 주문 등)
            
            <hr>
        `;
        body.appendChild(greet);
        body.scrollTop = body.scrollHeight;
        greeted = true;
    }
}

// 🥊 방향키 제어용 인덱스
let focusIndex = -1;

$(document).ready(function() {
    const input = document.getElementById("searchInput");
    const listBox = document.getElementById("autocompleteList");
    const searchBtn = document.getElementById("searchBtn");

    if (input && listBox) {
        document.body.appendChild(listBox); 

        const updatePosition = () => {
            const rect = input.getBoundingClientRect();
            listBox.style.position = 'fixed';
            listBox.style.top = (rect.bottom) + 'px'; 
            listBox.style.left = (rect.left + 25) + 'px'; 
            listBox.style.width = (rect.width - 25) + 'px'; 
            listBox.style.zIndex = '1000000'; // 중앙 카드보다 무조건 위로!
            listBox.style.boxSizing = 'border-box';
        };

        // 🥊 1. 통합 입력 이벤트 (상품 + 숙소 병렬 호출)
        input.addEventListener("input", function() {
            const keyword = this.value.trim();
            focusIndex = -1;
            if (!keyword) {
                listBox.style.display = "none";
                return;
            }

            const stayAjax = $.ajax({ url: "${pageContext.request.contextPath}/stay/autocomplete", data: { q: keyword } });
            const productAjax = $.ajax({ url: "${pageContext.request.contextPath}/product/autocomplete", data: { q: keyword } });

            $.when(stayAjax, productAjax).done(function(stayRes, productRes) {
                const stays = stayRes[0] || [];
                const products = productRes[0] || [];
                
                if (stays.length === 0 && products.length === 0) {
                    listBox.style.display = "none";
                    return;
                }

                let html = "";
                // 🏨 숙소 목록 추가
                stays.forEach(item => {
                    html += `<div class="auto-item stay-item" style="padding:12px 20px; cursor:pointer; border-bottom:1px solid #f0f0f0; background:white; color:#333; text-align:left;">
                                <span style="margin-right:8px;">🏨</span>\${item} <small style="color:#888; float:right;">숙소</small>
                             </div>`;
                });
                // 🎁 상품 목록 추가
                products.forEach(item => {
                    html += `<div class="auto-item prod-item" style="padding:12px 20px; cursor:pointer; border-bottom:1px solid #f0f0f0; background:white; color:#333; text-align:left;">
                                <span style="margin-right:8px;">🎁</span>\${item} <small style="color:#888; float:right;">상품</small>
                             </div>`;
                });

                listBox.innerHTML = html;
                updatePosition();
                listBox.style.display = "block";
                
                $('.auto-item').off('click').on('click', function() {
                    const selectedText = $(this).text().replace(/🏨|🎁|숙소|상품/g, '').trim();
                    input.value = selectedText;
                    listBox.style.display = "none";
                    location.href = "/search?keyword=" + encodeURIComponent(selectedText);
                });
            });
        });

        // 🥊 2. 키보드 제어 이벤트 (방향키/엔터)
        input.addEventListener("keydown", function(e) {
            const items = listBox.querySelectorAll(".auto-item");
            
            if (listBox.style.display !== "none" && items.length > 0) {
                if (e.key === "ArrowDown") {
                    e.preventDefault();
                    focusIndex = (focusIndex + 1) % items.length;
                    updateFocus(items);
                } else if (e.key === "ArrowUp") {
                    e.preventDefault();
                    focusIndex = (focusIndex - 1 + items.length) % items.length;
                    updateFocus(items);
                } else if (e.key === "Enter") {
                    if (focusIndex > -1) {
                        e.preventDefault();
                        items[focusIndex].click();
                        return;
                    }
                } else if (e.key === "Escape") {
                    listBox.style.display = "none";
                }
            }
            
            if (e.key === "Enter" && focusIndex === -1 && input.value.trim()) {
                location.href = "/search?keyword=" + encodeURIComponent(input.value.trim());
            }
        });

        function updateFocus(items) {
            items.forEach((item, idx) => {
                item.style.backgroundColor = (idx === focusIndex) ? "#f5f5f5" : "white";
            });
        }

        if(searchBtn) {
            searchBtn.onclick = () => { if(input.value.trim()) location.href = "/search?keyword=" + encodeURIComponent(input.value.trim()); };
        }

        window.addEventListener('scroll', updatePosition);
        window.addEventListener('resize', updatePosition);
    }

    // 🥊 3. 다른 영역 클릭 시 닫기
    $(document).on("click", function(e) {
        if (!$(e.target).closest(".search-box").length && e.target !== listBox) {
            $(listBox).hide();
        }
    });
});
</script>
</body>
</html>