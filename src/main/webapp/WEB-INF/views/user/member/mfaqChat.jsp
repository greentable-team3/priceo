<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
/* 스타일은 형님 코드 그대로 보존 */
#faq-float-btn { position: fixed; right: 20px; bottom: 20px; width: 56px; height: 56px; border-radius: 50%; cursor: pointer; text-align: center; line-height: 56px; border: 1px solid #ccc; background: #fff; z-index: 9999; }
#faq-chat { position: fixed; right: 20px; bottom: 90px; width: 320px; height: 420px; border: 1px solid #ccc; background: #fff; display: none; z-index: 9999; }
#chat-header { background-color: #1e3a8a; color: white; padding: 10px 15px; display: flex; justify-content: space-between; align-items: center; width: 320px; box-sizing: border-box; border-top-left-radius: 5px; border-top-right-radius: 5px; position: absolute; top: 0; left: 0; }
#chat-body { height: 300px; overflow-y: auto; padding: 10px; margin-top: 45px; }
#chat-input { padding: 15px 10px; border-top: 1px solid #ddd; display: flex; gap: 8px; background: #f9f9f9; }
#question { flex: 1; height: 40px; padding: 0 12px; border: 1px solid #ccc; border-radius: 4px; outline: none; }
#chat-input button { width: 60px; height: 40px; background-color: #1e3a8a; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; }
</style>
</head>
<body>

<div id="faq-float-btn" onclick="toggleChat()">❓</div>

<div id="faq-chat">
    <div id="chat-header">
        <strong>FAQ 챗봇</strong>
        <button type="button" onclick="toggleChat()">X</button>
    </div>
    <div id="chat-body"></div>
    <div id="chat-input">
        <input type="text" id="question" placeholder="질문을 입력하세요" onkeydown="if(event.key==='Enter'){ask();}">
        <button type="button" onclick="ask()">전송</button>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
// 🥊 1. 변수 선언 (자동검색 관련 변수 제거)
let greeted = false;
let waitingMailConfirm = false;
let waitingProductConfirm = false;   
let lastQuestion = "";
let productSearchUrl = "";

// 🥊 2. 자동검색(Autocomplete) 로직 완전 제거
$(document).ready(function() {
    // 자동검색 관련 이벤트 리스너를 모두 삭제했습니다.
});

// 🥊 3. 챗봇 제어 함수들
function toggleChat() {
    const chat = document.getElementById("faq-chat");
    const body = document.getElementById("chat-body");
    const isOpen = (chat.style.display === "block");
    chat.style.display = isOpen ? "none" : "block";

    if (!isOpen && !greeted) {
        const greet = document.createElement("div");
        greet.innerHTML = `안녕하세요! 프라이스O입니다!<br>궁금한건 O!봇에게 키워드로 물어보세요!🤖<br>(예: 회원가입, 로그인 등)<hr>`;
        body.appendChild(greet);
        body.scrollTop = body.scrollHeight;
        greeted = true;
    }
}

function ask() {
    const qInput = document.getElementById("question");
    const q = qInput.value.trim();
    if (!q) return;
    const body = document.getElementById("chat-body");

    // 확인 모드 처리
    if (waitingProductConfirm) { handleConfirm(q, () => location.href = productSearchUrl); return; }
    if (waitingMailConfirm) { handleConfirm(q, sendMail); return; }

    lastQuestion = q;
    const qDiv = document.createElement("div");
    qDiv.innerHTML = "<b>Q.</b> " + q;
    body.appendChild(qDiv);

    fetch("/mfaq/ask", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: "question=" + encodeURIComponent(q)
    })
    .then(res => res.json())
    .then(data => {
        const aDiv = document.createElement("div");
        if (data.type === "REDIRECT") {
            aDiv.innerHTML = "<b>A.</b> " + (data.message || "찾으시는 페이지를 발견했습니다.") + 
                             "<br><br><a href='" + data.url + "' style='color:#1e3a8a; font-weight:bold;'>👉 바로가기 링크 이동</a>";
        } else if (data.type === "ANSWER") {
            aDiv.innerHTML = "<b>A.</b> " + data.message;
        } else if (data.type === "CONFIRM_PRODUCT") {
            waitingProductConfirm = true; productSearchUrl = data.searchUrl;
            aDiv.innerHTML = "<b>A.</b> 혹시 <b>" + data.productName + "</b>를 찾으시나요?<br><button onclick='goProductSearch(\"" + data.searchUrl + "\")'>예</button><button onclick='continueChat()'>아니오</button>";
        } else if (data.type === "CONFIRM_MAIL") {
            waitingMailConfirm = true;
            aDiv.innerHTML = "<b>A.</b> 담당자에게 문의 메일을 보내드릴까요?<br><br><button onclick='sendMail()'>예</button><button onclick='continueChat()'>아니오</button>";
        }
        body.appendChild(aDiv);
        body.scrollTop = body.scrollHeight;
    });
    qInput.value = "";
    qInput.focus();
}

function handleConfirm(q, successCallback) {
    const answer = q.toLowerCase();
    const yesWords = ["예","네","넵","ㅇㅇ","yes","y","ㅇ","응"];
    const noWords  = ["아니","아니요","아니오","no","n","ㄴㄴ","놉"];
    if (yesWords.some(w => answer.includes(w))) { 
        waitingProductConfirm = false; 
        waitingMailConfirm = false; 
        successCallback(); 
    }
    else if (noWords.some(w => answer.includes(w))) { 
        continueChat(); 
    }
    else { 
        showMessage("예 또는 아니오로 답변해 주세요 😊"); 
    }
    document.getElementById("question").value = "";
}

function goProductSearch(url) { if(url) location.href = url; }

function sendMail() {
    fetch("/mfaq/sendMail", { method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" }, body: "question=" + encodeURIComponent(lastQuestion) })
    .then(() => { 
        waitingMailConfirm = false;
        showMessage("문의 메일이 전달되었습니다 😊"); 
    });
}

function continueChat() { 
    waitingProductConfirm = false; 
    waitingMailConfirm = false;
    showMessage("알겠습니다. 다른 궁금한 점을 말씀해 주세요 🙂"); 
}

function showMessage(msg) {
    const body = document.getElementById("chat-body");
    const div = document.createElement("div");
    div.innerHTML = "<b>A.</b> " + msg;
    body.appendChild(div);
    body.scrollTop = body.scrollHeight;
}
</script>
</body>
</html>