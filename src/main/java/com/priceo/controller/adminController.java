package com.priceo.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.priceo.dao.ordermasterDAO;
import com.priceo.dao.productDAO;
import com.priceo.dao.reviewDAO;
import com.priceo.dao.stayDAO;
import com.priceo.dto.reviewDTO;

@Controller
public class adminController {
	
	@Autowired
    private reviewDAO rdao; // 리뷰 전용 DAO
	
	@Autowired
    private ordermasterDAO odao;
	
	@Autowired
	private com.priceo.dao.imagefileDAO idao;
	
	@Autowired
	private productDAO pdao;
	   
	@Autowired
	private stayDAO sdao;
	
	@RequestMapping("/adminhome") // 관리자화면
	public String adminhome() {
	   return "admin/adminhome";
	}	

	// 1. 전체 리뷰 목록 조회
    @RequestMapping("/adminreviewlist")
    public String adminreviewlist(@RequestParam(value="page", defaultValue="1") int page, Model model) {
       int size = 10; // 한 페이지당 보여줄 개수
       int navSize = 10; // 하단에 보여줄 페이지 버튼 개수
        int start = (page - 1) * size + 1;
        int end = page * size;
        
        // 1. 해당 페이지의 리뷰 15개만 가져오기
        List<reviewDTO> rlist = rdao.getListWithPaging(start, end);
        
        // 2. 전체 리뷰 개수 가져오기 (페이지 버튼 계산용)
        int totalCount = rdao.getTotalCount();
        int totalPage = (int) Math.ceil((double) totalCount / size);
        
        // --- 추가된 페이징 그룹 계산 로직 ---
        int startPage = ((page - 1) / navSize) * navSize + 1;
        int endPage = startPage + navSize - 1;
        if (endPage > totalPage) endPage = totalPage;
        
        model.addAttribute("rlist", rlist);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPage", totalPage);
        model.addAttribute("startPage", startPage); // 추가
        model.addAttribute("endPage", endPage);     // 추가

        return "admin/adminreviewlist";
        
    }

    // 2. 삭제 메서드 수정
    @RequestMapping("/deleteReview") // 게시글/숙소 삭제 통합 메서드
    @ResponseBody
    public String deleteReview(@RequestParam("no") int no, @RequestParam("type") String type) {
        try {
            // 1. 해당 게시글(상품/숙소)에 달린 모든 리뷰 번호 리스트 조회
           List<Integer> reviewNos = rdao.getReviewNosByItem(type, no);

            // 2. 각 리뷰를 순회하며 파일 및 DB 데이터 삭제
            if (reviewNos != null) {
                for (int r_no : reviewNos) {
                    // 이미지 정보 조회용 DTO 설정
                    com.priceo.dto.imagefileDTO searchDto = new com.priceo.dto.imagefileDTO();
                    searchDto.setI_referenceno(r_no);
                    searchDto.setI_referencetype("review");

                    // 실제 물리 파일 삭제
                    List<com.priceo.dto.imagefileDTO> imgList = idao.selectImagesByRef(searchDto);
                    if (imgList != null && !imgList.isEmpty()) {
                        for (com.priceo.dto.imagefileDTO img : imgList) {
                            java.io.File file = new java.io.File(img.getI_root() + img.getI_savefile());
                            if (file.exists()) {
                                file.delete();
                            }
                        }
                    }

                    // [중요] DB 삭제 로직이 for문 안으로 들어와야 함
                    idao.deleteImagesByRef(searchDto); // 리뷰 이미지 DB 삭제
                    rdao.rdeleteDao(r_no);             // 리뷰 본문 DB 삭제
                }
            }

            // 3. 마지막으로 게시글(상품/숙소) 본체 삭제
            if ("PRODUCT".equals(type)) {
                pdao.pdeleteDao(no);
            } else if ("STAY".equals(type)) {
                sdao.deleteStay(no);
            }

            return "success";
        } catch (Exception e) {
            e.printStackTrace();
            return "error";
        }
    }
    

    @RequestMapping("/adminorderlist") // 모든 회원의 주문목록
    public String adminorderlist(Model model) {
        // 모든 회원의 주문 내역을 가져옴
        List<Map<String, Object>> allOrders = odao.selectAllOrders();
        model.addAttribute("orderList", allOrders);
        return "admin/adminorderlist";
    }
    
    
    @RequestMapping("/adminorderdetail") // 모든 회원의 주문목록 상세보기
    public String adminorderdetail(@RequestParam("om_no") int om_no, Model model) {
        // 1. 주문 정보 + 교환 정보
        Map<String, Object> orderInfo = odao.selectAdminOrderDetail(om_no);
        // 2. 주문 상품 목록
        List<Map<String, Object>> itemList = odao.selectAdminOrderItems(om_no);

        model.addAttribute("order", orderInfo);
        model.addAttribute("items", itemList);
        
        return "admin/adminorderdetail";
    }
    
    @RequestMapping("/updateStatus")
    @ResponseBody
    public String updateStatus(@RequestParam("om_no") int om_no, 
                               @RequestParam("pd_state") String pd_state) { // om_type 대신 pd_state 사용
        try {
            // 서비스 거치지 않고 DAO 메서드 바로 호출
            odao.updateProductState(om_no, pd_state); 
            
            return "success";
        } catch (Exception e) {
            return "error: " + e.getMessage();
        }
    }
    
   
    
}

