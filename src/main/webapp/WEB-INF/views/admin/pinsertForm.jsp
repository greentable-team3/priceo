<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<!DOCTYPE html>
<html>
<head>
<!-- ================= PUSH (절대 건들지 말 것) ================= -->
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="/js/Push.js"></script>
<meta charset="UTF-8">
<title>상품 등록 시스템</title>
<style>
    body {
        background-color: #f1f5f9; /* 관리자 배경색 */
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
        max-width: 800px; /* 숙소 등록 폼과 동일한 너비 */
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

    /* 테이블 레이아웃 (숙소 등록과 통일) */
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
    input[type="text"], input[type="number"], input[type="file"] {
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

    /* 라디오 버튼 그룹 */
    .radio-group {
        display: flex;
        gap: 20px;
    }

    .radio-group label {
        display: flex;
        align-items: center;
        gap: 5px;
        font-size: 14px;
        cursor: pointer;
    }

    /* 하단 버튼 그룹 */
    .btn-group {
        text-align: center;
        display: flex;
        justify-content: center;
        gap: 10px;
    }
    
    
    /* 버튼 스타일 */
    input[type="button"] {
        padding: 10px 20px;
        border-radius: 6px;
        border: none;
        cursor: pointer;
        font-weight: 600;
        transition: 0.3s;
        font-size: 14px;
    }
    
    input[onclick*="adminhome"] {
        background-color: #fff;
        color: #00b894;
        border: 1px solid #00b894;
    }
    
    .submit-btn {
        background-color: #00b894;
        color: white;
        padding: 12px 40px;
        font-size: 16px;
        border: none;
        border-radius: 6px;
        font-weight: 600;
        cursor: pointer;
        transition: 0.3s;
    }

    .submit-btn:hover {
        background-color: #009678;
    }

    .reset-btn {
        background-color: #eee;
        color: #666;
        padding: 12px 25px;
        border: none;
        border-radius: 6px;
        cursor: pointer;
    }
    .btn-list:hover {
        background-color: #00b894;
        color: #fff;
    }

    /* 이미지 미리보기 스타일 */
    #main-preview img, #preview-container img {
        border: 1px solid #ddd;
        border-radius: 5px;
        margin-top: 10px;
    }
</style>

<script>
    function check(){
        let p = document.product;
        let Expprice=/^[0-9]*$/;
        
        if(!p.p_category.value){ alert("카테고리를 선택해주세요."); return false; }
        if(!p.p_name.value){ alert("상품명을 입력해주세요."); p.p_name.focus(); return false; }
        if(!p.p_price.value || !Expprice.test(p.p_price.value)){ alert("가격을 숫자로 입력해주세요."); p.p_price.focus(); return false; }
        if(!p.p_count.value || !Expprice.test(p.p_count.value)){ alert("재고수량을 숫자로 입력해주세요."); p.p_count.focus(); return false; }
        if(!p.p_imagefilename.value){ alert("대표 이미지를 삽입해주세요."); return false; }
        if(!p.p_infofilename.value){ alert("상세정보 이미지를 삽입해주세요."); return false; }

        p.submit();
    }
</script>
</head>
<body>
<%@ include file="/WEB-INF/views/header.jsp" %>
    <div class="form-container">
       	<div class="logo-area">
            <a href="/adminhome">PRICEO ADMIN</a>
        </div>
        <h2>상품 등록</h2>
        <hr>

        <form name="product" action="/pinsert" method="post" enctype="multipart/form-data">
            <table>
                <tr>
                    <th>카테고리</th>
                    <td>
                        <div class="radio-group">
                            <label><input type="radio" name="p_category" value="푸드"> 푸드</label>
                            <label><input type="radio" name="p_category" value="뷰티"> 뷰티</label>
                            <label><input type="radio" name="p_category" value="전자기기"> 전자기기</label>
                        </div>
                    </td>
                </tr>
                <tr>
                    <th>상품명</th>
                    <td><input type="text" id="p_name" name="p_name" placeholder="상품 이름을 입력하세요"></td>
                </tr>
                <tr>
                    <th>판매 가격 (₩)</th>
                    <td><input type="text" id="p_price" name="p_price" placeholder="숫자만 입력"></td>
                </tr>
                <tr>
                    <th>재고 수량</th>
                    <td><input type="text" id="p_count" name="p_count" placeholder="숫자만 입력"></td>
                </tr>
                <tr>
                    <th>대표 상품 이미지</th>
                    <td>
                        <input type="file" id="p_imagefilename" name="p_imagefilename" accept="image/*">
                        <div id="main-preview"></div>
                    </td>
                </tr>
                <tr>
                    <th>상세정보 이미지</th>
                    <td>
                        <input type="file" id="p_infofilename" name="p_infofilename" accept="image/*" multiple>
                        <br><small style="color: #888;">* 다중 선택 가능 (Ctrl 이용)</small>
                        <div id="preview-container" style="display: flex; flex-wrap: wrap; gap: 10px;"></div>
                    </td>
                </tr>
            </table>
            
            <div class="btn-group">
                <button type="button" class="submit-btn" onclick="check()">상품 등록하기</button>
                <button type="reset" class="reset-btn" onclick="document.getElementById('main-preview').innerHTML=''; document.getElementById('preview-container').innerHTML='';">다시 쓰기</button>
                <input type="button" value="관리자홈" class ="btn-list" onclick="location.href='${pageContext.request.contextPath}/adminhome'">
            </div>
        </form>
    </div>
    <script>
    // 기존 스크립트 기능 유지
    document.getElementById('p_infofilename').onchange = function() {
        var files = this.files;
        var previewContainer = document.getElementById("preview-container");
        previewContainer.innerHTML = "";

        Array.from(files).forEach(function(file) {
            if (!file.type.match("image.*")) return;
            var reader = new FileReader();
            reader.onload = function(e) {
                var img = document.createElement("img");
                img.src = e.target.result;
                img.style.width = "80px";
                img.style.height = "80px";
                img.style.objectFit = "cover";
                previewContainer.appendChild(img);
            };
            reader.readAsDataURL(file);
        });
    };

    document.getElementById('p_imagefilename').onchange = function() {
        var file = this.files[0];
        var mainPreview = document.getElementById("main-preview");
        mainPreview.innerHTML = "";

        if (file && file.type.match("image.*")) {
            var reader = new FileReader();
            reader.onload = function(e) {
                var img = document.createElement("img");
                img.src = e.target.result;
                img.style.width = "100%";
                img.style.maxWidth = "200px";
                mainPreview.appendChild(img);
            };
            reader.readAsDataURL(file);
        }
    };
    </script>
</body>
</html>