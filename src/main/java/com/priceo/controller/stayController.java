package com.priceo.controller;

import java.io.File;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.priceo.dao.imagefileDAO;
import com.priceo.dao.memberDAO;
import com.priceo.dao.reviewDAO;
import com.priceo.dao.stayCalendarDAO;
import com.priceo.dao.stayDAO;
import com.priceo.dao.stayDetailDAO;
import com.priceo.dao.stayRoomDAO;
import com.priceo.dto.imagefileDTO;
import com.priceo.dto.memberDTO;
import com.priceo.dto.reviewDTO;
import com.priceo.dto.stayDTO;
import com.priceo.dto.stayRoomDTO;
import com.priceo.service.FaqSearchService;
import com.priceo.service.ProductService;
import com.priceo.service.PushService;

import jakarta.servlet.http.HttpServletRequest;

@Controller
public class stayController {
	
	@Autowired
	private FaqSearchService faqSearchService;

    @Autowired
    private stayDAO dao;
    
    @Autowired
    private imagefileDAO iDao; // 상세 이미지 전용 DAO 주입
    
    @Autowired
    private stayRoomDAO srDao; // 객실 정보용 DAO 추가
    
    @Autowired
    private stayCalendarDAO scDao;
    
    @Autowired
    private stayDetailDAO sdDao;
    
    @Autowired
    private memberDAO mDao;
    
    @Autowired
    private reviewDAO rDao; // 리뷰 DAO 주입
    
    @Autowired
    private PushService pushService;
    
    @Autowired
    private ProductService productService;
    
    
    // 숙소 대표/상세 이미지 경로
    private final String save_path = "C:/stay/";
    
    // 숙소 리뷰 이미지 경로 (추가)
    private final String review_path = "C:/stayreview/";

    // 1. 숙소 전체 목록 보기
    @RequestMapping("/stayList")
    public String list(@RequestParam(value="sort", defaultValue="newest") String sort, Model model) {
        // List<stayDTO> list = dao.selectStayList();
        
        List<stayDTO> list = dao.getStayList(sort);
        model.addAttribute("list", list);
        return "user/stay/slist"; // slist.jsp로 이동
    }

    // 2. 숙소 등록 폼으로 이동
    @RequestMapping("/stayInsertForm")
    public String insertForm() {
        return "admin/sinsertForm"; // sinsertForm.jsp로 이동
    }

    // 3. 숙소 실제 등록 처리 (상세 이미지 다중 처리)
    @RequestMapping("/stayInsert")
    public String insert(stayDTO dto, 
            @RequestParam("imageFile") MultipartFile imageFile,
            @RequestParam("infoFiles") MultipartFile[] infoFiles,
            HttpServletRequest request) throws Exception { // 배열로 변경
        
        File saveDir = new File(save_path);
        if (!saveDir.exists()) saveDir.mkdirs();

        // 1. 대표 이미지 업로드 (stay 테이블용)
        if (!imageFile.isEmpty()) {
            String fileName = UUID.randomUUID().toString() + "_" + imageFile.getOriginalFilename();
            imageFile.transferTo(new File(save_path + fileName));
            dto.setS_image(fileName);
        }

        // 2. 숙소 기본 정보 저장 (XML의 selectKey 덕분에 s_no가 dto에 자동으로 채워짐)
        dao.insertStay(dto);
        int s_no = dto.getS_no(); // 생성된 번호 가져오기

        // 3. 상세 이미지들 업로드 및 DB 저장 (imagefile 테이블용)
        for (MultipartFile file : infoFiles) {
            if (!file.isEmpty()) {
                String saveName = UUID.randomUUID().toString() + "_sub_" + file.getOriginalFilename();
                file.transferTo(new File(save_path + saveName));

                // imagefileDTO 객체 생성 및 데이터 세팅
                imagefileDTO imgDto = new imagefileDTO();
                imgDto.setI_referenceno(s_no);      // 방금 생성된 숙소 번호
                imgDto.setI_referencetype("stay");  // 타입 지정
                imgDto.setI_originalfile(file.getOriginalFilename());
                imgDto.setI_savefile(saveName);
                imgDto.setI_root(save_path);

                iDao.insertImage(imgDto); // imagefileDAO를 통해 저장
            }
        }
        System.out.println(">>> [3] 알람 로직 진입"); // 추적 로그
        try {
            List<memberDTO> allMembers = mDao.listDao(); 
            System.out.println(">>> [4] 회원 리스트 조회 성공 - 회원수: " + (allMembers != null ? allMembers.size() : "null"));

            if (allMembers != null && !allMembers.isEmpty()) {
                String scheme = request.getScheme();
                String serverName = request.getServerName();
                int serverPort = request.getServerPort();
                String contextPath = request.getContextPath();
                String baseAddr = scheme + "://" + serverName + ":" + serverPort + contextPath + "/stay/";
                String fullImageUrl = baseAddr + dto.getS_image();
                
                System.out.println(">>> [5] 발송 준비 완료 - 이미지주소: " + fullImageUrl);

                for (memberDTO m : allMembers) {
                    String token = m.getFcm_token(); 
                    if (token != null && !token.trim().isEmpty()) {
                        pushService.sendStayPush(m.getM_no(), token, "🏨 신규 숙소 오픈! [" + dto.getS_name() + "]", 
                                            "지금 바로 예약 가능한 숙소를 확인하세요.", fullImageUrl, s_no);
                    }
                }
                System.out.println(">>> [6] 모든 회원에게 발송 시도 완료");
            } else {
                System.out.println(">>> [!] 알림을 보낼 회원이 없습니다 (리스트가 비어있음)");
            }
        } catch (Exception e) {
            System.err.println(">>> [!] 알람 발송 중 에러 발생: " + e.getMessage());
            e.printStackTrace();
        }
     // 🥊 [핵심 추가] 등록된 숙소를 ES에도 즉시 반영
        productService.saveStayToElastic(dto); 

        return "redirect:/stayList";
    }

    // 4. 숙소 상세보기 (지도 정보 + 다중 이미지 리스트 + 리뷰 추가)
    @RequestMapping("/stayDetail")
    public String detail(@RequestParam("s_no") Integer s_no, Model model, Authentication auth) {
        dao.updateViewCount(s_no);
        
        // 숙소 기본 정보
        stayDTO dto = dao.selectStayDetail(s_no);
        
        // 해당 숙소에 딸린 객실 목록 가져오기
        List<stayRoomDTO> roomList = srDao.selectRoomsByStay(s_no);
        
        // [중요] 해당 숙소에 달린 상세 이미지 리스트 가져오기
        imagefileDTO searchDto = new imagefileDTO();
        searchDto.setI_referenceno(s_no);
        searchDto.setI_referencetype("stay");
        List<imagefileDTO> imageList = iDao.selectImagesByRef(searchDto);
        
        // 해당 숙소의 리뷰 목록 가져오기
        List<reviewDTO> reviewList = rDao.rlistByType(s_no, "STAY");
        
        // 각 리뷰마다 딸린 다중 이미지들을 imagefile 테이블에서 가져오기
        for(reviewDTO r : reviewList) {
            imagefileDTO revImgSearch = new imagefileDTO();
            revImgSearch.setI_referenceno(r.getR_no());
            revImgSearch.setI_referencetype("review");
            // reviewDTO에 추가한 List<imagefileDTO> reviewImages 필드에 세팅
            r.setReviewImages(iDao.selectImagesByRef(revImgSearch));
        }
        
        // 평균 평점 계산 (자바 로직으로 처리)
        double avgScore = 0.0;
        if (reviewList != null && !reviewList.isEmpty()) {
            avgScore = reviewList.stream()
                                 .mapToInt(r -> Integer.parseInt(r.getR_score()))
                                 .average()
                                 .orElse(0.0);
        }
        
        // 추가: 현재 로그인한 사용자의 번호를 JSP로 전달
        if (auth != null && auth.isAuthenticated()) {
            // [수정] 직접 형변환 하지 않고 별도 메서드나 타입 체크를 사용합니다.
            String username = "";
            Object principal = auth.getPrincipal();

            if (principal instanceof UserDetails) {
                username = ((UserDetails) principal).getUsername();
            } else if (principal instanceof org.springframework.security.oauth2.core.user.OAuth2User) {
                // 소셜 로그인인 경우 (보통 'sub'나 'email' 속성을 ID로 사용)
                org.springframework.security.oauth2.core.user.OAuth2User oauth2User = (org.springframework.security.oauth2.core.user.OAuth2User) principal;
                // 구글/카카오는 "email"이나 "sub" 등을 키로 사용합니다. 설정에 맞춰 수정 필요할 수 있음.
                username = oauth2User.getAttribute("email") != null ? oauth2User.getAttribute("email") : oauth2User.getName();
            }

            memberDTO loginMember = mDao.findByMid(username); 
            if (loginMember != null) {
                model.addAttribute("loginMemberNo", loginMember.getM_no());
            }
        }
        
        model.addAttribute("reviewList", reviewList); // JSP의 forEach 문에 연결
        model.addAttribute("avgScore", avgScore);     // 상단 별점 표시에 연결
        model.addAttribute("dto", dto);
        model.addAttribute("roomList", roomList);
        model.addAttribute("imageList", imageList); // JSP에서 forEach로 출력 예정
        
        return "user/stay/sdetail"; // sdetail.jsp로 이동
    }

    // 5. 숙소 수정 폼으로 이동 (기존 데이터 로드)
    @RequestMapping("/stayUpdateForm")
    public String updateForm(@RequestParam("s_no") Integer s_no, Model model) {
        stayDTO dto = dao.selectStayDetail(s_no);
        model.addAttribute("dto", dto);
        return "admin/supdateForm"; // supdateForm.jsp로 이동
    }

    // 6. 숙소 실제 수정 처리
    @RequestMapping("/stayUpdate")
    public String update(stayDTO dto,
                         @RequestParam("imageFile") MultipartFile imageFile) throws Exception {
        
    	if (!imageFile.isEmpty()) {
            stayDTO oldData = dao.selectStayDetail(dto.getS_no());
            if(oldData.getS_image() != null) {
                File oldFile = new File(save_path + oldData.getS_image());
                if(oldFile.exists()) oldFile.delete();
            }

            String fileName = UUID.randomUUID().toString() + "_" + imageFile.getOriginalFilename();
            imageFile.transferTo(new File(save_path + fileName));
            dto.setS_image(fileName);
        } 
        dao.updateStay(dto);
        productService.saveStayToElastic(dto); 

        return "redirect:/stayDetail?s_no=" + dto.getS_no();
    }

 // 7. 숙소 삭제 처리
 // 7. 숙소 삭제 처리 (ES 반영 수정)
    @RequestMapping("/stayDelete")
    @Transactional
    public String delete(@RequestParam("s_no") Integer s_no) {
        
        // 1. 리뷰 및 리뷰 이미지 파일 삭제
        List<reviewDTO> reviewList = rDao.rlistByType(s_no, "STAY");
        for(reviewDTO r : reviewList) {
            imagefileDTO imgSearch = new imagefileDTO();
            imgSearch.setI_referenceno(r.getR_no());
            imgSearch.setI_referencetype("review");
            List<imagefileDTO> revImgs = iDao.selectImagesByRef(imgSearch);
            
            for(imagefileDTO img : revImgs) {
                File f = new File(review_path + img.getI_savefile());
                if(f.exists()) f.delete();
            }
            iDao.deleteImagesByRef(imgSearch); 
        }
        
        // 2. 관련 데이터(리뷰, 상세, 캘린더, 객실) DB 삭제
        rDao.deleteReviewsByItem(s_no, "STAY");
        sdDao.deleteStayDetailByStay(s_no);
        scDao.deleteCalendarByStay(s_no);
        srDao.deleteRoomsByStay(s_no);
        
        // 3. 상세 이미지 파일 및 DB 데이터 삭제
        imagefileDTO searchDto = new imagefileDTO();
        searchDto.setI_referenceno(s_no);
        searchDto.setI_referencetype("stay");
        List<imagefileDTO> imageList = iDao.selectImagesByRef(searchDto);
        
        for(imagefileDTO img : imageList) {
            File f = new File(save_path + img.getI_savefile());
            if(f.exists()) f.delete();
        }
        iDao.deleteImagesByRef(searchDto);

        // 4. 대표 이미지 파일 삭제를 위해 정보 미리 가져오기
        stayDTO stayData = dao.selectStayDetail(s_no);
        if (stayData != null && stayData.getS_image() != null) {
            File f = new File(save_path + stayData.getS_image());
            if(f.exists()) f.delete();
        }

        // 1. DB에서 숙소 삭제
        dao.deleteStay(s_no);
        
        // 2. ProductService를 통해 ES 인덱스 삭제 및 인기 리스트 갱신
        // (기존 searchService에 있던 로직을 productService가 대신 수행)
        productService.deleteStayAndRefreshTotal(s_no); 
        // ----------------------------------------------------
        
        return "redirect:/stayList";
        
    }
    
    @RequestMapping("/stayReviewInsert")
    public String stayReviewInsert(reviewDTO rdto, 
                               @RequestParam("uploadFiles") MultipartFile[] files) throws Exception {
        
    	// 1. 리뷰 본문 먼저 저장 (XML의 selectKey 덕분에 r_no가 rdto에 자동으로 들어옴)
        rDao.rinsertDao(rdto); 
        int r_no = rdto.getR_no();

        // 2. 여러 개의 파일 처리
        if (files != null && files.length > 0) {
            File saveDir = new File(review_path);
            if (!saveDir.exists()) saveDir.mkdirs();

            for (MultipartFile file : files) {
                if (!file.isEmpty()) {
                    String fileName = UUID.randomUUID().toString() + "_rev_" + file.getOriginalFilename();
                    file.transferTo(new File(review_path + fileName));

                    // imagefileDTO에 데이터 담아서 iDao로 저장
                    imagefileDTO imgDto = new imagefileDTO();
                    imgDto.setI_referenceno(r_no);
                    imgDto.setI_referencetype("review");
                    imgDto.setI_originalfile(file.getOriginalFilename());
                    imgDto.setI_savefile(fileName);
                    imgDto.setI_root(review_path);

                    iDao.insertImage(imgDto);
                }
            }
        }

        // 등록 후 다시 숙소 상세페이지로 리다이렉트
        return "redirect:/stayDetail?s_no=" + rdto.getR_typeno();
    }
    
    @RequestMapping("/stayReviewDelete")
    public String stayReviewDelete(@RequestParam("r_no") int r_no, 
                                   @RequestParam("s_no") int s_no, 
                                   Authentication auth) {

	    	// 1. 리뷰 정보 가져오기 (r_no로 DB 조회)
	        reviewDTO rdto = rDao.getReviewDetail(r_no); 
	
	        // [수정] 로그인 방식에 따른 ID 추출
	        String username = "";
	        Object principal = auth.getPrincipal();
	        if (principal instanceof UserDetails) {
	            username = ((UserDetails) principal).getUsername();
	        } else if (principal instanceof org.springframework.security.oauth2.core.user.OAuth2User) {
	            org.springframework.security.oauth2.core.user.OAuth2User oauth2User = (org.springframework.security.oauth2.core.user.OAuth2User) principal;
	            username = oauth2User.getAttribute("email") != null ? oauth2User.getAttribute("email") : oauth2User.getName();
	        }

	        memberDTO loginMember = mDao.findByMid(username); 
	        if (loginMember == null) return "redirect:/login"; // 로그인 정보 없으면 튕김 처리

	        int loginMemberNo = loginMember.getM_no();
	
	        // 3. 관리자 여부 확인
	        boolean isAdmin = auth.getAuthorities().stream()
	                              .anyMatch(a -> a.getAuthority().equals("ADMIN"));
	
	        // 4. 권한 체크: 관리자(1번 등)이거나 작성자 번호가 일치할 때
	        if (isAdmin || rdto.getM_no() == loginMemberNo) {
            
            imagefileDTO searchDto = new imagefileDTO();
            searchDto.setI_referenceno(r_no);
            searchDto.setI_referencetype("review");
            List<imagefileDTO> imgList = iDao.selectImagesByRef(searchDto);
            
            for(imagefileDTO img : imgList) {
                File f = new File(review_path + img.getI_savefile());
                if(f.exists()) f.delete();
            }
            
            iDao.deleteImagesByRef(searchDto); // DB 이미지 정보 삭제
            rDao.rdeleteDao(r_no);            // DB 리뷰 본문 삭제
            
        }

        return "redirect:/stayDetail?s_no=" + s_no;
    }
    
    @GetMapping("/stay/autocomplete") // 🥊 JS에서 호출하는 URL이랑 똑같은지!
    @ResponseBody
    public List<String> stayAutocomplete(@RequestParam("q") String q) {
        return faqSearchService.autocompleteStays(q);
    }
    

}