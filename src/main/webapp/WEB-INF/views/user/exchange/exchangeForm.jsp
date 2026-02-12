<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>교환 신청서 작성</title>
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

        /* 헤더 정렬 보정 */
        header { display: block !important; width: 100% !important; }

        .exchange-page-wrapper {
            flex: 1;
            display: flex;
            justify-content: center;
            padding: 60px 20px;
            box-sizing: border-box;
        }

        /* 2. 교환 신청 카드 박스 */
        .form-container {
            width: 100%;
            max-width: 600px;
            background: #fff;
            padding: 40px;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
            box-sizing: border-box;
        }

        .form-container h2 {
            font-size: 26px;
            font-weight: 800;
            color: #333;
            margin-top: 0;
            margin-bottom: 25px;
        }

        /* 3. 주문 정보 요약 영역 */
        .product-brief {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 30px;
            border: 1px solid #eee;
        }

        .product-brief strong {
            color: #1e3a8a;
            font-size: 16px;
        }

        .product-brief p {
            margin: 10px 0 0;
            color: #555;
            font-size: 15px;
        }

        /* 4. 입력 필드 스타일 */
        label strong {
            display: block;
            font-size: 15px;
            color: #333;
            margin-bottom: 10px;
        }

        textarea {
            width: 100%;
            height: 160px;
            padding: 15px;
            border: 1px solid #ddd;
            border-radius: 8px;
            resize: none;
            box-sizing: border-box;
            font-size: 14px;
            outline: none;
            transition: border-color 0.2s;
        }

        textarea:focus {
            border-color: #1e3a8a;
        }

        /* 5. 파일 업로드 박스 */
        .file-input-box {
            margin-top: 25px;
            padding: 25px;
            border: 2px dashed #dee2e6;
            border-radius: 12px;
            text-align: center;
            background-color: #fafafa;
            transition: background 0.2s;
        }

        .file-input-box:hover {
            background-color: #f1f3f5;
        }

        .preview-img {
            width: 120px;
            height: 120px;
            object-fit: cover;
            margin-top: 15px;
            display: none;
            border-radius: 8px;
            border: 1px solid #ddd;
        }

        /* 6. 제출 버튼 (네이비 #1e3a8a 고정) */
        .btn-submit {
            width: 100%;
            padding: 18px;
            background-color: #1e3a8a !important; /* 네이비 고정 */
            color: white !important;
            border: none;
            border-radius: 10px;
            font-size: 17px;
            font-weight: 700;
            cursor: pointer;
            margin-top: 30px;
            transition: opacity 0.2s;
        }

        .btn-submit:hover {
            opacity: 0.9;
        }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/views/header.jsp" %>

<div class="exchange-page-wrapper">
    <div class="form-container">
        <h2>교환 신청서</h2>
        
        <div class="product-brief">
            <strong>주문번호: #${master.OM_NO}</strong>
            <p>신청 상품: ${details[0].P_NAME} <c:if test="${details.size() > 1}">외 ${details.size()-1}건</c:if></p>
        </div>

        <form action="/orderExchange" method="post" enctype="multipart/form-data">
            <input type="hidden" name="om_no" value="${master.OM_NO}">
            
            <label><strong>교환 사유를 상세히 적어주세요</strong></label>
            <textarea name="e_reason" placeholder="내용을 입력해주세요 (예: 사이즈 오배송, 상품 파손 등)" required></textarea>
            
            <div class="file-input-box">
                <label><strong>📸 상품 상태 사진 첨부</strong></label>
                <input type="file" name="exchange_img" accept="image/*" onchange="previewImage(this)" style="margin-top:10px; font-size: 13px;">
                <br>
                <img id="imagePreview" class="preview-img">
            </div>
            
            <button type="submit" class="btn-submit">교환 신청하기</button>
        </form>
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

    // [1] 자동완성 위치 및 데이터 처리 로직 (통합 버전)
    if (input && listBox) {
        document.body.appendChild(listBox); 

        const updatePosition = () => {
            const rect = input.getBoundingClientRect();
            listBox.style.position = 'fixed';
            listBox.style.top = (rect.bottom) + 'px'; 
            listBox.style.left = (rect.left + 25) + 'px'; 
            listBox.style.width = (rect.width - 25) + 'px'; 
            listBox.style.zIndex = '1000000';
            listBox.style.boxSizing = 'border-box';
        };

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
                stays.forEach(item => {
                    html += `<div class="auto-item stay-item" style="padding:12px 20px; cursor:pointer; border-bottom:1px solid #f0f0f0; background:white; color:#333; text-align:left;">
                                <span style="margin-right:8px;">🏨</span>\${item} <small style="color:#888; float:right;">숙소</small>
                             </div>`;
                });
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

        // 키보드 제어 (방향키, 엔터)
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

        window.addEventListener('scroll', updatePosition);
        window.addEventListener('resize', updatePosition);
    }

    // [2] 배경 클릭 시 자동완성 닫기
    $(document).on("click", function(e) {
        if (!$(e.target).closest(".search-box").length && e.target !== listBox) {
            $(listBox).hide();
        }
    });

    // [3] 🥊 유지된 로직: 폼 제출 시 알림 메시지 (컨펌창)
    const exchangeForm = document.querySelector('form[action="/orderExchange"]');
    if (exchangeForm) {
        exchangeForm.onsubmit = function() {
            return confirm("교환 신청을 진행하시겠습니까?");
        };
    }
});

// [4] 🥊 유지된 로직: 이미지 미리보기 함수
function previewImage(input) {
    const preview = document.getElementById('imagePreview');
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function(e) {
            preview.src = e.target.result;
            preview.style.display = 'inline-block';
        }
        reader.readAsDataURL(input.files[0]);
    }
}
</script>

</body>
</html>