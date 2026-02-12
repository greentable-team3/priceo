// [1] Firebase 설정
const firebaseConfig = {
  apiKey: "AIzaSyDr2qoZSdXdHgne4Pz17ffAKoCrzHqMDcg",
  authDomain: "priceo-9b9f4.firebaseapp.com",
  projectId: "priceo-9b9f4",
  messagingSenderId: "361725984447",
  appId: "1:361725984447:web:ae628ea921c2deac47500a"
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();
const VAPID_KEY = "BFIUlm6J2zfJeM1NxTJmk6D4H8w7_ihXd1cJKaiiN-A8qR8kJjBjqhkO9FYS5U6TgiLxKuRVIPVjgXUWovVqxRw";

// [2] 서비스 워커 등록 (좀비 사살용 타임스탬프 장착)
navigator.serviceWorker.register("/firebase-messaging-sw.js?v=" + Date.now())
  .then((registration) => {
    console.log("✅ [최신 일꾼 고용] 버전 업데이트 완료");
    // 새 버전 발견 시 즉시 강제 업데이트
    return registration.update(); 
  })
  .catch(err => console.error("❌ SW 등록 실패", err));

// [3] 토큰 동기화 공통 함수
async function updateFcmToken(token) {
    return fetch("/fcm/token", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ token })
    }).then(res => {
        if (res.ok) {
            console.log("✅ 토큰 동기화 성공");
            sessionStorage.setItem("last_fcm_token", token);
        }
    });
}

// [4] 상품 등록 버튼 클릭 시 호출 (토큰 따고 서브밋)
async function pinsertWithTokenSync() {
    console.log("🚀 [STEP 1] 상품 등록 프로세스 시작");
    try {
        const token = await messaging.getToken({ vapidKey: VAPID_KEY });
        if (token) {
            console.log("✅ [STEP 2] 토큰 확보:", token.substring(0, 10) + "...");
            await updateFcmToken(token); 
        }
    } catch (err) {
        console.error("❌ [STEP 2 에러] 토큰 처리 실패:", err);
    } finally {
        setTimeout(() => {
            const form = document.getElementById('pInsertForm'); 
            if(form) { 
                console.log("🔥 [STEP 3] 폼 제출!");
                form.submit(); 
            }
        }, 300);
    }
}

// [5] 페이지 로드 시 자동 토큰 갱신
window.addEventListener("load", () => {
    if (!window.IS_LOGIN) return;
    Notification.requestPermission().then(permission => {
        if (permission === "granted") {
            messaging.getToken({ vapidKey: VAPID_KEY }).then(token => {
                if (sessionStorage.getItem("last_fcm_token") !== token) {
                    updateFcmToken(token);
                }
            });
        }
    });
});

// ... [1] ~ [5] 부분은 그대로 두시고, 맨 아래 [6]번만 이 코드로 바꾸세요.

// [6] 포그라운드 메시지 처리 (알림 중복 방지 태그 추가)
messaging.onMessage(payload => {
  console.log("🔥 [신호 감지]", payload);
  
  const options = {
    body: payload.notification.body,
    icon: "/favicon.ico",
    image: payload.notification.image,
    badge: "/favicon.ico",
    // 🥊 [수정] 태그가 같으면 알림이 여러 개 뜨지 않고 하나로 교체됩니다.
    tag: "p-insert-alert", 
    renotify: true, // 알림이 교체될 때 진동/소리 다시 울림
    data: { url: (payload.data && payload.data.url) || "/main" }
  };
  
  if (Notification.permission === "granted") {
    navigator.serviceWorker.ready.then(reg => {
        reg.showNotification(payload.notification.title, options);
    });
  }
});