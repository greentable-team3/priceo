<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<!DOCTYPE html>
<html>
<head>
<link rel="icon" href="data:;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAMUlEQVQ4T2NkYGAQYcAP3uCTZhw1gGGYWAYgzRnMpwbDQDCCY6AnmB7Zjw6n8665gAAAABJRU5ErkJggg==">
<meta charset="UTF-8">
<title>PRICEO 메인</title>

<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="/js/Push.js"></script>

<style>
/* header.jsp에 있을 수도 있지만, 확실하게 하기 위해 main.jsp에 추가 */
#autocompleteList {
    position: absolute;
    background: white;
    width: 100%;
    max-height: 300px;
    overflow-y: auto;
    border: 1px solid #1e3a8a;
    border-radius: 10px;
    z-index: 9999; /* 메인 이미지에 가려지지 않게 최상단 배치 */
    display: none;
    box-shadow: 0 4px 10px rgba(0,0,0,0.1);
}

#autocompleteList div {
    padding: 12px 20px;
    cursor: pointer;
    text-align: left;
    color: #333;
    border-bottom: 1px solid #f0f0f0;
}

#autocompleteList div:hover {
    background-color: #f0f7ff;
    color: #1e3a8a;
}

/* ===== SUB NAV (카테고리 메뉴 업그레이드) ===== */
.sub-nav {
    display: flex;
    justify-content: center;
    gap: 10px;          /* 간격을 좁히고 버튼 형태로 구성 */
    padding: 40px 0 20px;
    background-color: transparent;
}

/* 공통: 모든 서브 메뉴를 캡슐 버튼 스타일로 */
.sub-nav a {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0px;            /* 처음엔 아이콘 자리를 비워둠 */
    padding: 12px 28px;
    border-radius: 50px;
    font-size: 18px;
    font-weight: 700;
    transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
    text-decoration: none;
    border: 1px solid transparent;
}

/* 2. [상품/숙소 목록] 기본 디자인 (연한 파란색 고정 느낌) */
.nav-products, .nav-stays {
    background-color: #f0f7ff; /* 아주 연한 블루 배경 */
    color: #1e3a8a;           /* 파란색 글자 */
    border: 1px solid #c2e0ff; /* 연한 파란 테두리 */
}

/* 3. [상품/숙소 목록] 마우스 호버 시 (파란색 채워짐 + 이모티콘) */
.nav-products:hover, .nav-stays:hover {
    background-color: #1e3a8a !important; /* 진한 파랑으로 채우기 */
    color: #fff !important;              /* 글자 하얗게 */
    gap: 8px;                            /* 아이콘 간격 생성 */
    padding: 12px 32px;                  /* 살짝 넓어지는 효과 */
    box-shadow: 0 4px 15px rgba(0, 122, 255, 0.3);
    transform: translateY(-3px);         /* 살짝 들리는 효과 */
}

/* 4. 이모티콘 넣기 (호버할 때만 나타나게 하려면 opacity 조정 가능) */
.nav-products::before { 
    content: '🎁'; 
    display: none; /* 기본은 숨김 */
}
.nav-stays::before { 
    content: '🏨'; 
    display: none; /* 기본은 숨김 */
}

/* 호버 시 아이콘 등장 */
.nav-products:hover::before, .nav-stays:hover::before {
    display: inline-block;
    animation: bounce 0.4s ease;
}

/* 아이콘 뿅 나타나는 애니메이션 */
@keyframes bounce {
    0% { transform: scale(0); }
    70% { transform: scale(1.2); }
    100% { transform: scale(1); }
}

/* [기존 실시간 인기 스타일 유지] */
.nav-popular {
    background-color: #fff9db !important;
    color: #f08c00 !important;
    border: 1px solid #ffe066 !important;
}
.nav-popular::before { content: '🔥'; margin-right: 8px; }
.nav-popular:hover {
    background-color: #ffec99 !important;
    box-shadow: 0 4px 12px rgba(255, 212, 59, 0.4) !important;
    transform: translateY(-3px);
}
/* [상품목록] 블루 스타일 */
.nav-products {
    border-color: #1e3a8a !important;
    color: #1e3a8a !important;
    background-color: #f0f7ff !important; /* 아주 연한 블루 배경 */
}
.nav-products::before { content: '🎁'; } /* 선물 상자 아이콘 */

/* [숙소목록] 블루 스타일 */
.nav-stays {
    border-color: #1e3a8a !important;
    color: #1e3a8a !important;
    background-color: #f0f7ff !important;
}
.nav-stays::before { content: '🏨'; } /* 호텔 아이콘 */


/* 마우스를 올렸을 때 효과 */
.sub-nav a:hover {
    color: #1e3a8a;     /* 메인 블루 */
    background-color: #fff;
    box-shadow: 0 4px 15px rgba(0, 122, 255, 0.1);
}

/* 활성화된 메뉴 표시 (밑줄 효과 추가) */
.sub-nav a::after {
    content: '';
    position: absolute;
    bottom: 5px;
    left: 50%;
    width: 0;
    height: 3px;
    background-color: #1e3a8a;
    transition: all 0.3s ease;
    transform: translateX(-50%);
    border-radius: 2px;
}

.sub-nav a:hover::after {
    width: 30px; /* 마우스 올리면 밑줄이 슥 생김 */
}

/* 2차 카테고리 (뷰티, 전자기기 등) 스타일 */
.category-nav {
    display: flex;
    justify-content: center;
    gap: 15px;
    margin-bottom: 30px;
}

.cate-item {
    background-color: #fff;
    border: 1px solid #d1d9e0;
    color: #7d8a99 !important;
    padding: 8px 20px;
    border-radius: 20px;
    font-size: 14px;
    font-weight: 600;
    transition: all 0.2s;
}

.cate-item:hover {
    border-color: #1e3a8a;
    color: #1e3a8a !important;
    background-color: #f0f7ff;
}

/* 실시간 인기 메뉴 전용 스타일 */
.nav-popular {
    background-color: #fff9db !important; /* 연한 노란색 배경 */
    color: #f08c00 !important;           /* 진한 주황빛 노란색 글자 */
    border: 1px solid #ffe066;           /* 테두리 포인트 */
    display: flex;
    align-items: center;
    gap: 5px;
}

/* 마우스 올렸을 때 더 밝게 */
.nav-popular:hover {
    background-color: #ffec99 !important;
    color: #e67700 !important;
    box-shadow: 0 4px 12px rgba(255, 212, 59, 0.3) !important;
    transform: translateY(-2px);
}

/* 아이콘 역할을 하는 불꽃 추가 */
.nav-popular::before {
    content: '🔥';
    font-size: 16px;
}

/* 클릭 시 밑줄도 노란색으로 변경 */
.nav-popular:hover::after {
    background-color: #f08c00 !important;
}
   

/* ===== 컨텐츠 레이아웃 (이미지 크게 설정) ===== */
.content-container {
    width: 100%;
    max-width: 1200px;
    margin: 0 auto;
}


/* 기존 HEADER, NAV 스타일은 유지하고 아래 부분만 확인/수정하세요 */

.product-grid {
    display: flex;
    flex-wrap: wrap; 
    gap: 20px; 
    padding: 20px 0;
    justify-content: flex-start;
}

/* 개별 상품 카드: 한 줄에 4개를 유지하며 너비를 강제 고정 */
.product-card {
    width: calc(25% - 15px) !important; /* 강제 적용 */
    cursor: pointer;
    margin-bottom: 30px;
    display: block !important;
}

/* 이미지 박스: 1:1 비율을 강제하여 사진 크기를 극대화 */
.img-box {
    width: 100% !important;
    aspect-ratio: 1 / 1 !important; /* 높이를 가로와 똑같이 맞춤 */
    overflow: hidden !important;
    border-radius: 12px;
    background-color: #f8f8f8;
}

/* 이미지 태그: 빈 공간 없이 꽉 채우기 (이미지가 커지는 핵심) */
.img-box img {
    width: 100% !important;
    height: 100% !important;
    object-fit: cover !important; /* contain에서 cover로 강제 변경 */
    display: block !important;
}

/* 텍스트 정보 */
.info-box {
    padding: 12px 5px;
}

/* 카테고리/주소 레이블 (작고 연하게) */
.category-label, .address-label {
    display: block;
    color: #999;
    font-size: 12px;
    margin-bottom: 4px;
}

.product-name {
    font-size: 16px; /* 이름 크기 살짝 키움 */
    font-weight: 600;
    margin-bottom: 8px;
    color: #333;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    line-height: 1.4;
}

.price-box {
    font-size: 18px;
    font-weight: 800;
    color: #000;
}

.price-box span {
    font-size: 14px;
    font-weight: normal;
}

.view-count {
    font-size: 12px;
    color: #bbb;
    margin-top: 6px;
}

.view-count {
        font-size: 12px;
        color: #bbb;
        margin-top: 6px;
        display: flex;
        align-items: center;
        gap: 4px;
    }
/* 인기 상품들이 담길 컨테이너를 가로 정렬 모드로 변경 */
#product-display {
    display: flex;             /* 자식 요소들을 가로로 나열 */
    flex-wrap: wrap;           /* 한 줄이 꽉 차면 자동으로 다음 줄로 넘김 */
    gap: 20px;                 /* 카드 사이의 일정한 간격 */
    justify-content: flex-start; /* 왼쪽부터 차례대로 정렬 */
    width: 100%;
    padding: 20px 0;
}

/* 인기 목록 카드 너비를 전체 상품과 동일하게 4등분 설정 */
#product-display .product-card {
    width: calc(25% - 15px) !important; /* 한 줄에 딱 4개가 들어가도록 계산 */
    display: block !important;           /* 세로 정렬 방지 */
}

/* 상품인지 숙소인지 알려주는 배지 디자인 */
.badge-STAY { background-color: #ff5a5f; color: white; padding: 2px 6px; border-radius: 4px; font-size: 11px; font-weight: bold; position: absolute; top: 10px; left: 10px; z-index: 10; }
.badge-PRODUCT { background-color: #1e3a8a; color: white; padding: 2px 6px; border-radius: 4px; font-size: 11px; font-weight: bold; position: absolute; top: 10px; left: 10px; z-index: 10; }



/* 1. 배너 전체를 감싸는 바구니 */
#popular-banner-container {
    width: 100%;
    height: 450px;           /* 배너의 전체 높이 설정 */
    overflow: hidden;        /* 영역 밖으로 나가는 사진 숨김 */
    position: relative;
    background: #f0f0f0;    /* 사진 로드 전 배경색 */
}

/* 2. 사진들이 가로로 줄 서는 기차 본체 */
#popular-slides {
    display: flex !important; /* 사진들을 가로로 나열 */
    width: 100%;
    height: 100%;
    transition: transform 0.5s ease-in-out;
    position: relative;
    z-index: 1; /* 사진 컨테이너는 아래에 */
}

/* 3. 개별 사진 칸 (기차 한 칸) */
.main-slide {
    flex: 0 0 100%;          /* 한 칸이 배너 너비를 100% 가득 채움 */
    width: 100%;
    height: 100%;
}

/* 4. 실제 이미지 태그 */
.main-slide img {
    width: 100%;
    height: 100%;
    object-fit: cover;       /* 사진이 찌그러지지 않고 꽉 차게 */
    display: block;
}

/* 글자 박스가 사진 위에 올라오게 설정 */
.banner-text-overlay {
    position: absolute;
    bottom: 0;
    left: 0;
    width: 100%;
    padding: 40px 20px;
    background: linear-gradient(transparent, rgba(0,0,0,0.7)); /* 배경을 투명에서 검정으로 */
    color: white;
    z-index: 999 !important; /* 글자는 가장 위에 */
    pointer-events: none; /* 글자 박스 때문에 클릭 안되는 현상 방지 */
}

#popular-slides img {
    /* 1. 이미지 렌더링 최적화 (가장 효과가 좋습니다) */
    image-rendering: -webkit-optimize-contrast; /* 크롬, 사파리 등에서 대비를 최적화 */
    image-rendering: crisp-edges;              /* 픽셀 경계선을 뚜렷하게 */
    
    /* 2. 선명도 조절 (살짝 필터를 주는 느낌) */
    filter: contrast(1.05) brightness(1.02);    /* 대비를 살짝 높여서 더 쨍하게 만듦 */
    
    /* 3. 부드러운 확대 방지 */
    -ms-interpolation-mode: nearest-neighbor;  /* IE용 (혹시 모르니) */
}

/* 화살표 버튼 공통 스타일 */
.banner-nav-btn {
    position: absolute;
    top: 50% !important;      /* 부모(배너)의 정확히 세로 가운데 */
    transform: translateY(-50%) !important;
    width: 50px;
    height: 50px;
    background-color: rgba(0, 0, 0, 0.2) !important; /* 배경을 더 투명하게 */
    color: white !important;
    border: none !important;
    border-radius: 50% !important;
    cursor: pointer;
    z-index: 2000 !important;   /* 모든 요소보다 위에 오도록 */
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
}

/* 마우스 올렸을 때만 진해지게 */
.banner-nav-btn:hover {
    background-color: rgba(0, 0, 0, 0.6) !important;
    transform: translateY(-50%) scale(1.1) !important; /* 살짝 커지는 효과 */
}

/* 왼쪽 버튼을 왼쪽 끝으로 */
#prev-btn {
    left: 20px !important;
}

/* 오른쪽 버튼을 오른쪽 끝으로 */
#next-btn {
    right: 20px !important;
}

#productSortArea {
    display: flex;
    justify-content: flex-end; /* 오른쪽 정렬 */
    align-items: center;
    gap: 12px;
    width: 100%;
    max-width: 1200px;         /* 상품 리스트 폭이랑 똑같이! */
    margin: 20px auto;         /* 위아래 여백 */
    padding-right: 15px;       /* 상품 카드 끝선과 맞추는 여백 */
}

/* 2. "정렬 기준" 텍스트 */
#productSortArea span {
    font-size: 14px;
    color: #7d8a99;
    font-weight: 600;
}

/* 3. 셀렉트 박스 (슬림 & 모던) */
#sortOrder {
    appearance: none;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' fill='%23555' viewBox='0 0 16 16'%3E%3Cpath d='M7.247 11.14L2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z'/%3E%3C/svg%3E");
    background-repeat: no-repeat;
    background-position: right 12px center;
    background-color: #fff;
    border: 1px solid #d1d9e0;
    border-radius: 6px;
    padding: 6px 35px 6px 15px; /* 높이를 살짝 줄여서 세련되게 */
    font-size: 14px;
    color: #444;
    cursor: pointer;
    transition: all 0.2s;
    box-shadow: 0 2px 5px rgba(0,0,0,0.02);
}

#sortOrder:hover {
    border-color: #1e3a8a;
}

#sortOrder:focus {
    outline: none;
    border-color: #1e3a8a;
}

/* 1. 이미지 박스에 overflow: hidden이 있어야 이미지가 밖으로 안 나갑니다 */
.img-box {
    overflow: hidden !important;
}

/* 2. 이미지 기본 상태: 부드러운 변화를 위해 transition 추가 */
.img-box img {
    transition: transform 0.3s ease-in-out !important;
}

/* 3. 카드에 마우스를 올렸을 때 이미지만 1.1배 확대 */
.product-card:hover .img-box img {
    transform: scale(1.1);
}


/* 챗봇 버튼이 무엇이든 배너보다 위에 오도록 설정 */
#chat-header, #faq-float-btn {
    z-index: 99999 !important;
    position: fixed; /* 위치가 고정되어 있는지 확인 */
}


</style>

</head>
<body>
<%@ include file="/WEB-INF/views/header.jsp" %>

<main class="content-container">
    <nav class="sub-nav">
        <a href="javascript:void(0);" class="main-menu nav-popular" id="btn-popular">실시간인기</a>
        <a href="#" class="main-menu nav-products" id="btn-all-products" data-url="/plist">상품목록</a>
        <a href="#" class="main-menu nav-stays" id="btn-all-stays" data-url="/stayList">숙소목록</a>
    </nav>
    
    <div id="popular-banner-container" style="position: relative; width: 100%; height: 400px; overflow: hidden; border-radius: 20px; margin-bottom: 40px; background: #f0f0f0;">
        <button id="prev-btn" class="banner-nav-btn" style="left: 20px;">
            <span style="font-weight: bold; font-size: 20px;">◀︎</span> 
        </button>
        <button id="next-btn" class="banner-nav-btn" style="right: 20px;">
            <span style="font-weight: bold; font-size: 20px;">▶︎</span>
        </button>
        <div id="popular-slides" style="display: flex; transition: transform 0.5s ease-in-out; height: 100%;"></div>
        <div id="banner-info" style="position: absolute; bottom: 30px; left: 30px; color: white; z-index: 20; text-shadow: 0 2px 10px rgba(0,0,0,0.5);">
            <span id="banner-badge" style="background: #ff5a5f; padding: 4px 10px; border-radius: 5px; font-weight: bold; font-size: 14px;">인기 급상승</span>
            <h2 id="banner-title" style="font-size: 32px; margin: 10px 0;">로딩 중...</h2>
            <p id="banner-price" style="font-size: 20px;"></p>
        </div>
        <div style="position: absolute; bottom: 0; left: 0; width: 100%; height: 50%; background: linear-gradient(transparent, rgba(0,0,0,0.7)); z-index: 10;"></div>
    </div>

    <div id="productSortArea">
        <span>정렬 기준</span>
        <select id="sortOrder" onchange="changeSort(this.value)">
            <option value="" selected disabled>정렬</option>
            <option value="newest">최신순</option>
            <option value="price_low">가격 낮은 순</option>
            <option value="price_high">가격 높은 순</option>
            <option value="view_desc">조회수 많은 순</option>
        </select>
    </div>

    <div id="category-area" class="category-nav" style="text-align: center; margin-bottom: 20px; display: none;">
        <a href="#" class="cate-item" data-cate="뷰티">뷰티</a>
        <a href="#" class="cate-item" data-cate="전자기기">전자기기</a>
        <a href="#" class="cate-item" data-cate="푸드">푸드</a>
    </div>

    <div id="product-display" class="content-container"></div>
</main>

<%@ include file="/WEB-INF/views/user/member/mfaqChat.jsp" %>
<%@ include file="/WEB-INF/views/footer.jsp" %>

<script>
let popularData = [];
let currentSlide = 0;
let slideInterval = null;
let focusIndex = -1; // 방향키 제어용 인덱스

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
            listBox.style.zIndex = '1000000';
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

        // 🥊 2. 키보드 제어 이벤트
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

    loadPopularList(); // 실시간 인기 리스트 초기 로드
    $('#category-area').hide();
    $('#productSortArea').hide();
    
    // 초기 실행 및 기존 로직 (건드리지 않음)
    loadPopularList();

 // 메인 메뉴 클릭 이벤트
    $('.main-menu').on('click', function(e) {
        e.preventDefault();
        var menuId = $(this).attr('id');
        var url = $(this).data('url');

        if (menuId === 'btn-popular') {
            $('#category-area').slideUp(200);
            $('#productSortArea').hide(); 
            loadPopularList(); 
        } else if (url) {
            fetchList(url, null);
        }
    });

 // 카테고리 아이템 클릭 이벤트
    $('.cate-item').on('click', function(e) {
        e.preventDefault();
        $('#sortOrder').val(""); // 정렬 초기화
        var categoryValue = $(this).data('cate');
        $('.cate-item').css({'color': '#888', 'font-weight': 'normal'});
        $(this).css({'color': '#000', 'font-weight': 'bold'});
        fetchList('/plist', categoryValue, 'newest');
    });

    // 배너 화살표 클릭 이벤트
    $('#next-btn').on('click', function() {
        if (!popularData.length) return;
        currentSlide = (currentSlide + 1) % popularData.length;
        updateBannerText(currentSlide);
        startBannerTimer();
    });

    $('#prev-btn').on('click', function() {
        if (!popularData.length) return;
        currentSlide = (currentSlide - 1 + popularData.length) % popularData.length;
        updateBannerText(currentSlide);
        startBannerTimer();
    });


    $(document).on("click", function(e) {
        if (!$(e.target).closest(".search-box").length && e.target !== listBox) {
            $(listBox).hide();
        }
    });
});

// 기존 함수들 (건드리지 않음)
function changeSort(val) {
    // 사용자가 선택한 정렬 값을 로컬 스토리지에 저장
    localStorage.setItem('selectedSort', val);

    if ($('#category-area').is(':visible')) {
        var currentCate = null;
        $('.cate-item').each(function() {
            if ($(this).css('font-weight') === '700' || $(this).css('font-weight') === 'bold') {
                currentCate = $(this).data('cate');
            }
        });
        fetchList('/plist', currentCate, val);
    } else {
        fetchList('/stayList', null, val);
    }
}


//Ajax 리스트 로딩
function fetchList(targetUrl, categoryData, sortValue) {
    var ajaxUrl = targetUrl + (targetUrl.indexOf('?') > -1 ? '&' : '?') + "isAjax=true&isMain=true";
    var currentSort = sortValue || $('#sortOrder').val() || 'newest';
    
    $.ajax({
        url: ajaxUrl, 
        type: "GET", 
        data: { p_category: categoryData, sort: currentSort },
        success: function(response) {
            var $html = $(response);
            var content = $html.filter('.product-container').length > 0 ? $html.filter('.product-container').html() : $html.find('.product-container').html();
            $('#product-display').empty().html(content || response);

            if (targetUrl.indexOf('/plist') > -1 || targetUrl.indexOf('/stayList') > -1) {
                $('#productSortArea').show(); 
                $('#category-area').toggle(targetUrl.indexOf('/plist') > -1);
            } else {
                $('#productSortArea, #category-area').hide();
            }
        }
    });
}

// 인기 리스트 로드 및 화면 렌더링
function loadPopularList() {
    $.ajax({
        url: "/api/main/popular",
        type: "GET",
        dataType: "json",
        success: function(data) {
            if (!data || data.length === 0) return;
            popularData = data;
            const slideContainer = $('#popular-slides');
            const listContainer = $('#product-display');
            slideContainer.empty();
            listContainer.empty();
            if (slideInterval) clearInterval(slideInterval);

            let listHtml = '';
            popularData.forEach((item) => {
                const type = (item.type || "").toUpperCase();
                const isStay = (type === 'STAY');
                const imgName = item.thumb || item.p_image || item.s_image;
                const path = isStay ? '/stay/' : '/product/';
                const id = item.p_no || item.P_NO;
                const detailUrl = isStay ? '/stayDetail?s_no=' + id : '/pdetail?p_no=' + id;
                const badgeColor = isStay ? '#ff5a5f' : '#1e3a8a';

                // 슬라이드 추가
                slideContainer.append('<div class="main-slide" onclick="location.href=\'' + detailUrl + '\'" style="flex:0 0 100%; width:100%; height:100%; cursor:pointer; position:relative;"><img src="' + (path + imgName) + '" style="width:100%; height:100%; object-fit:cover; display:block;"></div>');

                // 리스트 카드 추가
                listHtml += 
                    '<div class="product-card" onclick="location.href=\'' + detailUrl + '\'">' +
                        '<div class="img-box" style="position:relative;">' +
                            '<span class="badge" style="position:absolute; top:10px; left:10px; background:' + badgeColor + '; color:white; padding:4px 8px; border-radius:4px; font-size:11px; font-weight:bold; z-index:10;">' + (isStay ? '숙소' : '상품') + '</span>' +
                            '<img src="' + (path + imgName) + '" style="width:100%; height:100%; object-fit:cover;">' +
                        '</div>' +
                        '<div class="info-box">' +
                            '<p class="product-name">' + (item.p_name || item.name) + '</p>' +
                            '<p class="price-box">' + Number(item.p_price).toLocaleString() + '원</p>' +
                            '<div class="view-count">🔥 조회수 ' + (item.p_view || 0).toLocaleString() + '</div>' +
                        '</div>' +
                    '</div>';
            });
            listContainer.append(listHtml);
            currentSlide = 0;
            updateBannerText(0);
            startBannerTimer();
        }
    });
}

// 배너 텍스트 업데이트
function updateBannerText(index) {
    if (!popularData || popularData.length === 0) return;
    $('#popular-slides').css('transform', 'translateX(-' + (index * 100) + '%)');
    const item = popularData[index];
    $('#banner-badge').text((item.type || "").toUpperCase() === 'STAY' ? '인기 숙소' : '인기 상품');
    $('#banner-title').text(item.p_name || item.name);
    $('#banner-price').text(Number(item.p_price).toLocaleString() + '원');
}

// 배너 타이머
function startBannerTimer() {
    if (slideInterval) clearInterval(slideInterval);
    slideInterval = setInterval(() => {
        if (popularData.length <= 1) return;
        currentSlide = (currentSlide + 1) % popularData.length;
        updateBannerText(currentSlide);
    }, 5000);
}
</script>

</body>
</html>