package com.carefinder.service.naver;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import com.carefinder.dao.member.NaverDAO;
import com.carefinder.dto.member.NaverDTO; // ★ member 패키지 확인
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.math.BigInteger;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.security.SecureRandom;

@Service
public class NaverService {

    @Autowired
    private NaverDAO naverDAO;

    @Value("${naver.client.id}") private String clientId;
    @Value("${naver.client.secret}") private String clientSecret;
    @Value("${naver.redirect.uri}") private String redirectUri;

    // [1] 로그인 인증 URL 생성
    public String getAuthorizationUrl(HttpSession session) {
        String state = new BigInteger(130, new SecureRandom()).toString(32);
        session.setAttribute("state", state);
        return "https://nid.naver.com/oauth2.0/authorize?response_type=code"
                + "&client_id=" + clientId
                + "&redirect_uri=" + URLEncoder.encode(redirectUri, java.nio.charset.StandardCharsets.UTF_8)
                + "&state=" + state;
    }

    // [2] 접근 토큰 발급
    public String getAccessToken(String code, String state) {
        String apiURL = "https://nid.naver.com/oauth2.0/token?grant_type=authorization_code"
                + "&client_id=" + clientId + "&client_secret=" + clientSecret
                + "&code=" + code + "&state=" + state;
        try {
            URL url = new URL(apiURL);
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setRequestMethod("GET");
            BufferedReader br = new BufferedReader(new InputStreamReader(
                    con.getResponseCode() == 200 ? con.getInputStream() : con.getErrorStream()));
            StringBuilder res = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) res.append(line);
            br.close();

            JsonNode root = new ObjectMapper().readTree(res.toString());
            return root.has("access_token") ? root.get("access_token").asText() : null;
        } catch (Exception e) { e.printStackTrace(); return null; }
    }

    // [3] 사용자 프로필 조회
    public NaverDTO getUserProfile(String accessToken) {
        try {
            URL url = new URL("https://openapi.naver.com/v1/nid/me");
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setRequestProperty("Authorization", "Bearer " + accessToken);

            BufferedReader br = new BufferedReader(new InputStreamReader(
                    con.getResponseCode() == 200 ? con.getInputStream() : con.getErrorStream()));
            StringBuilder res = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) res.append(line);
            br.close();

            System.out.println("네이버 응답: " + res.toString());

            JsonNode response = new ObjectMapper().readTree(res.toString()).get("response");
            if (response == null) return null;

            // ★ 여기서 에러났었음 (dto.naver... 지우고 NaverDTO로 통일)
            NaverDTO dto = new NaverDTO();

            String naverId = response.has("id") ? response.get("id").asText() : null;
            String name = response.has("name") ? response.get("name").asText() : "이름없음";
            String email = response.has("email") ? response.get("email").asText() : "";
            String gender = response.has("gender") ? response.get("gender").asText() : "U";
            String mobile = response.has("mobile") ? response.get("mobile").asText() : "";
            String birthyear = response.has("birthyear") ? response.get("birthyear").asText() : "2000";
            String birthday = response.has("birthday") ? response.get("birthday").asText() : "01-01";

            dto.fillDetails(naverId, name, email, gender, mobile, birthyear, birthday);
            return dto;
        } catch (Exception e) { e.printStackTrace(); return null; }
    }

    // [4] 로그인 또는 회원가입 처리
    public NaverDTO loginOrJoin(NaverDTO dto) {
        // 1. 네이버 ID로 찾기
        NaverDTO member = naverDAO.selectByNaverId(dto.getNaver_id());

        if (member == null) {
            // 2. 이메일로 찾기
            member = naverDAO.selectByEmail(dto.getEmail());
            if (member != null) {
                // 연동
                dto.setMno(member.getMno());
                naverDAO.updateNaverMember(dto);
            } else {
                // 신규 가입
                naverDAO.insertNaverMember(dto);
            }
        } else {
            // 정보 업데이트
            dto.setMno(member.getMno());
            naverDAO.updateNaverMember(dto);
        }

        return naverDAO.selectByNaverId(dto.getNaver_id());
    }
}