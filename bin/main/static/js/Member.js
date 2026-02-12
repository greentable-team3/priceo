let isIdChecked = false; // 아이디 중복검사 여부는 기본적으로 false로 설정해서 중복검사 버튼을 눌러보고 사용 가능해야만 checkId()와 check() 통과되게 설정
var isEmailChecked = false; // 이메일 인증 여부는 기본적으로 false, 인증이 안 되면 회원 가입불가


// =======================
// 회원가입용 메일 발송
// =======================
function sendJoinEmail() {
    let email = $('#m_email').val();
    if (!email) { alert("이메일을 입력해주세요."); return; }

    $.ajax({
        url: '/mailCheck',
        type: 'post',
        data: {
            m_email: email,
            type: 'join'
        },
        success: function(data) {
            alert("인증번호가 발송되었습니다!");
            $('#auth-section').show();
        },
        error: function() {
            alert("발송 실패. 서버 상태를 확인하세요.");
        }
    });
}


// =======================
// 비밀번호 재설정용 메일 발송
// =======================
function sendFindPwEmail() {
    let email = $('#m_email').val();
    let id = $('#m_id').val();

    if (!id) { alert("아이디를 입력해주세요."); return; }
    if (!email) { alert("이메일을 입력해주세요."); return; }

    $.ajax({
        url: '/findPwAuth',
        type: 'post',
        data: {
            m_email: email,
            m_id: id,
            type: 'reset'
        },
        success: function(data) {
            if (data.trim() === "success") {
                alert("인증번호가 발송되었습니다!");
                $('#auth-section').show();
            } else {
                alert("아이디 또는 이메일 정보가 일치하지 않습니다.");
            }
        },
        error: function() {
            alert("발송 실패. 서버 상태를 확인하세요.");
        }
    });
}


// =======================
// 인증번호 확인
// =======================
function verifyEmailCode() {
    let code = $('#auth_code').val();

    $.ajax({
        url: '/verifyCode',
        type: 'post',
        data: { code: code },
        success: function(isMatch) {
            if (isMatch) {
                alert("인증 성공!");
                $('#auth-msg').text("인증 성공!").css("color", "blue");
                $('#m_email').attr("readonly", true);
                $('#verify-btn').attr("disabled", true);
                $('#send-btn').attr("disabled", true);

                isEmailChecked = true;

                // 비밀번호 재설정이라면
                if ($('#password-reset-section').length) {
                    $('#password-reset-section').show();
                    $('#password-reset-confirm-section').show();
                }
            } else {
                alert("인증번호가 틀렸습니다.");
                $('#auth-msg').text("인증번호가 틀렸습니다.").css("color", "red");
            }
        }
    });
}


// =======================
// 비밀번호 변경
// =======================
function changePassword() {
    let pw = $('#new_pw').val();
    let pw2 = $('#new_pw2').val();

    if (!pw || pw.length < 8) {
        alert("새 비밀번호를 8자리 이상 입력해주세요.");
        return;
    }

    if (pw !== pw2) {
        alert("비밀번호가 일치하지 않습니다.");
        return;
    }

    $.ajax({
        url: '/updatePassword',
        type: 'post',
        data: { m_passwd: pw },
        success: function(result) {
            if (result === "success") {
                alert("비밀번호가 성공적으로 변경되었습니다.");
                location.href = "/mloginForm";
            } else {
                alert("변경 실패. 세션이 만료되었을 수 있습니다.");
            }
        },
        error: function() {
            alert("서버 통신 오류가 발생했습니다.");
        }
    });
}


// =======================
// 주소 검색 (Daum API)
// =======================
function execDaumPostcode() {
    new daum.Postcode({
        oncomplete: function(data) {
            document.getElementById('postcode').value = data.zonecode;
            document.getElementById('roadAddress').value = data.roadAddress;
            document.getElementById('detailAddress').focus();
        }
    }).open();
}


// =======================
// 아이디 중복 검사
// =======================
function checkId() {
    const id = document.getElementById("m_id").value;
    const msg = document.getElementById("idMsg");

    if (!id) {
        msg.textContent = "";
        return;
    }

    // 🥊 Context Path를 자동으로 붙여주는 JQuery 방식으로 변경하거나 절대 경로 확인!
    // 배포 환경에서도 안전하게 `${pageContext.request.contextPath}`를 붙여주는 게 최고입니다.
    const url = "${pageContext.request.contextPath}/idCheck?m_id=" + encodeURIComponent(id);

    fetch(url)
        .then(res => res.text())
        .then(result => {
            const cleanResult = result.trim();
            if (cleanResult === "DUPLICATE") {
                msg.textContent = "이미 사용 중인 아이디입니다.";
                msg.style.color = "red";
                isIdChecked = false;
            } else {
                msg.textContent = "사용 가능한 아이디입니다.";
                msg.style.color = "green";
                isIdChecked = true;
            }
        })
        .catch(err => {
            console.error("중복검사 오류:", err);
            alert("서버와 통신할 수 없습니다.");
        });
}


// =======================
// 비밀번호 일치 확인
// =======================
function checkpasswd() {
    let passwd = document.msignup.m_passwd.value;
    let passwd2 = document.msignup.m_passwd2.value;
    let msg = document.getElementById("pwMsg");

    if (!passwd || !passwd2) {
        msg.textContent = "";
        return false;
    }

    if (passwd !== passwd2) {
        msg.textContent = "비밀번호가 일치하지 않습니다.";
        msg.style.color = "red";
        return false;
    }

    msg.textContent = "비밀번호가 일치합니다.";
    msg.style.color = "green";
    return true;
}


// =======================
// 연락처 자동 하이픈 처리
// =======================
function formatPhone(input) {
    let numbers = input.value.replace(/\D/g, "");

    if (numbers.length > 11) {
        numbers = numbers.slice(0, 11);
    }

    let formatted = "";

    if (numbers.length <= 3) {
        formatted = numbers;
    } else if (numbers.length <= 7) {
        formatted = numbers.slice(0, 3) + "-" + numbers.slice(3);
    } else {
        formatted =
            numbers.slice(0, 3) +
            "-" +
            numbers.slice(3, 7) +
            "-" +
            numbers.slice(7);
    }

    input.value = formatted;
    document.msignup.m_tel.value = formatted;
}


// =======================
// 최종 회원가입 체크
// =======================
function check() {
    let id = document.msignup.m_id.value;
    let passwd = document.msignup.m_passwd.value;
    let passwd2 = document.msignup.m_passwd2.value;
    let name = document.msignup.m_name.value;
    let nickname = document.msignup.m_nickname.value;
    let tel = document.getElementById("phone").value; // id="phone" 요소에서 직접 가져옴
    let email = document.msignup.m_email.value;
    
    // 주소 관련 요소들
    let postcode = document.getElementById("postcode").value;
    let roadAddr = document.getElementById("roadAddress").value;
    let detailAddr = document.getElementById("detailAddress").value;

    let ExpId = /^[a-z0-9]*$/;
    let ExpPasswd = /^[A-Za-z0-9!@#$%_]{8,}$/;
    let ExpName = /^[가-힣]*$/;
    let Exptel = /^\d{3}-\d{3,4}-\d{4}$/;
    let ExpEmail = /^[a-zA-Z0-9][a-zA-Z0-9.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z0-9.-]{2,}$/;

    if (id == "" || !ExpId.test(id)) {
        alert("아이디를 입력하지 않았거나 부적합한 아이디 형식입니다.");
        return false;
    }

    if (isIdChecked === false) {
        alert("아이디 중복 검사를 진행해 주세요.");
        return false;
    }

    if (passwd == "" || !ExpPasswd.test(passwd)) {
        alert("비밀번호 형식이 올바르지 않습니다.");
        return false;
    }

    if (passwd !== passwd2) {
        alert("비밀번호가 일치하지 않습니다.");
        return false;
    }

    if (name == "" || !ExpName.test(name)) {
        alert("이름은 한글로 입력해주세요.");
        return false;
    }

    if (nickname == "") {
        alert("닉네임을 입력하세요.");
        return false;
    }

    if (roadAddr == "") {
        alert("주소를 입력하세요.");
        return false;
    }

    if (tel == "" || !Exptel.test(tel)) {
        alert("전화번호를 올바르게 입력하세요.");
        return false;
    }

    if (email == "" || !ExpEmail.test(email)) {
        alert("이메일 형식이 올바르지 않습니다.");
        return false;
    }

    if (isEmailChecked === false) {
        alert("이메일 인증을 완료해주세요.");
        return false;
    }

    // ================= 주소 합치기 로직 수정 (수정 페이지와 동일하게) =================
    // (우편번호) 도로명주소 상세주소
    let prefix = postcode ? "(" + postcode + ") " : "";
    let fullAddr = detailAddr ? prefix + roadAddr + " " + detailAddr : prefix + roadAddr;
    
    document.msignup.m_addr.value = fullAddr.trim();
    document.msignup.m_tel.value = tel;

    return true;
}


// =======================
// 아이디 재입력 시 중복검사 초기화
// =======================
document.addEventListener("DOMContentLoaded", function() {
    const idInput = document.getElementById("m_id");
    const idMsg = document.getElementById("idMsg");

    if (idInput) {
        idInput.addEventListener("input", function() {
            isIdChecked = false;
            idMsg.textContent = "아이디 중복 검사를 진행해 주세요.";
            idMsg.style.color = "red";
        });
    }
});
