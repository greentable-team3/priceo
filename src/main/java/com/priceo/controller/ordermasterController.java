package com.priceo.controller;

import java.io.File;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.priceo.dao.memberDAO;
import com.priceo.dao.ordermasterDAO;
import com.priceo.dao.productcartDAO;
import com.priceo.dao.stayCalendarDAO;
import com.priceo.dao.stayDetailDAO;
import com.priceo.dao.stayRoomDAO;
import com.priceo.dto.exchangeDTO;
import com.priceo.dto.memberDTO;
import com.priceo.dto.ordermasterDTO;
import com.priceo.dto.productcartDTO;
import com.priceo.dto.productdetailDTO;
import com.priceo.dto.stayDetailDTO;
import com.priceo.service.portoneService;

@Controller
public class ordermasterController {
	@Autowired
    private ordermasterDAO odao;
	
	@Autowired
    private productcartDAO cdao;
	
	@Autowired
    private stayDetailDAO sddao; 

    @Autowired
    private stayCalendarDAO scdao;
	
	@Autowired
    private stayRoomDAO srdao;
	
	@Autowired
    private memberDAO dao;
	
	@Autowired
	private portoneService ps;
	
	@RequestMapping("/orderform")
	public String orderForm(@RequestParam("om_total") int om_total, Model model) { 
	    // 1. URL(?m_no=1)에 상관없이 현재 로그인한 사람의 진짜 ID를 가져옴
	    String loginId = SecurityContextHolder.getContext().getAuthentication().getName();
	    
	    // 2. DB에서 해당 ID를 가진 회원의 정보를 조회 (여기서 진짜 m_no가 나옴)
	    memberDTO member = dao.getMemberByIdDao(loginId);
	    
	    // 3. 모델에 실제 회원의 번호를 담음 (이제 URL이 1이든 100이든 상관없이 본인 번호가 들어감)
	    model.addAttribute("loginMember", member); 
	    model.addAttribute("m_no", member.getM_no()); 
	    model.addAttribute("totalSum", om_total);
	    
	    return "user/ordermaster/orderForm";
	}
	
	@RequestMapping("/orderProcess")
	@Transactional
	public String orderProcess(ordermasterDTO dto, stayDetailDTO sddto) {
		// 1. 유저 정보 가져오기 (기존 유지)
		String loginId = SecurityContextHolder.getContext().getAuthentication().getName();
		memberDTO member = dao.getMemberByIdDao(loginId); 
		dto.setM_no(member.getM_no());

		// 2. 주문 마스터 저장 
		// [중요] odao.orderinsertDao 실행 후 MyBatis의 selectKey에 의해 dto.getOm_no()에 값이 채워집니다.
		odao.orderinsertDao(dto); 
		
		// 생성된 주문번호를 변수에 확실히 저장
		int generatedOmNo = dto.getOm_no();
		System.out.println(">>> 생성된 주문번호: " + generatedOmNo);

		if ("STAY".equals(dto.getOm_type())) {
			// --- [숙소 예약 로직] ---
			sddto.setOm_no(generatedOmNo); // 방금 생성된 번호 강제 세팅
			sddao.insertStayDetail(sddto); 

			Map<String, Object> map = new java.util.HashMap<>();
			map.put("sr_no", sddto.getSr_no());
			map.put("sc_date", sddto.getSd_checkin());
			scdao.updateBookingStatus(map); 
			
		} else {
			// --- [상품 결제 로직] ---
			List<productcartDTO> cartList = cdao.cartlistDao(member.getM_no());
			
			// 장바구니가 비어있는데 주문이 들어오는 경우 방지 (방어 코드)
			if(cartList == null || cartList.isEmpty()) {
				throw new RuntimeException("장바구니가 비어있어 주문을 진행할 수 없습니다.");
			}

			for(productcartDTO cart : cartList) {
				productdetailDTO pdto = new productdetailDTO();
				pdto.setOm_no(generatedOmNo); // 방금 생성된 번호 강제 세팅
				pdto.setP_no(cart.getP_no());
				pdto.setPd_count(cart.getPc_count());
				pdto.setPd_state("결제완료"); // 관리자 목록의 버튼 조건과 일치해야 함
				
				// [확인] 이 메소드가 DB에 'product_detail' 인서트를 수행함
				odao.insertProductDetail(pdto);
				odao.updateProductStock(cart.getP_no(), cart.getPc_count());
			}
			odao.cartclearDao(member.getM_no());
		}

		return "redirect:/orderlist";
	}

	@RequestMapping("/orderlist")
	public String orderlist(Model model) {
	    // 1. 현재 로그인한 유저 정보 및 권한 가져오기
	    String loginId = SecurityContextHolder.getContext().getAuthentication().getName();
	    memberDTO member = dao.getMemberByIdDao(loginId);
	    
	    // 시큐리티 권한 확인 (ROLE_ADMIN 또는 ADMIN 형식 확인 필요)
	    boolean isAdmin = SecurityContextHolder.getContext().getAuthentication()
	                      .getAuthorities().stream()
	                      .anyMatch(a -> a.getAuthority().equals("ADMIN"));

	    List<Map<String, Object>> olist;

	    if (isAdmin) {
	        // 관리자: 전체 주문 조회
	    	olist = odao.selectAllOrders(); 
	    } else {
	        // 일반 유저: 본인 주문만 조회
	        olist = odao.orderlistDao(member.getM_no());
	    }

	    model.addAttribute("olist", olist);
	    model.addAttribute("isAdmin", isAdmin); // JSP에서 버튼 분기용
	    return "user/ordermaster/orderlist"; 
	}
    
    
    @RequestMapping("/orderdetail") // 주문목록 상세보기
    public String orderDetail(@RequestParam("om_no") int om_no, Model model) {
    	// 1. DAO를 통해 조인된 데이터를 가져옵니다.
        // 결과가 List인 이유는 한 주문에 여러 상품이 있을 수 있기 때문입니다.
        List<Map<String, Object>> detailList = odao.getOrderDetail(om_no);

        if (detailList != null && !detailList.isEmpty()) {
            // 2. 주문 마스터 정보(주소, 수신인 등)는 리스트의 어떤 항목이든 동일하므로 첫 번째 항목을 꺼냅니다.
            model.addAttribute("master", detailList.get(0));
            // 3. 상품 목록 전체를 모델에 담습니다.
            model.addAttribute("details", detailList);
        }
        
        return "user/productdetail/productdetail";
    }

    @RequestMapping("/orderCancel")
    @ResponseBody
    @Transactional
    public String orderCancel(@RequestParam("om_payno") String om_payno, @RequestParam("om_no") int om_no) {
        try {
            String token = ps.getToken();
            if (token != null) {
                boolean isRefunded = ps.refund(token, om_payno, "고객 요청 취소");

                if (isRefunded) {
                    // 1. 숙소 정보 확인 (숙소 예약인지 체크)
                    stayDetailDTO sdInfo = sddao.selectStayDetail(om_no); 
                    
                    if (sdInfo != null) {
                        // --- [숙소 취소 로직] ---
                        // A. 달력 복구 ('Y' -> 'N')
                        Map<String, Object> map = new java.util.HashMap<>();
                        map.put("sr_no", sdInfo.getSr_no());
                        String cleanDate = String.valueOf(sdInfo.getSd_checkin()).substring(0, 10);
                        map.put("sc_date", cleanDate);
                        scdao.restoreBookingStatus(map); 

                        // B. 상태 업데이트 (마스터 & 상세 모두)
                        odao.updateStayDetailStatus(om_no, "취소완료");
                        odao.updateProductDetailStatus(om_no, "취소완료"); // 숙소 상세는 취소완료로

                    } else {
                        // --- [일반 상품 취소 로직] ---
                        // A. 재고 복구
                        List<productdetailDTO> items = odao.getOrderDetailItems(om_no);
                        if(items != null) {
                            for(productdetailDTO item : items) {
                                odao.restoreProductStock(item.getP_no(), item.getPd_count());
                            }
                        }
                        // B. 상태 업데이트 (마스터 & 상세)
                        odao.updateProductDetailStatus(om_no, "결제취소");
                    }
                    
                    return "success";
                } else {
                    return "refund_api_failed";
                }
            }
            return "token_failed";
        } catch (Exception e) {
            e.printStackTrace();
            return "error: " + e.getMessage();
        }
    }
    
    
    @RequestMapping("/orderExchangeForm") // 교환 폼
    public String orderExchangeForm(@RequestParam("om_no") int om_no, Model model) {
        // 해당 주문의 상품 정보를 가져와서 화면에 보여주기 위함
        List<Map<String, Object>> detailList = odao.getOrderDetail(om_no);
        
        model.addAttribute("master", detailList.get(0));
        model.addAttribute("details", detailList);
        
        return "user/exchange/exchangeForm"; // 생성할 JSP 파일명
    }
    
    @RequestMapping("/orderExchange")  // 교환
    public String orderExchange(exchangeDTO edto, 
                                @RequestParam(value="exchange_img", required=false) MultipartFile file, 
                                RedirectAttributes rttr) {
    	
    	String loginId = SecurityContextHolder.getContext().getAuthentication().getName();
        memberDTO member = dao.getMemberByIdDao(loginId);
    	
        try {
            // 1. 이미지 파일 처리
            if (file != null && !file.isEmpty()) {
                String uploadPath = "C:/exchange/"; 
                File folder = new File(uploadPath);
                if (!folder.exists()) folder.mkdirs();

                String fileName = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
                file.transferTo(new File(uploadPath + fileName));
                
                edto.setE_image(fileName); // DTO 필드명 확인 (e_img 또는 e_image)
            }

            // 2. [추가] 로그 확인: 번호가 제대로 넘어오는지 체크
            System.out.println("교환 신청 주문번호(om_no): " + edto.getOm_no());

            // 3. 교환 테이블 데이터 저장
            odao.insertExchange(edto);

            // 4. [중요/추가] ordermaster 테이블 상태를 '교환신청'으로 변경
            // 이 부분이 빠져있어서 DB 값이 안 변했던 것입니다.
            odao.updateOrderForExchange(edto.getOm_no());
            
            // 5. [중요/추가] product_detail 테이블 상품들 상태도 '교환신청'으로 변경
            odao.updateProductDetailStatus(edto.getOm_no(), "교환신청");

            // 6. 재고 차감 로직 (새 상품 발송분)
            List<productdetailDTO> items = odao.getOrderDetailItems(edto.getOm_no());
            for(productdetailDTO item : items) {
                odao.updateProductStock(item.getP_no(), item.getPd_count());
            }

            rttr.addFlashAttribute("msg", "교환 신청이 완료되었습니다.");
            
        } catch (Exception e) {
            e.printStackTrace();
            rttr.addFlashAttribute("msg", "오류가 발생했습니다: " + e.getMessage());
        }
        
        // m_no=1 고정보다는 DTO의 m_no를 사용하는 것이 안전합니다.
        return "redirect:/orderlist";
    }
    
    @RequestMapping("/reservationForm")
    public String reservationForm(@RequestParam("sr_no") int sr_no, 
                                  @RequestParam("checkIn") String checkIn,
                                  @RequestParam("totalSum") int totalSum,
                                  Model model) {
        // 1. 체크아웃 날짜 계산
        LocalDate inDate = LocalDate.parse(checkIn);
        LocalDate outDate = inDate.plusDays(1);
        
        // 현재 로그인한 유저 정보 가져오기
        String loginId = SecurityContextHolder.getContext().getAuthentication().getName();
        memberDTO member = dao.getMemberByIdDao(loginId);

        // [중요] JSP의 ${loginMember}에서 사용할 수 있도록 모델에 담기
        model.addAttribute("loginMember", member); 

        // 2. 모델에 담아서 결제 폼으로 전달
        model.addAttribute("room", srdao.selectRoomDetail(sr_no));
        model.addAttribute("checkIn", checkIn);           
        model.addAttribute("checkOut", outDate.toString()); 
        model.addAttribute("totalSum", totalSum); 
        
        // member가 null일 경우를 대비한 안전한 처리
        if(member != null) {
            model.addAttribute("m_no", member.getM_no());
        }
        
        model.addAttribute("om_type", "STAY"); 
        
        return "user/ordermaster/orderForm";
    }
    
}

