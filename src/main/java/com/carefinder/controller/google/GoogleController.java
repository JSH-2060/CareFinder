package com.carefinder.controller.google;

import jakarta.servlet.http.HttpSession;
import com.carefinder.dto.member.GoogleMemberDTO;
import com.carefinder.dto.member.GooglePeopleDTO;
import com.carefinder.dto.member.GoogleTokenResponseDTO;
import com.carefinder.dto.member.GoogleUserInfoDTO;
import com.carefinder.service.google.GoogleLoginService;
import com.carefinder.service.google.GoogleService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
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

    // ✅ application.properties 값 주입
    @Value("${google.oauth.client-id}")
    private String clientId;

    @Value("${google.oauth.redirect-uri}")
    private String redirectUri;

    @GetMapping("/glogin")
    public String googleLoginRedirect() {

        String googleAuthUrl =
                "https://accounts.google.com/o/oauth2/v2/auth"
                        + "?client_id=" + clientId
                        + "&redirect_uri=" + redirectUri
                        + "&response_type=code"
                        + "&scope=email%20profile"
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

        // 3. 추가 정보(People API)
        GooglePeopleDTO people =
                googleService.getPeopleInfo(token.getAccessToken());

        // 4. DB 로그인/가입 처리
        GoogleMemberDTO loginUser =
                googleLoginService.loginOrJoin(userInfo, people);

        // ✅ 세션 통일
        session.setAttribute("userPk", loginUser.getMno());
        session.setAttribute("userName", loginUser.getName());
        session.setAttribute("loginType", "구글");
        session.setAttribute("loginUser", loginUser);

        return "redirect:/";
    }
}
