\<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>객실 정보 수정</title>
<style>
    table { width: 500px; border-collapse: collapse; margin: 20px 0; }
    th { background-color: #f9f9f9; padding: 10px; width: 120px; border: 1px solid #ddd; }
    td { padding: 10px; border: 1px solid #ddd; }
    input[type="text"], input[type="number"] { width: 90%; padding: 5px; }
    .btn-group { margin-top: 15px; }
    .info-text { color: #666; font-size: 0.9em; }
</style>
</head>
<body>

    <h2>객실(Room) 정보 수정</h2>
    <p class="info-text">* 객실의 명칭, 인원 및 가격 정보를 수정할 수 있습니다.</p>
    <hr>

    <form action="${pageContext.request.contextPath}/roomUpdate" method="post">
        <input type="hidden" name="sr_no" value="${dto.sr_no}">
        
        <input type="hidden" name="s_no" value="${dto.s_no}">

        <table>
            <tr>
                <th>객실 타입명</th>
                <td>
                    <input type="text" name="sr_name" value="${dto.sr_name}" required>
                </td>
            </tr>
            <tr>
                <th>기준 인원</th>
                <td>
                    <input type="number" name="sr_people" value="${dto.sr_people}" min="1" required> 명
                </td>
            </tr>
            <tr>
                <th>평일 가격</th>
                <td>
                    <input type="number" name="sr_lowprice" value="${dto.sr_lowprice}" step="1000" required> 원
                </td>
            </tr>
            <tr>
                <th>주말 가격</th>
                <td>
                    <input type="number" name="sr_highprice" value="${dto.sr_highprice}" step="1000" required> 원
                </td>
            </tr>
        </table>

        <div class="btn-group">
            <input type="submit" value="수정 완료" style="background-color: #2196F3; color: white; border: none; padding: 10px 20px; cursor: pointer; border-radius: 4px;">
            <input type="button" value="수정 취소" onclick="history.back()" style="padding: 10px 20px; cursor: pointer; border: 1px solid #ccc; border-radius: 4px; background: white;">
        </div>
    </form>

</body>
</html>