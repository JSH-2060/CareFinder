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

        // ✅ 세션 구조 통일
        session.setAttribute("userPk", member.getMno()); // PK 저장
        session.setAttribute("loginUser", member);       // DTO 전체 저장

        // ★ [핵심 수정] 이 줄이 없어서 이름이 안 나왔던 겁니다! ★
        // (DTO에 이름 필드가 name인지 nickname인지 확인하세요. 보통 KakaoDTO는 nickname일 수 있습니다)
        // 만약 DTO에 getName()이 있다면:
        session.setAttribute("userName", member.getName());

        // 만약 DTO에 getNickname()이라면:
        // session.setAttribute("userName", member.getNickname());

        // 로그인 타입도 명시해주면 좋습니다 (JSP에서 괄호 안에 넣는 용도)
        session.setAttribute("loginType", "KAKAO");

        return "redirect:/";
    }
}