//주소 검색 및 입력은 daum 주소 검색 API를 활용 여기서 검색하여 입력된 데이터 값(도로명 주소 + 상세 주소)은 js에서 하나의 데이터로 결합 
function execDaumPostcode() {
    new daum.Postcode({
        oncomplete: function(data) {
			// 우편번호와 주소 정보를 해당 필드에 넣음
            document.getElementById('postcode').value = data.zonecode;
            document.getElementById('roadAddress').value = data.roadAddress;
            // 커서를 상세주소 필드로 이동
            document.getElementById('detailAddress').focus();
        }
    }).open(); // 주소 검색 api 팝업창을 띄움
}
function checkpasswd(){
	let passwd = document.mupdateForm.m_passwd.value;
	let passwd2 = document.mupdateForm.m_passwd2.value;
	let msg = document.getElementById("pwMsg"); // 비밀번호 일치 불일치 표시
	
	// 아직 입력 안 된 상태면 아무 표시도 안 함
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
// 회원정보 수정 페이지에서 기존 주소 표시(도로명주소, 상세주소 쪼개기)
// =======================
document.addEventListener("DOMContentLoaded", function() {
    // 🥊 JSP에서 input에 숨겨둔 원본 주소를 가져옵니다.
    const fullAddr = document.mupdateForm.old_addr.value; 
    
    if (fullAddr) {
        // 1. (우편번호) 부분을 떼어내고 순수 주소만 추출
        const pureAddr = fullAddr.replace(/^\(\d{5}\)\s*/, ""); 

        // 2. 도로명과 상세주소를 나누는 정규식 (형님이 주신 로직 최적화)
        const match = pureAddr.match(/^(.+[로|길|동|읍|면]\s\d+(?:-\d+)?)\s(.*)$/);

        if (match) {
            document.getElementById('roadAddress').value = match[1].trim();
            document.getElementById('detailAddress').value = match[2].trim();
        } else {
            // 정규식 매칭 실패 시 전체를 도로명에 넣음
            document.getElementById('roadAddress').value = pureAddr;
        }
    }
});

// =======================
// 주소 새로 검색 시 기존 주소 지우기
// =======================

function execDaumPostcode() {
    new daum.Postcode({
        oncomplete: function(data) {
            document.getElementById('postcode').value = data.zonecode;
            document.getElementById('roadAddress').value = data.roadAddress;
            
            // 주소를 새로 검색하면 상세 주소 칸은 비워주고 포커스를 줍니다.
            document.getElementById('detailAddress').value = "";
            document.getElementById('detailAddress').focus();
        }
    }).open();
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
    document.mupdateForm.m_tel.value = formatted;
}

function check() {
	let passwd = document.mupdateForm.m_passwd.value;
	let name = document.mupdateForm.m_name.value;
	let roadAddr = document.getElementById("roadAddress").value;
	let detailAddr = document.getElementById("detailAddress").value;
	let postcode = document.getElementById("postcode").value; // 우편번호 가져오기 추가
    let tel = document.getElementById("phone").value;
	const oldAddr = document.mupdateForm.old_addr.value; 
	
	let email = document.mupdateForm.m_email.value;
	
	let finalAddr = ""; // 최종 주소를 담을 변수
	
	let ExpPasswd=/^[A-Za-z0-9!@#$%_]{8,}$/;
	let ExpName=/^[가-힣]*$/;
	let Exptel=/^\d{3}-\d{3,4}-\d{4}$/;
	let ExpEmail=/^[a-zA-Z0-9][a-zA-Z0-9.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z0-9.-]{2,}$/;
	
	if (passwd !== "" && !ExpPasswd.test(passwd)) {
	    alert("부적합한 비밀번호 형식입니다. \n비밀번호는 영문 대소문자와 숫자, 특수기호(!, @, #, $, %, _)를 사용하여 8자리 이상 입력해 주세요");
	    return false;
	}
	
	if(!ExpName.test(name)) {
		alert("이름을 확인하세요\n이름은 한글로만 입력해 주세요");
		return false;
	}

	// ================= 주소 합치기 로직 수정 시작 =================
	if (roadAddr) {
		// 우편번호가 있으면 (우편번호)를 앞에 붙이고, 없으면 도로명부터 시작
		let prefix = postcode ? "(" + postcode + ") " : "";
		finalAddr = detailAddr ? prefix + roadAddr + " " + detailAddr : prefix + roadAddr;
	} else {
		finalAddr = oldAddr; // 입력된 주소가 없으면 기존 데이터 유지
	}
	// ================= 주소 합치기 로직 수정 끝 =================
	
	if(!Exptel.test(tel)) {
		alert("전화번호를 확인하세요\n전화번호는 숫자만 입력하세요");
		return false;
	}
	
	if(!ExpEmail.test(email)) {
		alert("이메일을 확인하세요\n이메일 입력형식 : abcd@google.com")
		return false;
	}
	
	document.mupdateForm.m_addr.value = finalAddr.trim(); // 합쳐진 finalAddr를 저장
	document.mupdateForm.m_tel.value = tel;

	document.mupdateForm.submit();
}