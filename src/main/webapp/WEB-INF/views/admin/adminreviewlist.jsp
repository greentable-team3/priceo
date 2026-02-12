<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>리뷰 전체 관리</title>
<style>
    body {
        background-color: #f1f5f9; /* 관리자 배경색 */
        font-family: 'Pretendard', -apple-system, sans-serif;
        margin: 0;
        padding: 0;
    }

    .admin-container {
        max-width: 1100px;
        margin: 60px auto; /* 상단 여백 확보 */
        background: #fff;
        padding: 40px;
        border-radius: 15px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.05);
    }

   .logo-area a {
        text-decoration: none;
        color: #00b894;
        font-weight: 800;
        font-size: 20px;
        letter-spacing: -1px;
    }
   
    h2 {
        color: #2d3436;
        font-size: 24px;
        margin-bottom: 30px;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    /* 테이블 스타일링 */
    .admin-table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 10px;
        font-size: 14px;
    }

    .admin-table thead th {
        background-color: #f9fbf9;
        color: #555;
        font-weight: 700;
        padding: 15px;
        border-bottom: 2px solid #00b894; /* 관리자 포인트 컬러 */
        text-align: center;
    }

    .admin-table tbody td {
        padding: 15px;
        border-bottom: 1px solid #edf2ef;
        text-align: center;
        vertical-align: middle;
        color: #666;
    }

    /* 내용(텍스트) 왼쪽 정렬 및 가독성 */
    .admin-table tbody td:nth-child(4) {
        text-align: center;
        color: #333;
        line-height: 1.4;
    }

    /* 별점 강조 */
    .score-badge {
        color: #ffb142; /* 별점은 따뜻한 주황색 */
        font-weight: bold;
    }

    /* 이미지 미리보기 */
    .review-img {
        width: 60px;
        height: 60px;
        object-fit: cover;
        border-radius: 8px;
        border: 1px solid #eee;
        transition: transform 0.2s;
    }

    .review-img:hover {
        transform: scale(1.1); /* 마우스 올리면 살짝 확대 */
    }

    /* 삭제 버튼 (기존 스타일 계승 및 세련화) */
    .btn-delete {
        background-color: #fff;
        color: #e74c3c;
        border: 1px solid #ffccd5;
        padding: 8px 16px;
        border-radius: 8px;
        font-size: 12px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s ease;
    }

    .btn-delete:hover {
        background-color: #ff7675;
        color: #fff;
        border-color: #ff7675;
        box-shadow: 0 4px 10px rgba(231, 76, 60, 0.2);
    }

    /* 행(Row) 호버 효과 */
    .admin-table tbody tr:hover {
        background-color: #fcfdfc;
    }
    /* 하단 목록 버튼 스타일 */
   .btn-list {
      background-color: #fff;
       color: #00b894;
       border: 1px solid #00b894;
       padding: 12px 30px;
       border-radius: 8px;
       font-size: 14px;
       font-weight: 600;
       cursor: pointer;
       transition: all 0.2s ease;
   }
   
    .btn-list:hover {
        background-color: #00b894;
        color: #fff;
    }
   
   /* 버튼 배치 정렬 */
   .btn-group {
       display: flex;
       justify-content: center;
       gap: 15px;
   }    
      
      

    .btn-page {
        padding: 8px 12px;
        border: 1px solid #ddd;
        text-decoration: none;
        color: #666;
        border-radius: 4px;
        font-size: 13px;
    }
    .btn-page.active {
        background-color: #00b894;
        color: white;
        border-color: #00b894;
        font-weight: bold;
    }
    .btn-page:hover:not(.active) {
        background-color: #f1f5f9;
    }   
 
</style>
</head>
<body>
<%@ include file="/WEB-INF/views/header.jsp" %>

   <div class="admin-container">
   <div class="logo-area">
       <a href="/adminhome">PRICEO ADMIN</a>
    </div>
    <h2>📝 전체 리뷰 관리</h2>
    <table class="admin-table">
        <thead>
            <tr>
                <th>번호</th>
                <th>게시물</th>
                <th>작성자</th>
                <th>내용</th>
                <th>별점</th>
                <th>관리</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="r" items="${rlist}">
                <tr>
                    <td>${r.r_no}</td>
                    <td>
                   <c:choose>
                       <%-- 상품(Product)인 경우 --%>
                       <c:when test="${r.r_type == 'PRODUCT'}">
                           <span style="font-weight: bold; color: #2c3e50;">
                               <a href="/pdetail?p_no=${r.r_typeno}" style="text-decoration: none; color: inherit;">
                                   상품 : ${r.r_typeno}
                               </a>
                           </span>
                       </c:when>
                       
                       <%-- 숙소(Stay)인 경우 --%>
                       <c:when test="${r.r_type == 'STAY'}">
                           <span style="font-weight: bold; color: #e67e22;">
                               <a href="/stayDetail?s_no=${r.r_typeno}" style="text-decoration: none; color: inherit;">
                                   숙소 : ${r.r_typeno}
                               </a>
                           </span>
                       </c:when>
                       
                       <%-- 기타 예외 케이스 --%>
                       <c:otherwise>
                           기타 : ${r.r_typeno}
                       </c:otherwise>
                   </c:choose>
               </td>
               
                    <td>${r.m_name}</td>
                    <td>
                      <c:choose>
                          <c:when test="${fn:length(r.r_review) > 20}">
                              <span title="${r.r_review}">${fn:substring(r.r_review, 0, 20)}...</span>
                          </c:when>
                          <c:otherwise>
                              ${r.r_review}
                          </c:otherwise>
                      </c:choose>
                  </td>

                    <td><span class="score-badge">${r.r_score}점</span></td>
                    <td>
                        <button type="button" class="btn-delete" onclick="deleteReview(${r.r_no})">삭제</button>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
   </table>
   <div class="pagination" style="margin-top: 30px; text-align: center; display: flex; justify-content: center; gap: 5px; align-items: center;">
    
       <%-- [처음으로] 버튼 (필요시) --%>
       <c:if test="${currentPage > 1}">
           <a href="?page=1" class="btn-page">«</a>
       </c:if>
   
       <%-- [이전 10개] 버튼: 현재 시작페이지가 1보다 크면 노출 --%>
       <c:if test="${startPage > 1}">
           <a href="?page=${startPage - 1}" class="btn-page">이전</a>
       </c:if>
   
       <%-- 페이지 번호: startPage부터 endPage까지만 출력 --%>
       <c:forEach var="i" begin="${startPage}" end="${endPage}">
           <a href="?page=${i}" class="btn-page ${i == currentPage ? 'active' : ''}">${i}</a>
       </c:forEach>
   
       <%-- [다음 10개] 버튼: 현재 끝페이지가 전체페이지보다 작으면 노출 --%>
       <c:if test="${endPage < totalPage}">
           <a href="?page=${endPage + 1}" class="btn-page">다음</a>
       </c:if>
   
       <%-- [맨끝으로] 버튼 (필요시) --%>
       <c:if test="${currentPage < totalPage}">
           <a href="?page=${totalPage}" class="btn-page">»</a>
       </c:if>
   </div>

   <div class="btn-group" style="margin-top: 30px; text-align: center;">
        <input type="button" value="관리자홈" class="btn-list" onclick="location.href='${pageContext.request.contextPath}/adminhome'">
    </div>
   </div>

   <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script> <script>
   function deleteReview(rno) {
       if(confirm("이 리뷰를 정말 삭제하시겠습니까?")) {
           $.ajax({
               url: "/deleteReview",
               type: "POST",
               data: { r_no: rno },
               success: function(res) {
                   if(res.trim() === "success") { // 공백 제거 후 비교
                       alert("리뷰가 삭제되었습니다.");
                       location.reload();
                   } else {
                       alert("삭제 실패: " + res);
                   }
               },
               error: function(xhr, status, error) {
                   alert("서버 통신 에러! (상태코드: " + xhr.status + ")");
               }
           }); 
       }
   }
   </script>
</body>
</html>