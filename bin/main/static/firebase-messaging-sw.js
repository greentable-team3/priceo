importScripts("https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyDr2qoZSdXdHgne4Pz17ffAKoCrzHqMDcg",
  authDomain: "priceo-9b9f4.firebaseapp.com",
  projectId: "priceo-9b9f4",
  messagingSenderId: "361725984447",
  appId: "1:361725984447:web:ae628ea921c2deac47500a"
});

const messaging = firebase.messaging();

// [1] 백그라운드 수신 - 여기서 URL을 못 놓치게 꽉 잡아야 합니다.
messaging.onBackgroundMessage(function(payload) {
  console.log("🎁 보따리 확인:", payload);

  // 🥊 주소 추출 (데이터 주머니, 알림 주머니 다 뒤집니다)
  const targetUrl = (payload.data && payload.data.url) 
                 || (payload.fcmOptions && payload.fcmOptions.link)
                 || (payload.notification && payload.notification.click_action)
                 || "/main";

  const title = payload.notification.title || "신규 알림";
  const options = {
    body: payload.notification.body || "",
    icon: "/favicon.ico",
    image: payload.notification.image || "",
    badge: "/favicon.ico",
    data: { url: targetUrl } // 🥊 클릭 시 사용할 수 있게 저장
  };

  return self.registration.showNotification(title, options);
});

// [2] 클릭 이벤트 - 여기가 핵심입니다.
self.addEventListener('notificationclick', function(event) {
  event.notification.close();

  // 🥊 저장된 URL 가져오기
  let urlToOpen = (event.notification.data && event.notification.data.url) 
                  ? event.notification.data.url : "/main";

  console.log("🚀 이동 시도:", urlToOpen);

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true })
      .then(function(windowClients) {
        // 1. 이미 우리 사이트가 열려있으면 그 창을 새로고침하며 포커스
        for (var i = 0; i < windowClients.length; i++) {
          var client = windowClients[i];
          if (client.url.includes(self.location.origin) && 'focus' in client) {
            return client.focus().then(function(c) {
              return c.navigate(urlToOpen);
            });
          }
        }
        // 2. 창이 없으면 새로 열기
        if (clients.openWindow) {
          return clients.openWindow(urlToOpen);
        }
      })
  );
});