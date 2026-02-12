<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>상품 상세보기</title>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<style>
    /* 1. 기본 레이아웃 및 전체 배경 */
    body { background-color: #f8f9fa; font-family: 'Pretendard', sans-serif; }
    
    .tab-menu {
        display: flex;
        justify-content: center;
        margin: 40px 0 20px;
        border-bottom: 2px solid #eee;
    }
    /* 탭 버튼 기본 스타일 */
	.tab-btn {
	    width: 200px;
	    padding: 15px;
	    font-size: 18px;
	    font-weight: normal; /* 기본은 보통 굵기 */
	    background: none;
	    border: none;
	    cursor: pointer;
	    color: #888;
	    border-bottom: 2px solid transparent; /* 밑줄 자리 확보 */
	    transition: 0.3s;
	}
	
	/* 활성화된 탭 스타일 (클릭 시 적용됨) */
	.tab-btn.active {
	    color: #333; /* 글자색 진하게 */
	    font-weight: bold; /* 글자 굵게 */
	    border-bottom: 3px solid #333; /* 검은색 강조선 */
	}
    .tab-content {
        display: none; /* 기본적으로 숨김 */
        padding: 20px;
        text-align: center;
    }
    .tab-content.active {
        display: block; /* active 클래스가 붙은 것만 보임 */
    }
   
    /* 전체 컨테이너: 가로폭을 제한하고 중앙으로 모음 */
    .detail-container {
        max-width: 900px;
        margin: 50px auto;
        padding: 40px;
        background: #fff;
        border: 1px solid #f0f0f0;
        border-radius: 20px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.05);
    }

    /* 상단 제목: 중앙 정렬 및 선 강조 */
    .detail-header {
        text-align: center;
        margin-bottom: 40px;
    }
    .detail-header h2 {
        font-size: 28px;
        color: #222;
        display: inline-block;
        padding-bottom: 10px;
        border-bottom: 3px solid #333;
    }

    /* 상품 이미지: 그림자 효과로 입체감 부여 */
    .product-img-box {
        text-align: center;
        margin-bottom: 40px;
    }
    .product-img-box img {
        width: 100%;
        max-width: 600px;
        border-radius: 15px;
        box-shadow: 0 5px 20px rgba(0,0,0,0.08);
    }

    /* 상품 정보 텍스트: 깔끔한 정렬 */
    .product-info-text {
        text-align: center;
        margin-bottom: 30px;
    }
    .product-info-text h3 { font-size: 24px; margin-bottom: 15px; }
    .price-text { font-size: 26px; color: #e74c3c; font-weight: bold; }

    /* 구매 섹션: 카드 형태로 디자인하여 균형 유지 */
    .purchase-card {
        background: #fcfcfc;
        border: 1px solid #eee;
        border-radius: 15px;
        padding: 30px;
        margin-bottom: 30px;
    }
    
    #backToTop {
	  display: none;        /* 초기에는 숨김 */
	  position: fixed;     /* 화면에 고정 */
	  bottom: 20px;        /* 밑에서 20px */
	  right: 30px;         /* 오른쪽에서 30px */
	  z-index: 99;         /* 다른 요소보다 위에 있게 */
	  border: none;
	  outline: none;
	  background-color: #1e3a8a; /* 이미지 분위기에 맞춘 색상 예시 */
	  color: white;
	  cursor: pointer;
	  padding: 15px;
	  border-radius: 50%;   /* 동그란 모양 */
	  font-size: 18px;
	}
	
	#backToTop:hover {
	  background-color: #0984e3; /* 마우스 올렸을 때 색상 변화 */
	}
	
	/* 리뷰 */
    .review-container { max-width: 1200px; margin: 50px auto; padding: 20px; border-top: 2px solid #eee; }
    .review-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
    .review-card { padding: 20px; border-bottom: 1px solid #f0f0f0; margin-bottom: 15px; }
    .review-img { width: 120px; height: 120px; border-radius: 10px; object-fit: cover; margin-top: 10px; cursor: pointer; }
    .star-rating { color: #ff5a5f; font-weight: bold; }
    .review-form-box { background: #f8f9fa; padding: 30px; border-radius: 15px; margin-top: 40px; }
    
    /* 미리보기 */
    .preview-item {transition: transform 0.2s;}
   	.preview-item:hover {transform: scale(1.05);}
   	#preview-container {
       display: flex; 
       gap: 10px; 
       margin-bottom: 10px; 
       flex-wrap: wrap;
       min-height: 10px; /* 컨테이너가 찌그러지지 않게 최소 높이 부여 */
   	}
   	.preview-item img {
       display: block; /* 인라인 여백 제거 */
   	}
	
	
	/* 공통 버튼 베이스 */
	.btn-primary {
	    background-color: #1e3a8a !important; /* 사용자님이 원하시는 색상 */
	    color: #fff !important;
	    border: none;
	    cursor: pointer;
	    transition: 0.3s;
	}

	
	/* 목록 버튼 등 보조 버튼 */
	.btn-secondary {
	    background-color: #1e3a8a !important;
	    color: #fff !important;
	    border: 1px solid #1e3a8a !important;
	    cursor: pointer;
	}
	
	/* 장바구니 버튼 전용 */
	.btn-cart-main {
	    width: 100%;
	    height: 65px;
	    border-radius: 10px;
	    font-size: 20px;
	    font-weight: bold;
	    margin-top: 25px;
	}
	
    
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/header.jsp" %>

	<div class="detail-container">
	    <div class="detail-header"><h2>상품 상세 정보</h2></div>
	    <div class="product-img-box"><img src="/product/${dto.p_image}"></div>
	    <div class="product-info-text">
	        <h3>${dto.p_name}</h3>
	        <p class="price-text"><fmt:formatNumber value="${dto.p_price}" pattern="#,###" />원</p>
	        <div style="color: #888; margin-top: 10px;">
	            <span>${dto.p_category}</span> | <span>재고 ${dto.p_count}개</span>
	        </div>
	    </div>
	    <div class="purchase-card">
		    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
		        <span style="font-weight: bold; font-size: 18px;">구매 수량</span>
		        <div style="display: flex; align-items: center;">
		            <div style="display: flex; align-items: center; border: 1px solid #ddd; border-radius: 5px; background: #fff;">
		                <button type="button" onclick="changeQty(-1)" style="width:40px; height:40px; border:none; background:none; cursor:pointer; font-size:20px;">-</button>
		                <input type="number" id="order_qty" name="pc_count" value="1" min="1" max="5" readonly style="width: 60px; text-align: center; border:none; border-left:1px solid #ddd; border-right:1px solid #ddd; font-size:18px;">
		                <button type="button" onclick="changeQty(1)" style="width:40px; height:40px; border:none; background:none; cursor:pointer; font-size:20px;">+</button>
		            </div>
		        </div>
		    </div>
		    <div style="text-align: right; margin-top: -10px; margin-bottom: 20px;">
		        <span style="font-size: 12px; color: #888;">(최대 5개 구매 가능)</span>
		    </div>
		    <div style="text-align: right; border-top: 1px solid #eee; padding-top: 20px;">
		        <span style="color: #888;">최종 결제 금액</span><br>
		        <strong id="total_amt" style="font-size: 32px; color: #222;"><fmt:formatNumber value="${dto.p_price}" pattern="#,###" /></strong><span style="font-size: 20px;"> 원</span>
		    </div>
		    <button type="button" onclick="addCart()" class="btn-primary btn-cart-main">장바구니 담기</button>
		</div>
	    <div style="text-align: center; display: flex; justify-content: center; gap: 15px;">
	        <button onclick="location.href='/'" class="btn-secondary" style="padding: 10px 25px; border-radius: 5px;">목록</button>
            <sec:authorize access="hasAuthority('ADMIN')">
                <button onclick="location.href='/pupdateForm?p_no=${dto.p_no}'" style="padding: 10px 25px; background: #fff; border: 1px solid #ddd; border-radius: 5px; cursor: pointer;">수정</button>
                <button onclick="pdelete('${dto.p_no}')" style="padding: 10px 25px; background: #fff; border: 1px solid #ff4d4d; color: #ff4d4d; border-radius: 5px; cursor: pointer;">삭제</button>
            </sec:authorize>
	    </div>
	</div>
	
	<div class="tab-menu">
	    <button type="button" class="tab-btn active" onclick="openTab('description')">상세설명</button>
	    <button type="button" class="tab-btn" onclick="openTab('reviews')">리뷰</button>
	</div>

	<div id="description" class="tab-content active">
        <h4>상품 상세 정보</h4>
	    <div style="display: flex; flex-direction: column; align-items: center; gap: 20px;">
	        <c:forEach items="${imageList}" var="img"><img src="/product/${img.i_savefile}" style="max-width: 100%; height: auto; display: block;"></c:forEach>
	    </div>
	</div>
	
	<div id="reviews" class="tab-content">
        <div class="review-container" style="border-top: none; margin-top: 0;">
            <div class="review-header">
                <h2>상품후기 <span style="color:#ff5a5f;">${reviewList.size()}</span></h2>
                <div class="star-rating" style="font-size: 1.5em;">★ <fmt:formatNumber value="${avgScore}" pattern="0.0"/> / 5.0</div>
            </div>

            <c:forEach items="${reviewList}" var="r">
               <div class="review-card">
                   <div style="display: flex; align-items: center; width: 100%;">
                       <div style="display: flex; align-items: center; gap: 15px; min-width: 250px;">
                           <strong>${r.m_nickname}</strong>
                           <span class="star-rating"><c:forEach begin="1" end="${r.r_score}">★</c:forEach></span>
                       </div>
                       <div style="flex-grow: 1;"></div> 
                       <div> <%-- 리뷰 번호를 삭제하고 삭제 버튼만 남김 --%>
                           <sec:authorize access="hasAuthority('ADMIN')">
						        <a href="javascript:void(0);" onclick="deleteReview(${r.r_no}, ${dto.p_no})" 
						           style="color: #ff5a5f; font-size: 0.85em; text-decoration: none; border: 1px solid #ff5a5f; padding: 2px 10px; border-radius: 4px;">삭제</a>
						    </sec:authorize>
						    <sec:authorize access="hasAuthority('USER')">
						        <c:if test="${loginMemberNo == r.m_no}">
						            <a href="javascript:void(0);" onclick="deleteReview(${r.r_no}, ${dto.p_no})" 
						               style="color: #ff5a5f; font-size: 0.85em; text-decoration: none; border: 1px solid #ff5a5f; padding: 2px 10px; border-radius: 4px;">삭제</a>
						        </c:if>
						    </sec:authorize>
                       </div>
                   </div>
                   <p style="margin: 15px 0; color: #444; line-height: 1.6; text-align: left;">${r.r_review}</p>
                   <div class="review-image-list" style="display: flex; gap: 10px; overflow-x: auto; margin-top: 10px;">
                     <c:forEach items="${r.reviewImages}" var="img"><img src="/productreview/${img.i_savefile}" class="review-img" onclick="viewImage(this)"></c:forEach>
                   </div>
               </div>
           </c:forEach>

            <sec:authorize access="isAuthenticated()">
	            <div class="review-form-box">
	                <h3 style="text-align: left;">후기 작성하기</h3>
	                <form action="${pageContext.request.contextPath}/productReviewInsert" method="post" enctype="multipart/form-data">
	                    <input type="hidden" name="r_type" value="PRODUCT">
	                    <input type="hidden" name="r_typeno" value="${dto.p_no}">
	                    <input type="hidden" name="m_no" value="${loginMemberNo}"> 
	                    <div style="margin-bottom: 15px; text-align: left;">
	                        <label>평점 선택: </label>
	                        <select name="r_score" style="padding: 8px; border-radius: 5px;">
	                            <option value="5">★★★★★ (매우 만족)</option><option value="4">★★★★☆ (만족)</option><option value="3">★★★☆☆ (보통)</option><option value="2">★★☆☆☆ (불만족)</option><option value="1">★☆☆☆☆ (매우 불만족)</option>
	                        </select>
	                    </div>
	                    <textarea name="r_review" required style="width: 100%; height: 120px; padding: 15px; border-radius: 10px; border: 1px solid #ddd; resize: none;" placeholder="받으신 상품은 어떠했나요?"></textarea>
	                    <div style="margin-top: 15px; text-align: left;">
		                     <div style="flex-direction: column; display: flex; gap: 5px;">
		                         <label style="font-size: 0.8em; color: #666;">사진을 여러 장 선택할 수 있습니다.</label>
		                         <div id="preview-container"></div>
		                         <input type="file" name="uploadFiles" id="review-files" multiple accept="image/*">
		                     </div>
		                     <button type="submit" class="btn-primary" style="padding: 12px 30px; border-radius: 8px; font-weight: bold; margin-top: 10px;">리뷰 등록하기</button>
		                </div>
	                </form>
	            </div>
            </sec:authorize>
            
            <sec:authorize access="isAnonymous()">
		        <div class="review-form-box" style="text-align: center; padding: 40px;">
		            <p style="color: #666; font-size: 1.1em;">리뷰를 작성하려면 로그인이 필요합니다.</p>
		            <a href="${pageContext.request.contextPath}/mloginForm" style="color: #ff5a5f; font-weight: bold; text-decoration: underline;">로그인 페이지로 이동</a>
		        </div>
		    </sec:authorize>
        </div>
    </div>

    <div id="imageModal" style="display: none; position: fixed; z-index: 10000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.9); align-items: center; justify-content: center;">
        <span style="position: absolute; top: 20px; right: 30px; color: white; font-size: 40px; font-weight: bold; cursor: pointer; z-index: 10001;" onclick="closeModal()">&times;</span>
        <div id="prevBtn" style="position: absolute; left: 20px; color: white; font-size: 50px; cursor: pointer; user-select: none;">&#10094;</div>
        <img id="modalImg" style="max-width: 85%; max-height: 85%; border-radius: 5px; transition: 0.3s;">
        <div id="nextBtn" style="position: absolute; right: 20px; color: white; font-size: 50px; cursor: pointer; user-select: none;">&#10095;</div>
        <div id="imgIndex" style="position: absolute; bottom: 20px; color: white; font-size: 1.2em;"></div>
    </div>
	<button id="backToTop">▲</button>

<script>
	function pdelete(p_no) { if(confirm("정말 이 상품을 삭제하시겠습니까?")) { location.href = "/pdelete?p_no=" + p_no; } }
	function openTab(tabName) { $(".tab-content").removeClass("active").hide(); $(".tab-btn").removeClass("active"); $("#" + tabName).addClass("active").show(); $(event.currentTarget).addClass("active"); }
	
    const unitPrice = ${dto.p_price}; 
    const maxStock = ${dto.p_count}; 
    function changeQty(num) {
        const qtyInput = document.getElementById("order_qty");
        const currentQty = parseInt(qtyInput.value);
        const newQty = currentQty + num;
        
        // 사용자님이 강조하신 수량 체크 로직 (alert 포함)
        if (newQty < 1) return; 
        if (newQty > 5) { alert("최대 5개 가능합니다."); return; }
        if (newQty > maxStock) { alert("재고 부족"); return; }
        
        qtyInput.value = newQty;
        updateTotalPrice(newQty);
    }
    function updateTotalPrice(qty) { document.getElementById("total_amt").innerText = (unitPrice * qty).toLocaleString(); }
    function addCart() { const p_no = "${dto.p_no}"; const pc_count = document.getElementById("order_qty").value; if(confirm("장바구니에 담으시겠습니까?")) { location.href = "/cartinsert?p_no=" + p_no + "&pc_count=" + pc_count; } }
	
    var currentImgList = []; var currentIndex = 0;
	function viewImage(obj) {
	    var $imgList = $(obj).closest('.review-image-list').find('.review-img');
	    currentImgList = [];
	    $imgList.each(function(i, img) { currentImgList.push($(img).attr('src')); if($(img).attr('src') === $(obj).attr('src')) { currentIndex = i; } });
	    updateModal(); $('#imageModal').css('display', 'flex').show(); $('body').css('overflow', 'hidden');
	}
	function updateModal() { $('#modalImg').attr('src', currentImgList[currentIndex]); $('#imgIndex').text((currentIndex + 1) + " / " + currentImgList.length); if(currentImgList.length <= 1) { $('#prevBtn, #nextBtn').hide(); } else { $('#prevBtn, #nextBtn').show(); } }
	function closeModal() { $('#imageModal').hide(); $('body').css('overflow', 'auto'); }
    function deleteReview(r_no, p_no) { if(confirm("삭제하시겠습니까?")) { location.href = "${pageContext.request.contextPath}/productReviewDelete?r_no=" + r_no + "&p_no=" + p_no; } }
    
    $(document).ready(function() {
        $('#review-files').on('change', function(e) {
          const files = e.target.files; const previewContainer = $('#preview-container'); previewContainer.empty();
          if (files && files.length > 0) {
              Array.from(files).forEach(file => {
                  const reader = new FileReader();
                  reader.onload = function(event) {
                      const $img = $('<img>').attr({'src': event.target.result, 'style': 'width: 80px; height: 80px; object-fit: cover; border-radius: 5px; border: 1px solid #ddd;'});
                      previewContainer.append($('<div class="preview-item"></div>').append($img));
                  };
                  reader.readAsDataURL(file);
              });
          }
      });
        const topBtn = document.getElementById("backToTop");
        window.onscroll = function() { if (document.body.scrollTop > 200 || document.documentElement.scrollTop > 200) { topBtn.style.display = "block"; } else { topBtn.style.display = "none"; } };
        topBtn.onclick = function() { window.scrollTo({ top: 0, behavior: 'smooth' }); };
        $('#nextBtn').on('click', function(e) { e.stopPropagation(); currentIndex = (currentIndex + 1) % currentImgList.length; updateModal(); });
        $('#prevBtn').on('click', function(e) { e.stopPropagation(); currentIndex = (currentIndex - 1 + currentImgList.length) % currentImgList.length; updateModal(); });
        $('#imageModal').on('click', function(e) { if(e.target.id === 'imageModal') closeModal(); });
    });
</script>
<%@ include file="/WEB-INF/views/footer.jsp" %>
</body>
</html>