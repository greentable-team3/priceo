package com.priceo.controller;

import java.io.File;
import java.security.Principal;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.priceo.dao.imagefileDAO;
import com.priceo.dao.memberDAO;
import com.priceo.dao.productDAO;
import com.priceo.dao.reviewDAO;
import com.priceo.dto.imagefileDTO;
import com.priceo.dto.memberDTO;
import com.priceo.dto.productDTO;
import com.priceo.dto.reviewDTO;
import com.priceo.service.ProductSearchService;
import com.priceo.service.ProductService;
import com.priceo.service.PushService;
import com.priceo.service.productfileService;


import jakarta.servlet.http.HttpServletRequest;

@Controller
public class productController {
	
	
	@Autowired
    private ProductService productService;
	
	@Autowired
    private memberController memberController;

    @Autowired
    private productDAO dao;

    @Autowired
    private productfileService pfile;

    @Autowired
    private reviewDAO rdao; // 리뷰 전용 DAO 주입

    @Autowired
    private imagefileDAO iDao; // 상세 이미지 전용 DAO 주입
    
    @Autowired
    private memberDAO mDao;
    
    
    
    @Autowired
    private com.priceo.service.FaqSearchService faqSearchService;

    // 엘라스틱 서치 검색 서비스 주입
    @Autowired
    private ProductSearchService searchService;
    
    @Autowired
    private PushService pushService;

    private String save_path = "C:\\product\\";
    private String review_path = "C:\\productreview\\";

    @RequestMapping("/") // 메인화면
    public String root() {
        return "redirect:/main";
    }

    @RequestMapping("/main")
    public String mainPage(@RequestParam(value="sort", defaultValue="newest") String sort, Model model) {
       // 상품 목록 가져올 때 sort 값 전달
        List<productDTO> plist = dao.getProductList(sort, sort);
        
        model.addAttribute("plist", plist);
        model.addAttribute("sort", sort); // 현재 정렬 상태 유지용
        return "main"; 
    }

    @RequestMapping("/pinsertForm") // 상품 등록폼 
    public String finsertForm() {   
        return "admin/pinsertForm";
    }

    @RequestMapping("/pinsert") // 상품 등록
    public String pinsert(productDTO dto, 
                          @RequestParam("p_imagefilename") MultipartFile pimageFile,
                          @RequestParam("p_infofilename") MultipartFile[] pinfoFile,
                          HttpServletRequest request) throws Exception {
        
        // --- [절대 안 건드림] 기존 로직 시작 ---
        if (!pimageFile.isEmpty()) {
            String name2 = pfile.upload(pimageFile); 
            dto.setP_image(name2);
        }
        dto.setP_view(0); 

        dao.pinsertDao(dto);
        
        for (MultipartFile file : pinfoFile) {
            if (!file.isEmpty()) {
                String saveName = UUID.randomUUID().toString() + "_sub_" + file.getOriginalFilename();
                file.transferTo(new File(save_path + saveName));
                imagefileDTO imgDto = new imagefileDTO();
                imgDto.setI_referenceno(dto.getP_no());
                imgDto.setI_referencetype("product");
                imgDto.setI_originalfile(file.getOriginalFilename());
                imgDto.setI_savefile(saveName);
                imgDto.setI_root(save_path);
                iDao.insertImage(imgDto); 
            }
        }
        
        try {
            List<memberDTO> allMembers = mDao.listDao(); 
            if (allMembers != null && !allMembers.isEmpty()) {
                String scheme = request.getScheme();
                String serverName = request.getServerName();
                int serverPort = request.getServerPort();
                String contextPath = request.getContextPath();
                String baseAddr = scheme + "://" + serverName + ":" + serverPort + contextPath + "/product/";
                String fullImageUrl = baseAddr + dto.getP_image();
                int currentPno = dto.getP_no(); 
                for (memberDTO m : allMembers) {
                    String token = m.getFcm_token(); 
                    if (token != null && !token.trim().isEmpty()) {
                        pushService.sendPush(m.getM_no(), token, "🎁 신상 입고! [" + dto.getP_name() + "]", 
                                            "새로운 상품이 등록되었습니다.", fullImageUrl, currentPno);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println(">>> [푸시 에러]: " + e.getMessage());
        }
        // --- [절대 안 건드림] 기존 로직 끝 ---

        // 🥊 [수정 완료] 전체 동기화 대신, 방금 등록한 dto만 즉시 ES에 반영합니다.
        productService.saveProductToElastic(dto); 

        return "redirect:/plist"; 
    }

    @RequestMapping("/plist") // 상품 목록
    public String plist(@RequestParam(value="p_category", required=false) String p_category, 
          @RequestParam(value="sort", defaultValue="") String sort, Model model) {
       // List<productDTO> list = dao.plistDao(p_category);
       
       List<productDTO> list = dao.getProductList(p_category, sort);
        model.addAttribute("list", list);
        model.addAttribute("selectedCategory", p_category);
        model.addAttribute("sort", sort);
        return "user/product/plist";
    }

    @RequestMapping("/pdetail") // 상품 상세보기
    public String pdetail(@RequestParam("p_no") int p_no, Model model, Principal principal) {
        dao.pviewUpDao(p_no);
        productDTO dto = dao.pdetailDao(p_no);
        
        if (principal != null) {
            String mid = principal.getName();
            int loginMemberNo = mDao.findByMid(mid).getM_no();
            model.addAttribute("loginMemberNo", loginMemberNo);
        }

        imagefileDTO searchDto = new imagefileDTO();
        searchDto.setI_referenceno(p_no);
        searchDto.setI_referencetype("product");
        List<imagefileDTO> imageList = iDao.selectImagesByRef(searchDto);
        
        List<reviewDTO> reviewList = rdao.rlistByType(p_no, "PRODUCT");
        
        for(reviewDTO r : reviewList) {
            imagefileDTO revImgSearch = new imagefileDTO();
            revImgSearch.setI_referenceno(r.getR_no());
            revImgSearch.setI_referencetype("review");
            r.setReviewImages(iDao.selectImagesByRef(revImgSearch));
        }
        
        double avgScore = 0.0;
        if (reviewList != null && !reviewList.isEmpty()) {
            avgScore = reviewList.stream()
                                 .mapToInt(r -> Integer.parseInt(r.getR_score()))
                                 .average()
                                 .orElse(0.0);
        }
        
        model.addAttribute("reviewList", reviewList);
        model.addAttribute("dto", dto);
        model.addAttribute("imageList", imageList);
        model.addAttribute("avgScore", avgScore);
        
        return "user/product/pdetail"; 
    }

    @RequestMapping("/pdelete") // 상품 삭제
    public String pdelete(@RequestParam("p_no") int p_no) {
        // 1. 리뷰 및 이미지 파일 삭제 (기존 로직 유지)
        List<reviewDTO> reviewList = rdao.rlistByType(p_no, "PRODUCT");
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
        
        rdao.deleteReviewsByItem(p_no, "PRODUCT");
        
        imagefileDTO searchDto = new imagefileDTO();
        searchDto.setI_referenceno(p_no);
        searchDto.setI_referencetype("product");
        List<imagefileDTO> imageList = iDao.selectImagesByRef(searchDto);
        
        for(imagefileDTO img : imageList) {
            File f = new File(save_path + img.getI_savefile());
            if(f.exists()) f.delete();
        }
        iDao.deleteImagesByRef(searchDto);
        
        productDTO dto = dao.pdetailDao(p_no);
        if (dto != null && dto.getP_image() != null) {
            File f = new File(save_path + dto.getP_image());
            if(f.exists()) f.delete();
        }

        // ----------------------------------------------------
        // 🥊 [수정 완료] DB 삭제와 ES 삭제를 각각 진행합니다.
        // ----------------------------------------------------
        // 1. DB에서 먼저 삭제
        dao.pdeleteDao(p_no);
        
        // 2. ProductService를 통해 ES 인덱스 삭제 및 인기 리스트 갱신
        productService.deleteProductAndRefreshTotal(p_no); 
        // ----------------------------------------------------

        return "redirect:/plist";
    }

    @RequestMapping("/pupdateForm") // 상품 수정 폼
    public String pupdateForm(@RequestParam("p_no") int p_no, Model model) {
        productDTO dto = dao.pdetailDao(p_no);
        model.addAttribute("dto", dto);
        return "admin/pupdateForm";
    }

    @RequestMapping("/pupdate")
    public String pupdate(@RequestParam("p_no") int p_no, @RequestParam("p_price") int p_price) {
        productDTO dto = dao.pdetailDao(p_no);
        dto.setP_price(p_price);
        dao.pupdateDao(dto);
        
        // 🥊 [수정] searchService 대신 productService 호출!
        productService.saveProductToElastic(dto); 

        return "redirect:/pdetail?p_no=" + p_no;
    }

    // --- 리뷰 관련 메서드 ---

    @RequestMapping("/productReviewInsert")
    public String productReviewInsert(reviewDTO rdto, 
                                      @RequestParam("uploadFiles") MultipartFile[] files) throws Exception {
        rdao.rinsertDao(rdto); 
        int r_no = rdto.getR_no();

        if (files != null && files.length > 0) {
            File saveDir = new File(review_path);
            if (!saveDir.exists()) saveDir.mkdirs();

            for (MultipartFile file : files) {
                if (!file.isEmpty()) {
                    String fileName = UUID.randomUUID().toString() + "_rev_" + file.getOriginalFilename();
                    file.transferTo(new File(review_path + fileName));

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
        return "redirect:/pdetail?p_no=" + rdto.getR_typeno();
    }

    @RequestMapping("/productReviewDelete")
    public String stayReviewDelete(@RequestParam("r_no") int r_no, @RequestParam("p_no") int p_no) {
        imagefileDTO searchDto = new imagefileDTO();
        searchDto.setI_referenceno(r_no);
        searchDto.setI_referencetype("review");
        List<imagefileDTO> imgList = iDao.selectImagesByRef(searchDto);
        
        for(imagefileDTO img : imgList) {
            File f = new File(review_path + img.getI_savefile());
            if(f.exists()) f.delete();
        }
        
        iDao.deleteImagesByRef(searchDto);
        rdao.rdeleteDao(r_no);
        
        return "redirect:/pdetail?p_no=" + p_no;
    }


    
 // ////////////////////////////////////////////////////////// 인기순 출력
    @GetMapping("/api/main/popular")
    @ResponseBody // 👈 이 어노테이션을 추가하세요! (JSON 데이터를 직접 반환함)
    public List<productDTO> getPopular(Model model) {
        List<productDTO> popularList = dao.getPopularList();
        // model.addAttribute는 필요 없습니다. 그냥 리스트를 바로 리턴하세요.
        return popularList; 
    }
    
    
}