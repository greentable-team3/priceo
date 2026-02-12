package com.priceo.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.elasticsearch.core.ElasticsearchOperations;
import org.springframework.data.elasticsearch.core.query.Criteria;
import org.springframework.data.elasticsearch.core.query.CriteriaQuery;
import org.springframework.data.elasticsearch.core.query.Query;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
//import com.priceo.repository.StaySearchRepository;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.priceo.dao.memberDAO;
import com.priceo.dao.productDAO;
import com.priceo.dto.memberDTO;
import com.priceo.dto.productDTO;
import com.priceo.service.EmailService;
import com.priceo.service.FaqSearchService;
import com.priceo.service.OpenAIService;
import com.priceo.service.ProductSearchService;
import com.priceo.service.PushService;

import jakarta.annotation.PostConstruct;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;


	@Controller
	public class memberController {
	@Autowired
	private ElasticsearchOperations elasticsearchOperations; // ⭐ 새로 추가 (7버전 호환용)
		
	
	@Autowired
	private ProductSearchService productSearchService;
	

	@Autowired
	private productDAO productDao; // 오라클 DAO (Mapper)

	@Autowired
	OpenAIService openAIService;	
	
	@Autowired
	memberDAO dao;
	
	@Autowired
	private PushService pushService;
	
	@Autowired
	private FaqSearchService faqService;
	
	// 비밀 번호 암호화
	@Autowired
	private PasswordEncoder passwordEncoder;
   
   //회원 정보 입력
   @RequestMapping("/msignup")
      public String writeForm() {
      return "user/member/msignup";
   }
   
   // 회원 정보 저장
   @PostMapping("/write")
   public String write(memberDTO dto) {

       // 1. 비밀번호 암호화
       if (dto.getM_passwd() != null && !dto.getM_passwd().isEmpty()) {
           dto.setM_passwd(passwordEncoder.encode(dto.getM_passwd()));
       }

       // 2. 일단 USER로 넣기
       dto.setM_authority("USER");

       // 3. 회원 가입 (여기서 m_no 생성됨)
       dao.SignupDao(dto);

       // 4. 방금 가입한 회원 다시 조회
       memberDTO saved = dao.getMemberByIdDao(dto.getM_id());

       // 5. ⭐ 최초 가입자면 관리자 권한 부여
       if (saved.getM_no() == 1) {
           dao.updateAuthority(saved.getM_no(), "ADMIN");
       }

       return "redirect:/";
   }
   
   // 로그인
   @RequestMapping("/mloginForm")
   public String loginForm (memberDTO dto, Model model) {
      model.addAttribute("dto", dto);
      return "user/member/mloginForm";
   }
   
      
   // 이메일 인증
      @Autowired
      private EmailService emailService;

      @PostMapping("/mailCheck")
      @ResponseBody // 페이지 이동 없이 데이터만 보냄
      public String mailCheck(@RequestParam("m_email") String email, HttpSession session,@RequestParam("type") String type) {
          // 1. 이메일로 인증번호 발송
    	  String authKey = emailService.sendAuthMail(email, type);
    	  
          
          // 2. 서버 세션에 인증번호 저장 (나중에 사용자가 입력한 값과 비교용)
          session.setAttribute("authKey", authKey);
          // 세션 유지 시간 설정 (예: 3분)
          session.setMaxInactiveInterval(3 * 60); 
          
          return "success"; // 프론트엔드에 성공 알림
      }
      
      @PostMapping("/verifyCode")
      @ResponseBody
      public boolean verifyCode(@RequestParam("code") String code, HttpSession session) {
          String serverCode = (String) session.getAttribute("authKey");
          if (serverCode != null && serverCode.equals(code)) {
              return true; // 인증 성공
          }
          return false; // 인증 실패
      }
	

    // 아이디 확인
    @ResponseBody // 문자열 그대로 출력 어노테이션
    @GetMapping("/idCheck")
    public String idCheck(@RequestParam("m_id") String m_id) { // 사용자가 m_id값을 입력하고 서버에 요청을 보내면 'm_id'라는 변수에 저장해주세욥
 
        int cnt = dao.idCheck(m_id); 
        // idCheckDAO 메서드(select count(*) from member where m_id = #{m_id})를 실행하여
        // 사용자가 입력한 m_id데이터와 같은 m_id열의 데이터 개수를 'cnt'라는 변수에 저장한다
 
        if (cnt > 0) { // 개수가 0보다 많으면
            return "DUPLICATE";   // 이미 존재
        }
        return "OK";             // 아니면 사용 가능
    }

	
	// 회원 정보 조회
	   @RequestMapping("/alist")
	   public String alist(Model model) {
	      model.addAttribute("member", dao.listDao());
	      return "admin/alist";
	   }
	   
	   // 회원 정보 삭제
	   @RequestMapping("/delete")
	   public String adelete(HttpServletRequest request){
	      int m_no = Integer.parseInt(request.getParameter("m_no"));
	      dao.DeleteMemberDao(m_no);
	      return "redirect:/alist";
	      }
	   
	   // 회원 정보 수정 폼
	   @RequestMapping("/mupdateForm")
	   public String mupdateForm(HttpServletRequest request, Model model) {
	      int m_no = Integer.parseInt(request.getParameter("m_no"));
	      model.addAttribute("update", dao.getMember(m_no));
	      return "user/member/mupdateForm";
	   }
	   
	   
	   // 회원정보 수정
	   @RequestMapping("/update")
	   public String update(HttpServletRequest request,memberDTO dto,
			   @RequestParam("old_passwd")String oldPasswd,@RequestParam("old_addr") String oldAddr) throws Exception {
	      
		   	  // [추가] 시큐리티 세션에서 현재 로그인한 아이디 가져오기
	          String loginId = SecurityContextHolder.getContext().getAuthentication().getName();
	          memberDTO currentMember = dao.getMemberByIdDao(loginId);

	          // [체크] 로그인한 유저와 수정하려는 유저의 번호가 일치하는지 검증
	          if (currentMember.getM_no() != dto.getM_no()) {
	              return "redirect:/main"; // 혹은 에러 페이지
	          }
		   
	       // 비밀번호 암호화
	       // 사용자가 새 비밀번호를 입력했는지 확인
	       if (dto.getM_passwd() == null || dto.getM_passwd().equals("")) {
	           // 비어있다면 암호화 과정을 거치지 않고 "기존 암호문"을 그대로 세팅
	           dto.setM_passwd(oldPasswd);
	       } else {
	           // 새 비밀번호를 입력했을 때만 암호화(passwordEncoder)를 진행!
	           String encPw = passwordEncoder.encode(dto.getM_passwd());
	           dto.setM_passwd(encPw);
	       }
	       
	       // 주소 처리 (JS파일에서 합쳐진 m_addr이 비어있다면 기존 주소 유지)
	       if (dto.getM_addr() == null || dto.getM_addr().trim().equals("")) {
	           dto.setM_addr(oldAddr);
	       }
	       
	       
	       
	       dao.updateDao(dto); // dto에 저장된 값을 updateDao 메서드를 통해 최종적으로 DB에 저장
	       
	       return "redirect:/myinfo";  // 수정 완료 후 내 정보 보기로 회귀
	   }
	   
	   
	// 비밀번호 확인폼
	   @RequestMapping("/mpasswordCheckForm")
	   public String passwordCheckForm(HttpServletRequest request, HttpSession session, Model model) {
	       int mno = Integer.parseInt(request.getParameter("m_no"));
	       String mode = request.getParameter("mode");
	       
	       memberDTO dto = dao.getMember(mno);
	       
	       // DB 비번이 OAUTH2_USER면 무조건 소셜 유저다!
	       boolean isSocialUser = "OAUTH2_USER".equals(dto.getM_passwd());

	       if (isSocialUser) {
	           if ("update".equals(mode)) {
	               // 수정 모드: 소셜은 비번 확인 없이 바로 이동
	               model.addAttribute("update", dto);
	               return "user/member/mupdateForm";
	           } else if ("delete".equals(mode)) {
	               // 탈퇴 모드: JSP에서 'isSocial' 블록을 보여주기 위해 true 설정
	               model.addAttribute("isSocial", true);
	               model.addAttribute("member", dto);
	           }
	       }

	       model.addAttribute("m_no", mno);
	       model.addAttribute("mode", mode);
	       return "user/member/mpasswordCheckForm";
	   }
	   
	// 비밀번호 확인 처리 및 회원 탈퇴
	    @RequestMapping("/passwordCheck")
	    public String passwordCheck(HttpServletRequest request, HttpServletResponse response, HttpSession session, Model model) {

	        int m_no = Integer.parseInt(request.getParameter("m_no"));
	        String mode = request.getParameter("mode");
	        String m_passwd = request.getParameter("m_passwd");

	        memberDTO dto = dao.getMember(m_no);
	        boolean pwdchk = false;

	        // [기강 잡기] DB에 저장된 비번이 'OAUTH2_USER'면 소셜 유저 하이패스
	        if ("OAUTH2_USER".equals(dto.getM_passwd())) {
	            pwdchk = true; 
	        } else {
	            // 일반 유저는 암호화 체크
	            pwdchk = passwordEncoder.matches(m_passwd, dto.getM_passwd());
	        }

	        if (pwdchk) {
	            if ("update".equals(mode)) {
	                model.addAttribute("update", dto);
	                return "user/member/mupdateForm";
	            } else if ("delete".equals(mode)) {
	                // 🥊 1. 소셜 연동 해제 전 로그 찍어보기
	                String kakaoToken = (String) session.getAttribute("kakao_access_token");
	                String googleToken = (String) session.getAttribute("google_access_token");
	                
	                System.out.println("카카오 토큰 상태: " + (kakaoToken != null ? "있음" : "없음"));
	                System.out.println("구글 토큰 상태: " + (googleToken != null ? "있음" : "없음"));

	                // 🥊 2. 연동 해제 실행
	                if (kakaoToken != null) this.kakaoUnlink(kakaoToken);
	                if (googleToken != null) this.googleRevoke(googleToken);

	                // 🥊 3. DB 삭제
	                dao.DeleteMemberDao(m_no);
	                
	                // 🥊 4. 쿠키 강제 파괴 (매개변수에 HttpServletResponse response 추가됨)
	                Cookie[] cookies = request.getCookies();
	                if (cookies != null) {
	                    for (Cookie cookie : cookies) {
	                        cookie.setMaxAge(0);
	                        cookie.setPath("/");
	                        response.addCookie(cookie);
	                    }
	                }

	                SecurityContextHolder.clearContext();
	                session.invalidate(); 

	                return "redirect:/?status=withdrawn"; 
	            }
	        } else {
	            // 비밀번호 틀렸을 때 (pwdchk가 false인 경우)
	            model.addAttribute("msg", "비밀번호가 일치하지 않습니다.");
	            model.addAttribute("m_no", m_no);
	            model.addAttribute("mode", mode);
	            return "user/member/mpasswordCheckForm";
	        }
	        
	        return "user/member/mpasswordCheckForm"; // 만약의 상황을 대비한 리턴
	    }

	   // --- 아래는 소셜 연동 해제를 위한 지원 메서드들입니다 ---

	   // 카카오 연동 해제 API
	   private void kakaoUnlink(String accessToken) {
	       try {
	           java.net.URL url = new java.net.URL("https://kapi.kakao.com/v1/user/unlink");
	           java.net.HttpURLConnection conn = (java.net.HttpURLConnection) url.openConnection();
	           conn.setRequestMethod("POST");
	           conn.setRequestProperty("Authorization", "Bearer " + accessToken);
	           
	           int responseCode = conn.getResponseCode();
	           System.out.println("카카오 언링크 완료 (코드: " + responseCode + ")");
	       } catch (Exception e) {
	           System.out.println("카카오 언링크 실패: " + e.getMessage());
	       }
	   }

	   // 구글 연동 해제 API
	   private void googleRevoke(String accessToken) {
		    try {
		        // 🥊 구글은 파라미터를 몸체(Body)에 실어 보내는 걸 가장 좋아합니다.
		        java.net.URL url = new java.net.URL("https://oauth2.googleapis.com/revoke");
		        java.net.HttpURLConnection conn = (java.net.HttpURLConnection) url.openConnection();
		        conn.setRequestMethod("POST");
		        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
		        conn.setDoOutput(true);

		        // 🥊 토큰을 쿼리 스트링 형태로 바디에 꽂아넣기
		        try (java.io.OutputStream os = conn.getOutputStream()) {
		            byte[] input = ("token=" + accessToken).getBytes("utf-8");
		            os.write(input, 0, input.length);
		        }

		        int responseCode = conn.getResponseCode();
		        if (responseCode == 200) {
		            System.out.println("구글 연동 해제 성공 (코드: 200)");
		        } else {
		            // 실패했다면 구글이 보낸 에러 메시지라도 읽어봅시다.
		            System.out.println("구글 연동 해제 실패 (응답 코드: " + responseCode + ")");
		        }
		    } catch (Exception e) {
		        System.out.println("구글 연동 해제 에러: " + e.getMessage());
		    }
		}
	   
	   // 회원 정보 조회
	   @RequestMapping("/myinfo")
	   public String myinfo(Model model) {

	       String loginId = SecurityContextHolder
	               .getContext()
	               .getAuthentication()
	               .getName();   // 로그인한 m_id

	       memberDTO member = dao.getMemberByIdDao(loginId);

	       model.addAttribute("member", member);
	       model.addAttribute("m_no", member.getM_no());

	       return "user/member/myinfo";
	   }
	   
	      
	      
	      // 아이디 찾기 폼
	      @GetMapping("/mfindIdForm")
	      public String findIdForm() {
	         return "user/member/mfindIdForm";
	      }
	      
	      // 아이디 찾기
	      @PostMapping("/findId")
	      public String findIdByEmail(@RequestParam("m_email") String m_email, Model model) {

	          List<memberDTO> list = dao.findAllByEmail(m_email);

	          if (list.isEmpty()) {
	              model.addAttribute("msg", "해당 이메일로 가입된 계정이 없습니다.");
	              return "user/member/mfindIdForm";
	          }

	          //  *** 마스킹 처리 로직
	          for (memberDTO m : list) {
	              String rawId = m.getM_id();
	              // 여기서 바로 마스킹해서 리스트에 다시 세팅
	              m.setM_id(rawId.substring(0, 3) + "***"); 
	          }

	          model.addAttribute("idList", list);
	          // JSP의 c:if 조건을 위해 필요한 변수
	          model.addAttribute("foundId", true); 

	          return "user/member/mfindIdForm";
	      }
	      
	      // 비밀 번호 재설정
	      @RequestMapping("/mresetPasswordForm")
	      public String resetpasswordForm() {
	         return "user/member/mresetPasswordForm";
	      }
	   // 아이디와 이메일 확인
	      @PostMapping("/findPwAuth")
	      @ResponseBody
	      public String findPwAuth(@RequestParam("m_id") String m_id, 
	                               @RequestParam("m_email") String email, 
	                               HttpSession session) {
	          
	          // [추가] 전달받은 파라미터 확인용 로그
	          System.out.println("비밀번호 찾기 시도 - ID: " + m_id + ", Email: " + email);

	          // 아이디로 회원 정보 가져오기
	          memberDTO dto = dao.getMemberByIdDao(m_id);

	          // 아이디가 있고, 입력한 이메일이 DB의 이메일과 일치하는지 확인
	          if (dto != null && dto.getM_email().equals(email)) {
	              // 인증번호 발송 (기존에 만든 EmailService 활용)
	        	  String authKey = emailService.sendAuthMail(email, "reset");
	              
	              // 인증 성공 시 비밀번호를 바꿀 대상 아이디를 세션에 저장
	              session.setAttribute("resetId", m_id);
	              session.setAttribute("authKey", authKey); // 인증번호 비교용
	              
	              return "success";
	          } else {
	              // [추가] 실패 원인 파악을 위한 로그
	              if(dto == null) {
	                  System.out.println("결과: 존재하지 않는 아이디입니다.");
	              } else {
	                  System.out.println("결과: 아이디는 일치하나 이메일 정보가 다릅니다.");
	              }
	              return "fail"; // 일치하는 정보 없음 -> JS의 else 문에서 alert를 띄우게 됨
	          }
	      }
	      
	      // 비밀번호 재설정
	      @PostMapping("/updatePassword")
	      @ResponseBody
	      public String updatePassword(@RequestParam("m_passwd") String newPw, HttpSession session) {
	          // 세션에 저장해둔 '누구의 비번을 바꿀 것인가' 정보 가져오기
	          String m_id = (String) session.getAttribute("resetId");
	          
	          if (m_id != null) {
	              // 새 비밀번호 암호화
	              String encoded = passwordEncoder.encode(newPw);
	              // DB 업데이트
	              dao.updatePassword(m_id, encoded);
	              
	              // 작업 끝났으니 세션 비우기
	              session.removeAttribute("resetId");
	              session.removeAttribute("authKey");
	              
	              return "success";
	          }
	          return "fail";
	      }
	      
	      // FAQ 고정 페이지
	      @GetMapping("/mfaq")
	      public String mfaq() {
	          return "user/member/mfaq";
	      }
	      
	               // 챗봇
	               @PostMapping("/mfaq/ask")
	               @ResponseBody
	               public Map<String, Object> faqAsk(
	                       @RequestParam("question") String question,
	                       HttpSession session) {

	                   try {
	                       /* =========================
	                        * 0단계. 로그인 상태 확인
	                        * ========================= */
	                       Authentication auth = SecurityContextHolder.getContext().getAuthentication();
	                       boolean isLoggedIn =
	                               auth != null &&
	                               auth.isAuthenticated() &&
	                               !(auth instanceof AnonymousAuthenticationToken);

	                       /* =========================
	                        * 1단계. 챗봇 전용 메뉴 검색
	                        * ========================= */
	                       Map<String, String> menu = faqService.searchMenuDetailForChatbot(question);

	                       if (menu != null && menu.get("url") != null) {
	                           String menuName = menu.get("menuName");
	                           String show = menu.get("show");

	                           if (!isLoggedIn && "user".equals(show)) {
	                               return Map.of(
	                                       "type", "ANSWER",
	                                       "message", "요청하신 **" + menuName + "** 서비스는 로그인이 필요합니다."
	                               );
	                           }

	                           if (isLoggedIn && "guest".equals(show)) {
	                               return Map.of(
	                                       "type", "ANSWER",
	                                       "message", "이미 **로그인** 상태입니다!"
	                               );
	                           }

	                           return Map.of(
	                                   "type", "REDIRECT",
	                                   "url", menu.get("url"),
	                                   "menuName", menuName,
	                                   "message", "찾으시는 **" + menuName + "** 페이지를 찾았습니다! 😊"
	                           );
	                       }

	                       /* =========================
	                        * 2단계. 상품 검색 (NPE 방어)
	                        * ========================= */
	                       Map<String, Object> productRes = faqService.searchProducts(question);
	                       List<Map<String, Object>> products = null;

	                       if (productRes != null) {
	                           Object pObj = productRes.get("products");
	                           if (pObj instanceof List) {
	                               products = (List<Map<String, Object>>) pObj;
	                           }
	                       }

	                       if (products != null && !products.isEmpty()) {
	                           String displayName =
	                                   productRes.containsKey("message")
	                                           ? String.valueOf(productRes.get("message"))
	                                           : String.valueOf(products.get(0).get("p_name"));

	                           return Map.of(
	                                   "type", "CONFIRM_PRODUCT",
	                                   "productName", displayName,
	                                   "searchUrl", "/search?keyword=" +
	                                           java.net.URLEncoder.encode(question, "UTF-8")
	                           );
	                       }

	                       /* =========================
	                        * 3단계. FAQ 검색
	                        * ========================= */
	                       Map<String, Object> faqRes = faqService.searchAnswer(question);
	                       if (faqRes != null && faqRes.get("answer") != null) {
	                           return Map.of(
	                                   "type", "ANSWER",
	                                   "message", String.valueOf(faqRes.get("answer"))
	                           );
	                       }

	                       /* =========================
	                        * 4단계. FAQ에 없으면 → GPT + 이메일 자동 전송
	                        * ========================= */
	                       String gptAnswer;
	                       try {
	                           gptAnswer = openAIService.askGPT(question);
	                       } catch (Exception e) {
	                           e.printStackTrace();
	                           gptAnswer =
	                                   "죄송합니다. 현재 답변 생성에 문제가 발생했습니다. " +
	                                   "문의 내용은 담당자에게 전달되었습니다.";
	                       }

	                       /* =========================
	                        * 5단계. 메일 중복 전송 방지
	                        * ========================= */
	                       String lastMailed = (String) session.getAttribute("last_mailed_question");

	                       if (!question.equals(lastMailed)) {
	                           try {
	                               emailService.sendFaqMail(
	                                       "ytaeug43@gmail.com",
	                                       "[PRICEO 챗봇 문의 - FAQ 미등록]",
	                                       "질문:\n" + question + "\n\nGPT 답변:\n" + gptAnswer
	                               );
	                               session.setAttribute("last_mailed_question", question);
	                           } catch (Exception mailEx) {
	                               mailEx.printStackTrace();
	                           }
	                       }

	                       return Map.of(
	                               "type", "ANSWER",
	                               "message", gptAnswer
	                       );

	                   } catch (Exception e) {
	                       e.printStackTrace();
	                       return Map.of(
	                               "type", "ANSWER",
	                               "message",
	                               "챗봇 서비스에 일시적인 오류가 발생했습니다. " +
	                               "문의 내용은 담당자에게 전달되었습니다."
	                       );
	                   }
	               }
	      
	      // 챗봇 답변 실패 시 이메일 문의 전송
	      @PostMapping("/mfaq/sendMail")
	      @ResponseBody
	      public String sendFaqMail(
	              @RequestParam("question") String question
	      ) {
	          emailService.sendFaqMail(
	              "ytaeug43@gmail.com",
	              "[PRICEO FAQ 문의]",
	              question
	          );
	          return "OK";
	      }
	      
	   // 카카오 및 네이버 소셜 로그인 후처리 컨트롤러
	      @GetMapping("/kakao") // 기존 이름 유지
	      public String socialCallback(@AuthenticationPrincipal OAuth2User oAuth2User, HttpSession session) {
	          if (oAuth2User == null) return "redirect:/mloginForm";
	          
	          String mid = oAuth2User.getName(); 
	          memberDTO member = dao.findByMid(mid);
	          
	          if (member != null) {
	              // 이 4줄이 JSP 에러를 막는 핵심입니다.
	              session.setAttribute("loginMember", member);
	              session.setAttribute("m_id", member.getM_id());
	              session.setAttribute("m_nickname", member.getM_nickname());
	              session.setAttribute("m_authority", member.getM_authority());
	          }
	          return "redirect:/main";
	      }
	      
	      @PostConstruct 
	      @GetMapping("/sync/all")
	      @ResponseBody // 주소창에 직접 쳤을 때만 결과 메시지 보여줌
	      public String syncAll() {
	          // 내부 로직 실행용 메서드를 따로 호출 (아래 2번 참고)
	          return runSyncProcess(); 
	      }

	      // 🥊 진짜 동기화 "과정"만 담은 핵심 로직
	      public String runSyncProcess() {
	          try (org.elasticsearch.client.RestHighLevelClient client = new org.elasticsearch.client.RestHighLevelClient(
	                  org.elasticsearch.client.RestClient.builder(
	                          new org.apache.http.HttpHost("localhost", 9200, "http")))) {

	              List<productDTO> list = productDao.plistDao(null);
	              if (list == null || list.isEmpty()) return "DB Empty";

	              for (productDTO dto : list) {
	                  Map<String, Object> source = new HashMap<>();
	                  source.put("p_no", (long) dto.getP_no());
	                  source.put("p_name", dto.getP_name());
	                  // ... (중략: 형님의 ES 주입 로직) ...
	                  
	                  org.elasticsearch.action.index.IndexRequest request = new org.elasticsearch.action.index.IndexRequest("product")
	                          .id(String.valueOf(dto.getP_no()))
	                          .source(source, org.elasticsearch.common.xcontent.XContentType.JSON);

	                  client.index(request, org.elasticsearch.client.RequestOptions.DEFAULT);
	              }
	              return "Success";
	          } catch (Exception e) {
	              return "Error: " + e.getMessage();
	          }
	      }
	      
	   // 🔍 통합 자동완성 API (형님이 직접 추가해야 할 부분!)
	      @GetMapping("/chatbot/autocomplete")
	      @ResponseBody
	      public List<String> getAutocomplete(@RequestParam("q") String q) {
	          System.out.println("자동완성 요청 들어옴: " + q); // 서버 콘솔에 찍히는지 확인용
	          
	          if (q == null || q.trim().isEmpty()) {
	              return java.util.Collections.emptyList();
	          }

	          try {
	              // 1. 상품명 자동완성 호출
	              List<String> productSuggests = productSearchService.autocomplete(q);
	              
	              // 2. 숙소명 자동완성 호출 (faqService에 해당 메서드가 있는지 확인 필요)
	              List<String> staySuggests = faqService.autocompleteStays(q);
	              
	              // 3. 리스트 통합 및 중복 제거
	              java.util.List<String> total = new java.util.ArrayList<>();
	              if(productSuggests != null) total.addAll(productSuggests);
	              if(staySuggests != null) total.addAll(staySuggests);
	              
	              return total.stream()
	                          .distinct()
	                          .limit(10)
	                          .collect(java.util.stream.Collectors.toList());
	          } catch (Exception e) {
	              e.printStackTrace();
	              return java.util.Collections.emptyList();
	          }
	      }
	}
	