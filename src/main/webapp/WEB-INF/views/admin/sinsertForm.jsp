<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>숙소 등록</title>
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=972e1a44503376687f67fe5178b5145d&libraries=services"></script>
<script>
// 주소 검색 함수 (이건 head에 있어도 버튼 클릭 시 실행되므로 괜찮습니다)
function openAddrSearch() {
    new daum.Postcode({
        oncomplete: function(data) {
            var addr = data.address;
            document.getElementById("s_addr").value = addr;
            
            var geocoder = new kakao.maps.services.Geocoder();
            geocoder.addressSearch(addr, function(result, status) {
                if (status === kakao.maps.services.Status.OK) {
                    document.getElementById("s_lat").value = result[0].y;
                    document.getElementById("s_long").value = result[0].x;
                }
            });
        }
    }).open();
}
</script>
<style>
    body {
        background-color: #f1f5f9;
        font-family: 'Pretendard', -apple-system, sans-serif;
        margin: 0;
        padding: 0;
    }
	.logo-area a {
        text-decoration: none;
        color: #00b894;
        font-weight: 800;
        font-size: 20px;
        letter-spacing: -1px;
    }    

    .form-container {
        max-width: 800px;
        margin: 60px auto; /* 상단 간격 확보 */
        background: #fff;
        padding: 40px;
        border-radius: 15px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.05);
    }

    h2 {
        color: #2d3436;
        font-size: 24px;
        margin-bottom: 10px;
        text-align: center;
    }

    hr {
        border: 0;
        height: 2px;
        background: #00b894; /* 관리자 포인트 그린 */
        width: 50px;
        margin: 0 auto 30px;
    }

    /* 테이블 레이아웃 커스텀 */
    table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 30px;
    }

    th {
        width: 30%;
        text-align: left;
        padding: 15px;
        background-color: #f9fbf9;
        color: #555;
        font-size: 14px;
        border-bottom: 1px solid #edf2ef;
    }

    td {
        padding: 15px;
        border-bottom: 1px solid #edf2ef;
    }

    /* 입력창 스타일 */
    input[type="text"], input[type="file"] {
        width: 100%;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 6px;
        box-sizing: border-box;
        font-size: 14px;
        outline: none;
    }

    input[type="text"]:focus {
        border-color: #00b894;
    }

    /* 주소창 특수 조절 */
    #s_addr {
        width: calc(100% - 100px);
        margin-right: 5px;
    }

    /* 버튼 스타일 */
    input[type="button"], input[type="submit"], input[type="reset"] {
        padding: 10px 20px;
        border-radius: 6px;
        border: none;
        cursor: pointer;
        font-weight: 600;
        transition: 0.3s;
        font-size: 14px;
    }

    /* 하단 메인 버튼들 */
    .btn-group {
        text-align: center;
        display: flex;
        justify-content: center;
        gap: 10px;
    }

    input[type="submit"] {
        background-color: #00b894;
        color: white;
        padding: 12px 40px;
        font-size: 16px;
    }

    input[type="submit"]:hover {
        background-color: #009678;
    }

    input[type="reset"] {
        background-color: #eee;
        color: #666;
    }

    input[onclick*="adminhome"] {
        background-color: #fff;
        color: #00b894;
        border: 1px solid #00b894;
    }
    
    .btn-list:hover {
        background-color: #00b894;
        color: #fff;
    }

    /* 도움말 텍스트 */
    small {
        color: #888;
        display: block;
        margin-top: 5px;
    }
    
    /* 주소 입력창 영역을 한 줄로 배치 */
	.address-group {
	    display: flex; /* 가로로 나열 */
	    gap: 10px;    /* 창과 버튼 사이 간격 */
	    align-items: center;
	}
	
	#s_addr {
	    flex: 1; /* 입력창이 가능한 넓은 공간을 차지하도록 설정 */
	    min-width: 0; /* flex 안에서 깨짐 방지 */
	}
	
	/* 주소 검색 버튼 스타일 (크기 고정) */
	input[onclick="openAddrSearch()"] {
	    width: auto; /* 너비를 자동으로 조절 */
	    white-space: nowrap; /* 글자가 줄바꿈되지 않게 설정 */
	    padding: 10px 15px;
	    background-color: #333; /* 기존 검정색 유지 */
	    color: #fff;
	    flex-shrink: 0; /* 버튼 크기가 줄어들지 않도록 고정 */
	}
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/header.jsp" %>
<div class="form-container">
       	<div class="logo-area">
            <a href="/adminhome">PRICEO ADMIN</a>
        </div>
    <h2>숙소 등록</h2>
    <hr>

    <form action="${pageContext.request.contextPath}/stayInsert" method="post" enctype="multipart/form-data">
        <table>
            <tr>
                <th>숙소명</th>
                <td><input type="text" name="s_name" placeholder="숙소 이름을 입력하세요" required></td>
            </tr>
            <tr>
                <th>숙소 위치(주소)</th>
                <td>
                    <input type="text" name="s_addr" id="s_addr" readonly placeholder="주소 검색을 클릭하세요" required>
                    <input type="button" value="주소 검색" onclick="openAddrSearch()">
                </td>
            </tr>
            <tr>
                <th>위도 / 경도</th>
                <td>
                    <div style="display: flex; gap: 10px;">
                        <input type="text" name="s_lat" id="s_lat" readonly placeholder="위도" required>
                        <input type="text" name="s_long" id="s_long" readonly placeholder="경도" required>
                    </div>
                </td>
            </tr>
            <tr>
                <th>대표 이미지</th>
                <td>
                    <input type="file" name="imageFile" id="mainImage" required>
                    <div id="main-preview" style="margin-top:10px;"></div>
                </td>
            </tr>
            <tr>
                <th>상세정보 (이미지)</th>
                <td>
                    <input type="file" name="infoFiles" id="infoFiles" multiple required> 
                    <small>* 사진을 여러 장 선택할 수 있습니다 (Ctrl 또는 Shift 이용)</small>
                    <div id="preview-container" style="display: flex; flex-wrap: wrap; margin-top: 10px;"></div>
                </td>
            </tr>
        </table>
        
        <div class="btn-group">
            <input type="submit" value="숙소 등록">
            <input type="reset" value="다시 쓰기" onclick="document.getElementById('main-preview').innerHTML=''; document.getElementById('preview-container').innerHTML='';">
            <input type="button" value="관리자홈" class ="btn-list" onclick="location.href='${pageContext.request.contextPath}/adminhome'">
        </div>
    </form>
</div>
<script>
// 1. 상세 이미지 다중 미리보기
document.getElementById('infoFiles').onchange = function() {
    var files = this.files;
    var previewContainer = document.getElementById("preview-container");
    previewContainer.innerHTML = "";

    if (files.length > 0) {
        Array.from(files).forEach(function(file) {
            if (!file.type.match("image.*")) {
                alert("이미지 파일만 선택 가능합니다.");
                return;
            }
            var reader = new FileReader();
            reader.onload = function(e) {
                var img = document.createElement("img");
                img.src = e.target.result;
                img.style.width = "100px";
                img.style.height = "100px";
                img.style.margin = "5px";
                img.style.objectFit = "cover";
                img.style.border = "1px solid #ddd";
                img.style.borderRadius = "5px";
                previewContainer.appendChild(img);
            };
            reader.readAsDataURL(file);
        });
    }
};

// 2. 대표 이미지 단일 미리보기 추가
document.getElementById('mainImage').onchange = function() {
    var file = this.files[0];
    var mainPreview = document.getElementById("main-preview");
    mainPreview.innerHTML = "";

    if (file) {
        if (!file.type.match("image.*")) {
            alert("이미지 파일만 선택 가능합니다.");
            this.value = "";
            return;
        }
        var reader = new FileReader();
        reader.onload = function(e) {
            var img = document.createElement("img");
            img.src = e.target.result;
            img.style.width = "150px";
            img.style.border = "1px solid #ddd";
            mainPreview.appendChild(img);
        };
        reader.readAsDataURL(file);
    }
};
</script>

</body>
</html>