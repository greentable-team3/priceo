<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>상단바</title>
<style>
/* ===== 기본 ===== */
body {
	background-color: #f1f5f9 !important;
    margin: 0;
    font-family: 'Pretendard', Arial, sans-serif;
}

a {
    text-decoration: none;
    color: inherit;
    transition: all 0.2s ease;
}

/* ===== HEADER (블루 테마 적용) ===== */
.top-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 30px;
    border-bottom: 1px solid #d1d9e0; 
    height: 100px;
    position: sticky;
    top: 0;
    background-color: rgba(240, 244, 248, 0.95); 
    backdrop-filter: blur(10px); 
    z-index: 1000;
    /* 🥊 추가: 자식이 밖으로 나가는 것을 허용 */
    overflow: visible !important; 
}

.logo-area {
    display: flex;
    align-items: center;
    flex: 1;              
    justify-content: flex-start;
}

.logo-area img {
    height: 100%;    
    max-height: 75px; 
    width: auto;      
    object-fit: contain;
    filter: drop-shadow(0 2px 4px rgba(0,0,0,0.05));
}

/* ===== 🔍 메인 검색창 전용 스타일 (여기를 고쳤습니다) ===== */
.search-area {
    flex: 1;              
    display: flex;
    justify-content: center; 
    /* 🥊 추가: 자동완성창이 여기를 뚫고 나가야 함 */
    overflow: visible !important; 
}

.search-box {
    position: relative; /* 자동완성 박스의 기준점 */
    display: flex;
    width: 500px;         
}

.search-box input {
    flex: 1;
    padding: 14px 25px;
    border: 2px solid #1e3a8a; 
    border-right: none;
    border-radius: 35px 0 0 35px; 
    font-size: 15px;
    outline: none;
    background-color: #fff;
}

.search-box button {
    padding: 14px 30px;
    border: 2px solid #1e3a8a;
    background: #1e3a8a; 
    color: #fff; 
    cursor: pointer;
    border-radius: 0 30px 30px 0;
    font-size: 14px;
    font-weight: 600;
    transition: background 0.2s;
}

/* 🥊 [핵심] 메인 검색창 자동완성 박스 - 왼쪽에 딱 맞춤 */
#autocompleteList {
    display: none;
    position: absolute;
    top: 100%;             /* 인풋창 바로 아래 */
    left: 0;               /* 왼쪽 끝에 맞춤 */
    width: calc(100% - 103px); /* 🥊 버튼 너비를 제외하고 인풋창 너비에만 딱! */
    background-color: #ffffff !important;
    border: 2px solid #1e3a8a;
    border-top: 1px solid #eee; 
    z-index: 2000;         
    border-radius: 0 0 0 20px; /* 인풋 곡선에 맞춰 왼쪽 아래만 둥글게 */
    box-shadow: 0 4px 10px rgba(0,0,0,0.1);
    max-height: 250px;
    overflow-y: auto;
    box-sizing: border-box;
}

#autocompleteList div {
    padding: 12px 25px;
    cursor: pointer;
    font-size: 14px;
    color: #333;
    text-align: left;
}

#autocompleteList div:hover {
    background-color: #f0f7ff;
    color: #1e3a8a;
}

/* ===== 유저 메뉴 ===== */
.user-area {
    flex: 1;              
    display: flex;
    justify-content: flex-end; 
    align-items: center;
}
	
.user-area a {
    margin-left: 20px;
    font-size: 14px;
    color: #5a6a7a;
    font-weight: 600;
    display: flex;
    flex-direction: column; 
    align-items: center;
    gap: 6px;
    transition: color 0.2s ease;
    white-space: nowrap;
    position: relative; 
}

.user-area a::before {
    font-size: 18px; 
    margin-bottom: 2px;
}

.nav-views::before { content: '📊'; }
.nav-login::before { content: '🔑'; }
.nav-signup::before { content: '📝'; }
.nav-info::before { content: '👤'; }
.nav-cart::before { content: '🛒'; }
.nav-order::before { content: '📦'; }
.nav-logout::before { content: '🚪'; }

.cart-badge {
    position: absolute;
    top: -5px;          
    right: -2px;        
    background-color: #ef4444; 
    color: #ffffff;
    font-size: 10px;
    font-weight: 800;
    min-width: 16px;
    height: 16px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 2px solid #f0f4f8; 
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    z-index: 10;
}

.user-area a:hover {
    color: #1e3a8a;
    transform: translateY(-2px); 
}

.user-area a.nav-admin {
    flex-direction: row; 
    padding: 6px 15px;
    background: #e6f7f4;
    color: #00b894;
    border-radius: 20px;
    margin-left: 20px;
}
.user-area a.nav-admin::before { 
    content: '🛡️'; 
    font-size: 14px;
    margin-right: 5px;
}
.user-area a.nav-admin:hover {
    background: #00b894;
    color: #fff;
}

/* 3. 자동완성 박스 위치 세밀 조정 */
#autocompleteList {
    display: none;
    position: absolute;
    /* top: 100% 대신 고정 수치(px)를 써서 인풋 바로 아래 맞춤 */
    top: 51px;             
    left: 0;               
    width: 397px;          
    background-color: #ffffff !important;
    border: 2px solid #1e3a8a;
    border-top: 1px solid #eee; 
    /* 🥊 z-index를 최대로 높여 메인 컨텐츠 위로 띄움 */
    z-index: 99999 !important;         
    border-radius: 0 0 20px 20px; 
    box-shadow: 0 8px 15px rgba(0,0,0,0.2); 
    max-height: 300px;
    overflow-y: auto;
    box-sizing: border-box;
}
</style>
</head>
<body>

<header>
    <div class="top-header">
        <div class="logo-area">
            <a href="/"><img src="/image/mainlogo.png" alt="PRICEO 로고"></a>
        </div>

        <div class="search-area">
            <div class="search-box">
                <input type="text" id="searchInput"
                       placeholder="상품 및 숙소를 검색해보세요"
                       autocomplete="off">
                <button type="button" id="searchBtn">검색</button>
                <div id="autocompleteList"></div>
            </div>
        </div>

		 <div class="user-area">
		    <sec:authorize access="isAnonymous()">
		        <a href="/mloginForm" class="nav-login">로그인</a>
		        <a href="/msignup" class="nav-signup">회원가입</a>
		        <a href="/cartlist" class="nav-cart">장바구니<span class="cart-badge">0</span></a>
		        <a href="/orderlist" class="nav-order">주문목록</a>
		    </sec:authorize>
		    
		    <sec:authorize access="isAuthenticated()">
		        <a href="/myinfo" class="nav-info">내 정보</a>
		        <a href="/cartlist" class="nav-cart">
		            장바구니
		            <c:choose>
		                <c:when test="${not empty sessionScope.cartTypeCount}">
		                    <span class="cart-badge">${sessionScope.cartTypeCount}</span>
		                </c:when>
		                <c:otherwise>
		                    <span class="cart-badge">0</span>
		                </c:otherwise>
		            </c:choose>
		        </a>
		        <sec:authorize access="!hasAuthority('ADMIN')">
			        <a href="/orderlist" class="nav-order">주문목록</a>
			    </sec:authorize>
		        <a href="/logout" class="nav-logout">로그아웃</a>
		    </sec:authorize>
		    
		    <sec:authorize access="hasAuthority('ADMIN')">
		    	<a href="http://192.168.10.103:5601/app/dashboards#/view/cbc0c600-055a-11f1-b56a-7942d6b7688e?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now-15m,to:now))&_a=(description:'',filters:!(),fullScreenMode:!f,options:(hidePanelTitles:!f,useMargins:!t),query:(language:kuery,query:''),timeRestore:!f,title:priceo,viewMode:view)" class="nav-views">통계자료</a>
		        <a href="/adminhome" class="nav-admin">관리자센터</a>
		    </sec:authorize>
		</div>
    </div>
    
</header>
<script>
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('searchInput');
    const autocompleteList = document.getElementById('autocompleteList');
    const searchBtn = document.getElementById('searchBtn');

    if(!searchInput || !searchBtn) return;

    // 1. 자동완성 데이터 가져오기 (비동기 처리)
    const getAutocomplete = async (val) => {
        if (!val.trim()) {
            autocompleteList.style.display = 'none';
            return;
        }
        try {
            // 🥊 [핵심 수정] 404 에러를 잡기 위해 주소를 /product/autocomplete로 변경
            const res = await fetch('/product/autocomplete?q=' + encodeURIComponent(val));
            
            if (!res.ok) throw new Error('Network response was not ok');
            
            const data = await res.json();
            
            if (data && data.length > 0) {
                autocompleteList.innerHTML = '';
                data.forEach(item => {
                    const div = document.createElement('div');
                    div.textContent = item;
                    div.onclick = () => {
                        searchInput.value = item;
                        autocompleteList.style.display = 'none';
                        performSearch(item);
                    };
                    autocompleteList.appendChild(div);
                });
                autocompleteList.style.display = 'block';
            } else {
                autocompleteList.style.display = 'none';
            }
        } catch (e) { 
            console.log("자동완성 통신 실패:", e); 
        }
    };

    // 2. 검색 실행 함수
    const performSearch = (keyword) => {
        if (keyword.trim()) {
            location.href = "/search?keyword=" + encodeURIComponent(keyword);
        }
    };

    // 이벤트 리스너들
    searchInput.addEventListener('input', (e) => getAutocomplete(e.target.value));
    
    searchBtn.addEventListener('click', (e) => {
        e.preventDefault(); 
        performSearch(searchInput.value);
    });

    searchInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            performSearch(searchInput.value);
        }
    });

    // 외부 클릭 시 닫기
    document.addEventListener('click', (e) => {
        if (!searchInput.contains(e.target)) autocompleteList.style.display = 'none';
    });
});
</script>

</body>
</html>