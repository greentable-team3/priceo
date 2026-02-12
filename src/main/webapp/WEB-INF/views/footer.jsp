<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
    footer {
        background-color: #f8f9fa; 
        border-top: 1px solid #e9ecef;
        padding: 50px 0; 
        font-family: 'Pretendard', sans-serif;
        color: #333;
        flex-shrink: 0;
    }
    .footer-container {
        max-width: 1200px;
        margin: 0 auto;
        display: flex;
        justify-content: space-between;
        padding: 0 40px;
    }
    .footer-left { flex: 2; }
    .footer-logo {
        font-size: 30px;
        font-weight: 900;
        letter-spacing: -1.5px;
        margin-bottom: 25px;
        color: #212529;
    }
    .company-info { font-size: 13px; line-height: 1.8; color: #6c757d; }
    .company-info span { margin-right: 15px; }
    .copyright { margin-top: 25px; font-size: 13px; color: #adb5bd; }
    .footer-right { flex: 1; display: flex; flex-direction: column; gap: 20px; text-align: left; }
    .info-title { font-size: 14px; font-weight: 700; margin-bottom: 5px; color: #495057; }
    .cs-number { font-size: 26px; font-weight: 800; margin-bottom: 5px; color: #212529; }
    .footer-btns { display: flex; gap: 10px; margin-top: 10px; margin-bottom: 10px; }
    .cs-hours { font-size: 13px; color: #868e96; line-height: 1.8; }
    .footer-btn {
        display: inline-block;
        background-color: #1e3a8a;
        color: #fff !important;
        padding: 12px 18px;
        border-radius: 6px;
        font-size: 13px;
        font-weight: 600;
        text-align: center;
        text-decoration: none;
        transition: all 0.2s;
        flex: 1;
    }
    .footer-btn:hover { background-color: #0056b3; transform: translateY(-2px); }
    .btn-faq { background-color: #6c757d; }
    .btn-faq:hover { background-color: #495057; }
</style>

<footer>
    <div class="footer-container">
        <div class="footer-left">
            <div class="footer-logo">PRICEO</div>
            <div class="company-info">
                <span>상호명 : 프라이스오(주)</span> <span>대표 : 김관리</span><br>
                <span>주소 : 부산광역시 진구 어느길 123 (PRICEO 빌딩)</span><br>
                <span>사업자등록번호 : 123-45-67890</span> <span>통신판매업신고 : 2026-부산진구-0123</span><br>
                <span>개인정보보호책임자 : 김대표</span> <span>E-mail : priceo@priceo.com</span>
            </div>
            <div class="copyright">
                © 2026 PRICEO Inc. All rights reserved.
            </div>
        </div>
        <div class="footer-right">
            <div class="cs-area">
                <div class="info-title">고객센터</div>
                <div class="cs-number">070-1234-5678</div>
                <div class="footer-btns">
                    <a href="/partner/partnerApply" class="footer-btn">입점문의</a>
                    <a href="/mfaq" class="footer-btn btn-faq">자주 묻는 질문</a>
                </div>
                <div class="cs-hours">
                    주중 09:30 ~ 17:30<br>
                    주말 및 공휴일 휴무
                </div>
            </div>
        </div>
    </div>
</footer>