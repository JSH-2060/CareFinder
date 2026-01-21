package com.carefinder.controller.kakao;

import jakarta.servlet.http.HttpSession;
import com.carefinder.dto.member.MemberKakaoDTO;
import com.carefinder.service.kakao.MemberKakaoService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Map;

@Slf4j
@Controller
@RequiredArgsConstructor
public class KakaoController {

    private final KakaoApi kakaoApi;
    private final MemberKakaoService memberService;

    @GetMapping("/klogin")
    public String kakaoLoginRedirect() {
        String kakaoAuthUrl =
                "https://kauth.kakao.com/oauth/authorize"
                        + "?client_id=" + kakaoApi.getKakaoApikey()
                        + "&redirect_uri=" + kakaoApi.getKakaoRedirectUrl()
                        + "&response_type=code";

        return "redirect:" + kakaoAuthUrl;
    }

    @GetMapping("/login/oauth2/code/kakao")
    public String kakaoCallback(@RequestParam String code, HttpSession session) {

        String accessToken = kakaoApi.getAccessToken(code);
        Map<String, Object> kakaoUser = kakaoApi.getUserInfo(accessToken);

        MemberKakaoDTO member = memberService.kakaoLogin(kakaoUser);

        //세션
        session.setAttribute("userPk", member.getMno()); // PK 저장
        session.setAttribute("loginUser", member);       // DTO 전체 저장

        session.setAttribute("userName", member.getName());

        session.setAttribute("loginType", "KAKAO");

        return "redirect:/";
    }
}