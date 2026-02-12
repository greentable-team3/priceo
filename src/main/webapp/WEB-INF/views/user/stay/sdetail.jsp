<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>${dto.s_name} - 상세 정보</title>

<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=972e1a44503376687f67fe5178b5145d"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.js'></script>

<style>
    /* 1. 기본 레이아웃 및 전체 배경 */
    body { background-color: #f8f9fa; font-family: 'Pretendard', sans-serif; }
    
    .detail-container { 
        display: flex; max-width: 1200px; margin: 50px auto; gap: 50px; 
        padding: 40px; background: #fff; border-radius: 20px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.05); 
    }
    .left-side { flex: 1.2; }
    .right-side { flex: 0.8; position: relative; }

    /* 2. 이미지 및 타이틀 */
    .img-box { width: 100%; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.08); margin-bottom: 30px; object-fit: cover; }
    .hotel-name { font-size: 2.8em; font-weight: 800; color: #222; margin: 10px 0; letter-spacing: -1.5px; }
    .location-text { font-size: 1.1em; color: #666; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
    
    /* 지도보기 버튼 스타일 */
    .btn-open-map {
        padding: 8px 18px; border-radius: 20px; border: 1px solid #e0e0e0; 
        background: #1e3a8a; cursor: pointer; font-weight: bold; transition: 0.2s;
    }
    .btn-open-map:hover { background: #f8f9fa; border-color: #ccc; }

    /* 3. 우측 예약 영역 (Sticky 카드) */
    .sticky-box { 
        position: sticky; top: 20px; background: #fcfcfc; padding: 25px; 
        border: 1px solid #eee; border-radius: 20px; box-shadow: 0 8px 25px rgba(0,0,0,0.05); 
        max-height: calc(100vh - 40px); /* 화면 전체 높이에서 여백을 뺀 만큼만 차지 */
    	overflow-y: auto; /* 내용이 화면보다 길어지면 박스 내부에서 스크롤 발생 */
		/* 스크롤바 디자인 (선택 사항: 깔끔하게 보이기 위함) */
    	scrollbar-width: thin; 

    }
    
    .sticky-box::-webkit-scrollbar {
	    width: 6px;
	}
	.sticky-box::-webkit-scrollbar-thumb {
	    background-color: #ddd;
	    border-radius: 10px;
	}
    
    
    
    /* 달력 전체 컨테이너 크기 제한 */
	#calendar { 
	    max-width: 380px;  /* 원하는 너비로 조절 (예: 300px ~ 350px) */
	    margin: 15px auto 0 auto; /* 중앙 정렬 */
	    font-size: 0.75em; /* 전체적인 폰트 크기 축소 */
	    background: #fff; 
	    border-radius: 10px; 
	    overflow: hidden; 
	    padding: 5px; 
	}
	
	/* 달력 헤더(제목, 버튼) 크기 조절 */
	.fc .fc-toolbar-title {
	    font-size: 1.2em !important; /* '2026년 3월' 등의 타이틀 크기 */
	    font-weight: bold;
	}
	
	/* 날짜 셀 높이 조절 (가장 중요) */
	.fc .fc-daygrid-day-frame {
	    min-height: 10px !important; /* 셀의 최소 높이를 줄임 */
	}
	
	
	/* 요일 행 높이 조절 */
	.fc-col-header-cell-cushion {
	    padding: 1.5px 0 !important;
	}
	
	/* 가이드(범례) 영역도 달력 너비에 맞게 조절 */
	.calendar-guide {
		display: flex; 
		justify-content: center;
	    max-width: 320px;
	    margin: 10px auto;
	    gap: 10px;
	    font-size: 0.75em;
	    padding: 8px;
	    background: #f8f9fa;
	    border-radius: 8px; 
	    font-size: 0.85em; 
	    font-weight: bold;
	   
	}
     
    .fc-daygrid-day-top { display: flex; justify-content: center !important; }
    .fc-daygrid-day-number { float: none !important; padding: 1px !important; }
    

	/* 달력 기본 설정 */
	
	.fc-event { display: none !important; }
	.fc-daygrid-day.fc-day-other { visibility: hidden; }
	
	
	/* 예약 가능/불가 색상 */
	
	.is-available { background-color: #28a745 !important; color: white !important; cursor: pointer !important; }
	.is-booked { background-color: #ff4d4d !important; color: white !important; cursor: not-allowed !important; }
	
	
	
	/* 선택된 날짜 하이라이트 스타일 */
	
	.fc-highlight {
		background: #007bff !important;
		opacity: 1 !important;
		z-index: 5 !important;
	}
	
	
	
	/* 날짜 숫자가 파란색 배경 위로 올라오도록 설정 */
	
	.fc-daygrid-day-number {
	
	position: relative;
	
	z-index: 10 !important;
	
	color: white !important;
	
	text-shadow: 0px 0px 3px rgba(0,0,0,0.3);
	
	padding: 4px !important;
	
	}
	
	
	.guide-item { display: flex; align-items: center; gap: 5px; }
	
	.guide-box { width: 12px; height: 12px; border-radius: 2px; }
	
	
	#checkIn, #checkOut { font-weight: bold; color: #333; text-align: center; border: 1px solid #ddd; border-radius: 5px; padding: 5px; width: 100%; background: #f9f9f9; }


	#date-display { 
	    margin-top: 10px !important; /* 체크인/아웃 창 위쪽 간격 */
	    margin-bottom: 10px;        /* 가격 표시창과의 간격 */
	}
	
    /* 4. 입력창 및 가격 표시 */
	.price-info-area {
		margin-top: 0px; 
		margin-bottom: 10px;
		padding: 15px; 
		background: #fff5f5; 
		border: 1px solid #ff5a5f; 
		border-radius: 10px;
		text-align: right; 
		display: none;
	}

	.price-label { font-size: 0.85em; color: #666; }
	
	.price-value { font-size: 1.4em; font-weight: bold; color: #ff5a5f; margin-top: 2px; }



    /* 5. 예약하기 버튼 */
    .btn-reserve {
        width: 80%; padding: 10px; background: #0066ff; color: #fff;
        border: none; border-radius: 12px; font-size: 1.1em; font-weight: bold;
        cursor: pointer; transition: 0.3s; margin-top: 20px;
        box-shadow: 0 4px 15px rgba(0, 102, 255, 0.2);
    }
    .btn-reserve:hover { background: #0052cc; transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0, 102, 255, 0.3); }

    /* 6. 리뷰 영역 */
    .review-container { max-width: 1200px; margin: 60px auto; padding: 40px; border-top: 1px solid #eee; background: #fff; border-radius: 20px; }
    .review-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
    .review-card { padding: 30px 0; border-bottom: 1px solid #f8f8f8; }
    .review-img { width: 120px; height: 120px; border-radius: 12px; object-fit: cover; transition: 0.2s; }
    .review-img:hover { transform: scale(1.03); }
    .star-rating { color: #ff5a5f; font-weight: bold; }
    
    .review-form-box { background: #f8f9fa; padding: 40px; border-radius: 20px; margin-top: 40px; }
    
    /* 공통 버튼 베이스 */
	.btn-primary {
	    background-color: #1e3a8a !important; /* 사용자님이 원하시는 색상 */
	    color: #fff !important;
	    border: none;
	    cursor: pointer;
	    transition: 0.3s;
	}
    
    /* 리뷰 이미지 미리보기 컨테이너 스타일 추가 */
	#preview-container {
	    display: flex;       /* 가로 정렬 */
	    flex-wrap: wrap;    /* 공간 부족 시 다음 줄로 넘김 */
	    gap: 10px;          /* 이미지 사이 간격 */
	    margin-bottom: 10px;
	}
	
    
    
    /* 7. 스크롤 버튼 */
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
	
	/* 관리자 버튼 그룹 컨테이너 */
	.admin-btn-group {
	    margin-top: 15px;
	    display: flex;
	    gap: 10px; /* 버튼 사이 간격 살짝 넓힘 */
	    width: 100%; /* 부모 너비 전체 사용 */
	}
	
	/* 관리자 공통 버튼 베이스 (크기 균일화의 핵심) */
	.admin-btn-group input[type="button"] {
	    flex: 1; /* 세 버튼이 동일한 비율로 가로를 나눠 가짐 */
	    height: 48px; /* 높이를 고정하여 균일감 부여 */
	    border-radius: 8px;
	    font-size: 15px;
	    font-weight: 600;
	    cursor: pointer;
	    transition: all 0.2s ease;
	    padding: 0; /* flex 구조에서는 padding보다 height가 정확함 */
	    display: flex;
	    align-items: center;
	    justify-content: center;
	}
	
	/* 수정 & 객실추가 버튼 (원하시는 민트/청록 색감) */
	.btn-list {
	    background-color: #fff;
	    color: #00c4a7; /* 이미지 속의 그 민트색 */
	    border: 1px solid #00c4a7;
	}
	
	.btn-list:hover {
	    background-color: #00c4a7;
	    color: #fff;
	}
	
	/* 삭제 버튼 (레드) */
	.btn-red-delete {
	    background-color: #fff;
	    color: #ff5a5f;
	    border: 1px solid #ff5a5f;
	}
	
	.btn-red-delete:hover {
	    background-color: #ff5a5f;
	    color: #fff;
	}
	
	/* 클릭 시 살짝 작아지는 효과 */
	.admin-btn-group input[type="button"]:active {
	    transform: scale(0.97);
	}
	
	/* 목록버튼 그룹 컨테이너 */
	.user-btn-group {
	    margin-top: 7px;
	    display: flex; /* 버튼을 가로로 배치하기 위해 필요 */
	    width: 100%;   /* 부모의 너비를 전체 사용 */
	}
	
	/* 목록버튼 스타일 */
	.btn-secondary {
	    flex: 1;              /* 중요: 컨테이너 안의 남은 공간을 모두 차지하여 길게 늘어남 */
	    background-color: #1e3a8a !important;
	    color: #fff !important;
	    border: 1px solid #1e3a8a !important;
	    cursor: pointer;
	    height: 48px;         /* 관리자 버튼들과 높이를 맞추면 더 깔끔합니다 */
	    border-radius: 5px;   /* 인라인 스타일 대신 여기서 관리 가능 */
	    font-weight: 600;
	    transition: all 0.2s ease;
	}


    /* 8. 모달 */
    #mapModal { display: none; position: fixed; z-index: 10001; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.8); }
    .modal-content { background-color: white; margin: 5% auto; padding: 25px; width: 80%; height: 80%; position: relative; border-radius: 20px; }
    .close-btn { position: absolute; top: 15px; right: 25px; font-size: 35px; font-weight: bold; cursor: pointer; color: #333; }
</style>

</head>
<body>
<%@ include file="/WEB-INF/views/header.jsp" %>

<div class="detail-container">
    <div class="left-side">
        <img src="/stay/${dto.s_image}" class="img-box main-img">
        <div class="hotel-info-section">
            <p style="color: #717171; font-size: 0.9em; margin: 0;">숙소 · 호텔</p>
            <h1 class="hotel-name">${dto.s_name}</h1>
            <div class="location-text">
                <span>${dto.s_addr}</span>
                <button type="button" onclick="openMapModal()" style="padding: 6px 15px; border-radius: 20px; border: 1px solid #ddd; background: #fff; cursor: pointer; font-weight: bold;">지도보기</button>
            </div>
            <p style="color: #666; margin-top: 15px; line-height: 1.6;">
                편안하고 아늑한 휴식 공간, ${dto.s_name}에 오신 것을 환영합니다.
           </p>
            </div>
        <hr style="border: 0; height: 1.5px; background: #333; margin: 40px 0;">
        <div class="sub-img-list">
            <c:forEach items="${imageList}" var="img">
                <img src="/stay/${img.i_savefile}" class="img-box">
            </c:forEach>
        </div>
    </div>

    <div class="right-side">
        <div class="sticky-box">
            <h2 style="margin-top: 0;">객실 예약</h2>
            <p style="color: gray; font-size: 0.9em;">날짜를 선택하여 예약을 진행하세요.</p>
            <hr>
            <div class="room-selector">
                <label><strong>객실 선택</strong></label>
                <select id="roomSelect" style="width: 100%; padding: 12px; margin-top: 10px; border-radius: 5px; border: 1px solid #ccc;">
                    <option value="">=== 객실을 선택해주세요 ===</option>
                    <c:forEach items="${roomList}" var="room">
                        <option value="${room.sr_no}" 
                                data-low="${room.sr_lowprice}" 
                                data-high="${room.sr_highprice}">
                            ${room.sr_name} (기준 ${room.sr_people}인)
                        </option>
                    </c:forEach>
                </select>
            </div>
            
            <sec:authorize access="hasAuthority('ADMIN')">
			    <div style="margin-top: 15px; background: #fdfdfd; border: 1px solid #eee; border-radius: 8px; padding: 10px;">
			        <p style="font-size: 0.85em; font-weight: bold; color: #333; margin-bottom: 8px;">🛠 객실 개별 관리</p>
			        <c:forEach items="${roomList}" var="room">
			            <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.8em; padding: 4px 0; border-bottom: 1px var(--gray) solid;">
			                <span>${room.sr_name}</span>
			                <a href="javascript:void(0);" onclick="delRoom(${room.sr_no}, ${dto.s_no})" 
			                   style="color: #ff5a5f; text-decoration: none; border: 1px solid #ff5a5f; padding: 2px 5px; border-radius: 3px;">삭제</a>
			            </div>
			        </c:forEach>
			    </div>
			</sec:authorize>
            <div id="calendar-area" style="display:none;">
                <div id="calendar"></div>
                <div class="calendar-guide">
                    <div class="guide-item"><div class="guide-box" style="background-color: #28a745;"></div><span>예약가능</span></div>
                    <div class="guide-item"><div class="guide-box" style="background-color: #ff4d4d;"></div><span>예약불가</span></div>
                    <div class="guide-item"><div class="guide-box" style="background-color: #007bff;"></div><span>선택됨</span></div>
                </div>
                <div id="date-display" style="margin-top: 10px; display: flex; gap: 10px;">
                    <div style="flex: 1;"><label style="font-size: 0.8em; color: gray;">체크인</label><input type="text" id="checkIn" readonly></div>
                    <div style="flex: 1;"><label style="font-size: 0.8em; color: gray;">체크아웃</label><input type="text" id="checkOut" readonly></div>
                </div>

                <div id="price-display-area" class="price-info-area">
                    <div id="price-tag-name" class="price-label">안내</div>
                    <div class="price-value"><span id="calculated-price">0</span>원</div>
                </div>

                <div>
                    <button type="button" onclick="goReservation()" style="width: 100%; padding: 15px; background: #ff5a5f; color: #fff; border: none; border-radius: 8px; font-size: 1.1em; font-weight: bold; cursor: pointer;">예약하러 가기</button>
                </div>
            </div>

            <sec:authorize access="hasAuthority('ADMIN')">
				 <div class="admin-btn-group">
				    <input type="button" value="수정" class="btn-list" 
				           onclick="location.href='${pageContext.request.contextPath}/stayUpdateForm?s_no=${dto.s_no}'">
				    <input type="button" value="객실추가" class="btn-list" 
				           onclick="location.href='${pageContext.request.contextPath}/roomInsertForm?s_no=${dto.s_no}'">
				    <input type="button" value="삭제" class="btn-red-delete" 
				           onclick="delStay()">
				</div> 
            </sec:authorize>
            <div class="user-btn-group">
				<button onclick="location.href='/'" class="btn-secondary" style="padding: 10px 25px; border-radius: 5px;">목록</button>
			</div>
        </div>
    </div>
</div>
<div id="mapModal"><div class="modal-content"><span class="close-btn" onclick="closeMapModal()">&times;</span><h3 style="text-align:center;">위치 확인</h3><div id="modalMap" style="width:100%; height:80%;"></div></div></div>

<script>
    var calendar = null;
    var checkInDate = null;
    var checkOutDate = null;
    const holidays = ["2026-03-01"];

    var currentImgList = [];
    var currentIndex = 0;

    function viewImage(obj) {
        var $imgList = $(obj).closest('.review-image-list').find('.review-img');
        currentImgList = [];
        $imgList.each(function(i, img) {
            currentImgList.push($(img).attr('src'));
            if($(img).attr('src') === $(obj).attr('src')) { currentIndex = i; }
        });
        updateModal();
        $('#imageModal').css('display', 'flex').show();
        $('body').css('overflow', 'hidden');
    }

    function updateModal() {
        $('#modalImg').attr('src', currentImgList[currentIndex]);
        $('#imgIndex').text((currentIndex + 1) + " / " + currentImgList.length);
        if(currentImgList.length <= 1) { $('#prevBtn, #nextBtn').hide(); } 
        else { $('#prevBtn, #nextBtn').show(); }
    }

    function closeModal() { $('#imageModal').hide(); $('body').css('overflow', 'auto'); }

    function delStay() { if(confirm('모든 정보가 삭제됩니다. 계속하시겠습니까?')) { location.href='${pageContext.request.contextPath}/stayDelete?s_no=${dto.s_no}'; } }

    function updatePriceDisplay(dateStr) {
        var selectedRoom = $('#roomSelect option:selected');
        var lowPrice = parseInt(selectedRoom.data('low'));
        var highPrice = parseInt(selectedRoom.data('high'));
        var date = new Date(dateStr);
        var day = date.getDay(); 
        var isHoliday = holidays.includes(dateStr);
        var finalPrice = (day === 5 || day === 6 || isHoliday) ? highPrice : lowPrice;
        var tagName = isHoliday ? "공휴일 요금 적용" : (day === 5 || day === 6 ? "주말 요금 적용" : "평일 요금 적용");
        $('#calculated-price').text(finalPrice.toLocaleString());
        $('#price-tag-name').text(tagName);
        $('#price-display-area').show();
    }

    function goReservation() {
        var sr_no = $('#roomSelect').val();
        var inD = $('#checkIn').val();
        var outD = $('#checkOut').val();
        var finalPrice = $('#calculated-price').text().replace(/,/g, ''); 
        if(!sr_no) { alert("객실을 선택해주세요."); return; }
        if(!inD || !outD) { alert("날짜를 선택해주세요."); return; }
        location.href = "${pageContext.request.contextPath}/reservationForm?sr_no=" + sr_no + "&checkIn=" + inD + "&checkOut=" + outD + "&totalSum=" + finalPrice;
    }
    
 	// 객실 개별 삭제 함수
    function delRoom(sr_no, s_no) {
        if(confirm('이 객실을 삭제하시겠습니까? 관련 예약 달력 데이터도 모두 삭제됩니다.')) {
            location.href = '${pageContext.request.contextPath}/roomDelete?sr_no=' + sr_no + '&s_no=' + s_no;
        }
    }

    var map = null;
    function openMapModal() {
        document.getElementById('mapModal').style.display = "block";
        var mapContainer = document.getElementById('modalMap'); 
        var mapOption = { center: new kakao.maps.LatLng(${dto.s_lat}, ${dto.s_long}), level: 3 };
        if(map === null) {
            map = new kakao.maps.Map(mapContainer, mapOption); 
            new kakao.maps.Marker({ position: new kakao.maps.LatLng(${dto.s_lat}, ${dto.s_long}) }).setMap(map);
        } else {
            setTimeout(function(){ map.relayout(); map.setCenter(new kakao.maps.LatLng(${dto.s_lat}, ${dto.s_long})); }, 100);
        }
    }
    function closeMapModal() { document.getElementById('mapModal').style.display = "none"; }

    function deleteReview(r_no, s_no) {
        if(confirm("이 리뷰를 삭제하시겠습니까?")) {
            location.href = "${pageContext.request.contextPath}/stayReviewDelete?r_no=" + r_no + "&s_no=" + s_no;
        }
    }

    $(document).ready(function() {
        $('#review-files').on('change', function(e) {
		    const files = e.target.files;
		    const previewContainer = $('#preview-container');
		    previewContainer.empty();
		    if (files && files.length > 0) {
		        Array.from(files).forEach(file => {
		            if (!file.type.match("image.*")) return;
		            const reader = new FileReader();
		            reader.onload = function(event) {
		                const $imgDiv = $('<div class="preview-item"></div>');
		                const $img = $('<img>').attr({
		                    'src': event.target.result,
		                    'style': 'width: 80px; height: 80px; object-fit: cover; border-radius: 5px; border: 1px solid #ddd;'
		                });
		                $imgDiv.append($img);
		                previewContainer.append($imgDiv);
		            };
		            reader.readAsDataURL(file);
		        });
		    }
		});

        $('#roomSelect').on('change', function() {
            var sr_no = $(this).val();
            if(!sr_no) { $('#calendar-area').hide(); return; }
            $('#calendar-area').show();
            $.ajax({
                url: '${pageContext.request.contextPath}/api/calendar/list',
                data: { sr_no: sr_no, startDate: '2026-03-01', endDate: '2026-03-31' },
                success: function(bookingData) {
                    if (calendar) calendar.destroy();
                    var calendarEl = document.getElementById('calendar');
                    calendar = new FullCalendar.Calendar(calendarEl, {
                        initialView: 'dayGridMonth',
                        initialDate: '2026-03-01',
                        locale: 'ko',
                        headerToolbar: { left: '', center: 'title', right: '' },
                        height: 'auto',
                        selectable: true,
                        unselectAuto: false, 
                        showNonCurrentDates: false, 
                        fixedWeekCount: false,
                        dayCellDidMount: function(info) {
                            var dateStr = info.date.getFullYear() + "-" + ("0" + (info.date.getMonth() + 1)).slice(-2) + "-" + ("0" + info.date.getDate()).slice(-2);
                            info.el.classList.add('is-available');
                            var isBooked = bookingData.some(function(d) { return d.start === dateStr && d.title === '예약불가'; });
                            if (isBooked) { info.el.classList.remove('is-available'); info.el.classList.add('is-booked'); }
                        },
                        dateClick: function(info) {
                            if (info.dayEl.classList.contains('is-booked')) { alert("이미 예약된 날짜입니다."); return; }
                            checkInDate = info.dateStr;
                            var dateObj = new Date(info.date);
                            dateObj.setDate(dateObj.getDate() + 1);
                            checkOutDate = dateObj.getFullYear() + "-" + ("0" + (dateObj.getMonth() + 1)).slice(-2) + "-" + ("0" + dateObj.getDate()).slice(-2);
                            $('#checkIn').val(checkInDate);
                            $('#checkOut').val(checkOutDate);
                            var hEnd = new Date(info.date);
                            hEnd.setDate(hEnd.getDate() + 2);
                            calendar.select(checkInDate, hEnd.getFullYear() + "-" + ("0" + (hEnd.getMonth() + 1)).slice(-2) + "-" + ("0" + hEnd.getDate()).slice(-2));
                            updatePriceDisplay(checkInDate);
                        }
                    });
                    calendar.render();
                }
            });
        });

        const topBtn = document.getElementById("backToTop");
        window.onscroll = function() { if (document.body.scrollTop > 200 || document.documentElement.scrollTop > 200) { topBtn.style.display = "block"; } else { topBtn.style.display = "none"; } };
        topBtn.onclick = function() { window.scrollTo({ top: 0, behavior: 'smooth' }); };
    });
</script>

<div class="review-container">
    <div class="review-header">
        <h2>실제 투숙객 후기 <span style="color:#ff5a5f;">${reviewList.size()}</span></h2>
        <div class="star-rating" style="font-size: 1.5em;">
            ★ <fmt:formatNumber value="${avgScore}" pattern="0.0"/> / 5.0
        </div>
    </div>

    <c:forEach items="${reviewList}" var="r">
	    <div class="review-card">
	        <div style="display: flex; justify-content: space-between; align-items: center;">
	            <div>
	                <strong>${r.m_nickname}</strong>
	                <span class="star-rating" style="margin-left:10px;">
	                    <c:forEach begin="1" end="${r.r_score}">★</c:forEach>
	                </span>
	            </div>
                
                <sec:authorize access="hasAuthority('ADMIN')">
				    <a href="javascript:void(0);" onclick="deleteReview(${r.r_no}, ${dto.s_no})" 
				       style="color: #ff5a5f; font-size: 0.85em; text-decoration: none; border: 1px solid #ff5a5f; padding: 2px 8px; border-radius: 4px; margin-left:10px;">삭제</a>
				</sec:authorize>
				
				<sec:authorize access="hasAuthority('USER')">
				    <c:if test="${loginMemberNo == r.m_no}">
				        <a href="javascript:void(0);" onclick="deleteReview(${r.r_no}, ${dto.s_no})" 
				           style="color: #ff5a5f; font-size: 0.85em; text-decoration: none; border: 1px solid #ff5a5f; padding: 2px 8px; border-radius: 4px; margin-left:10px;">삭제</a>
				    </c:if>
				</sec:authorize>
	        </div>
	        <p style="margin: 15px 0; color: #444; line-height: 1.6;">${r.r_review}</p>
	        <div class="review-image-list" style="display: flex; gap: 10px; overflow-x: auto; margin-top: 10px;">
			    <c:forEach items="${r.reviewImages}" var="img">
			        <img src="/stayreview/${img.i_savefile}" class="review-img" onclick="viewImage(this)">
			    </c:forEach>
			</div>
	    </div>
	</c:forEach>

    <c:if test="${empty reviewList}">
        <p style="text-align: center; color: #999; padding: 50px 0;">작성된 리뷰가 없습니다. 첫 번째 후기를 남겨보세요!</p>
    </c:if>

    <sec:authorize access="isAuthenticated()">
	    <div class="review-form-box">
	        <h3>후기 작성하기</h3>
	        <form action="${pageContext.request.contextPath}/stayReviewInsert" method="post" enctype="multipart/form-data">
	            <input type="hidden" name="r_type" value="STAY">
	            <input type="hidden" name="r_typeno" value="${dto.s_no}">
	            <input type="hidden" name="m_no" value="${loginMemberNo}">
	            
	            <div style="margin-bottom: 15px;">
	                <label>평점 선택: </label>
	                <select name="r_score" style="padding: 8px; border-radius: 5px;">
	                    <option value="5">★★★★★ (매우 만족)</option>
	                    <option value="4">★★★★☆ (참 좋음)</option>
	                    <option value="3">★★★☆☆ (보통)</option>
	                    <option value="2">★★☆☆☆ (아쉬움)</option>
	                    <option value="1">★☆☆☆☆ (별로임)</option>
	                </select>
	            </div>
	            <textarea name="r_review" required style="width: 100%; height: 120px; padding: 15px; border-radius: 10px; border: 1px solid #ddd; resize: none;" placeholder="투숙하신 방의 청결도나 서비스는 어떠셨나요?"></textarea>
	            <div style="margin-top: 15px;">
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

<button id="backToTop">▲</button>

<div id="imageModal" style="display: none; position: fixed; z-index: 10000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.9); align-items: center; justify-content: center;">
    <span style="position: absolute; top: 20px; right: 30px; color: white; font-size: 40px; font-weight: bold; cursor: pointer; z-index: 10001;" onclick="closeModal()">&times;</span>
    <div id="prevBtn" style="position: absolute; left: 20px; color: white; font-size: 50px; cursor: pointer; user-select: none;" onclick="currentIndex = (currentIndex > 0) ? currentIndex - 1 : currentImgList.length - 1; updateModal();">&#10094;</div>
    <img id="modalImg" style="max-width: 85%; max-height: 85%; border-radius: 5px; transition: 0.3s;">
    <div id="nextBtn" style="position: absolute; right: 20px; color: white; font-size: 50px; cursor: pointer; user-select: none;" onclick="currentIndex = (currentIndex < currentImgList.length - 1) ? currentIndex + 1 : 0; updateModal();">&#10095;</div>
    <div id="imgIndex" style="position: absolute; bottom: 20px; color: white; font-size: 1.2em;"></div>
</div>
<%@ include file="/WEB-INF/views/footer.jsp" %>
</body>
</html>