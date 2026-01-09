package com.carefinder.controller.google;

import jakarta.servlet.http.HttpSession;
import com.carefinder.dto.member.GoogleMemberDTO;
import com.carefinder.dto.member.GooglePeopleDTO;
import com.carefinder.dto.member.GoogleTokenResponseDTO;
import com.carefinder.dto.member.GoogleUserInfoDTO;
import com.carefinder.service.google.GoogleLoginService;
import com.carefinder.service.google.GoogleService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/google")
@RequiredArgsConstructor
public class GoogleController {

    private final GoogleService googleService;
    private final GoogleLoginService googleLoginService;

    @GetMapping("/glogin")
    public String googleLoginRedirect() {

        String clientId =
                "752178699258-runigl7jm4vmoimffkovbvul39lqg0bq.apps.googleusercontent.com";

        // ★ 실제 배포/테스트 환경에 맞춰 포트나 도메인 확인 필요
        String redirectUri =
                "http://localhost:8080/google/gcallback";

        String googleAuthUrl =
                "https://accounts.google.com/o/oauth2/v2/auth"
                        + "?client_id=" + clientId
                        + "&redirect_uri=" + redirectUri
                        + "&response_type=code"
                        + "&scope=email%20profile" // https://www.googleapis.com/auth/userinfo.profile 권장
                        + "&prompt=select_account";

        return "redirect:" + googleAuthUrl;
    }

    @GetMapping("/gcallback")
    public String googleCallback(
            @RequestParam(required = false) String code,
            @RequestParam(required = false) String error,
            HttpSession session
    ) {
        if (error != null) {
            return "redirect:/Nologin?error=social";
        }

        // 1. 토큰 발급
        GoogleTokenResponseDTO token =
                googleService.getAccessToken(code);

        // 2. 유저 정보 조회
        GoogleUserInfoDTO userInfo =
                googleService.getUserInfo(token.getAccessToken());

        // 3. 추가 정보(People API) 조회 (필요한 경우)
        GooglePeopleDTO people =
                googleService.getPeopleInfo(token.getAccessToken());

        // 4. DB 로그인/가입 처리
        GoogleMemberDTO loginUser =
                googleLoginService.loginOrJoin(userInfo, people);

        // ✅ 세션 규칙 완벽 통일 (🔥 핵심 수정)

        // 1. 핵심 PK (DB 조회용)
        session.setAttribute("userPk", loginUser.getMno());

        // 2. 사용자 이름 (index.jsp 헤더 표시용: ${userName})
        // (GoogleMemberDTO에 getName() 메서드가 있어야 함)
        session.setAttribute("userName", loginUser.getName());

        // 3. 로그인 타입 (index.jsp 헤더 표시용: 구글)
        session.setAttribute("loginType", "구글");

        // 4. 전체 DTO (필요 시 사용)
        session.setAttribute("loginUser", loginUser);

        return "redirect:/";
    }
}