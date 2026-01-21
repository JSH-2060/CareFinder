package com.carefinder.controller.kakao;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;

@Slf4j
@Data
@Component
public class KakaoApi {

    @Value("${kakao.api_key}")
    private String kakaoApikey;

    @Value("${kakao.redirect_url}")
    private String kakaoRedirectUrl;

    //Access Token 발급
    public String getAccessToken(String code) {
        String accessToken = "";
        String reqUrl = "https://kauth.kakao.com/oauth/token";

        try {
            URL url = new URL(reqUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();

            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=utf-8");

            String param = "grant_type=authorization_code"
                    + "&client_id=" + kakaoApikey
                    + "&redirect_uri=" + kakaoRedirectUrl
                    + "&code=" + code;

            BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(conn.getOutputStream(), "UTF-8"));
            bw.write(param);
            bw.flush();

            int responseCode = conn.getResponseCode();
            log.info("카카오 토큰 responseCode = {}", responseCode);

            BufferedReader br;
            if (responseCode == 200) {
                br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            } else {
                br = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
            }

            String result = br.readLine();
            log.info("카카오 토큰 응답 = {}", result);

            if (responseCode == 200) {
                JsonObject json = JsonParser.parseString(result).getAsJsonObject();
                accessToken = json.get("access_token").getAsString();
            }

            br.close();
            bw.close();

        } catch (Exception e) {
            log.error("카카오 토큰 발급 실패", e);
        }

        return accessToken;
    }

    //사용자 정보 전부 가져오기
    public HashMap<String, Object> getUserInfo(String accessToken) {
        HashMap<String, Object> userInfo = new HashMap<>();
        String reqUrl = "https://kapi.kakao.com/v2/user/me";

        if (accessToken == null || accessToken.isBlank()) {
            log.error("getUserInfo() accessToken 비어있음");
            return userInfo;
        }

        try {
            URL url = new URL(reqUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Authorization", "Bearer " + accessToken);
            conn.setRequestProperty("Content-type", "application/x-www-form-urlencoded;charset=utf-8");

            int responseCode = conn.getResponseCode();

            BufferedReader br = new BufferedReader(new InputStreamReader(
                    responseCode == 200 ? conn.getInputStream() : conn.getErrorStream(), "UTF-8"
            ));

            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) sb.append(line);
            br.close();

            if (responseCode != 200) {
                log.error("카카오 사용자 정보 조회 실패 responseCode={}, body={}", responseCode, sb);
                return userInfo;
            }

            JsonObject json = JsonParser.parseString(sb.toString()).getAsJsonObject();

            userInfo.put("kakaoId", get(json, "id"));

            JsonObject properties = json.has("properties") && json.get("properties").isJsonObject()
                    ? json.getAsJsonObject("properties")
                    : null;

            if (properties != null) {
                userInfo.put("nickname", get(properties, "nickname"));
                userInfo.put("profileImage", get(properties, "profile_image"));
                userInfo.put("thumbnailImage", get(properties, "thumbnail_image"));
            }

            //kakao_account
            JsonObject account = json.has("kakao_account") && json.get("kakao_account").isJsonObject()
                    ? json.getAsJsonObject("kakao_account")
                    : null;

            if (account != null) {
                userInfo.put("email", get(account, "email"));
                userInfo.put("name", get(account, "name"));
                userInfo.put("gender", get(account, "gender"));
                userInfo.put("ageRange", get(account, "age_range"));
                userInfo.put("birthday", get(account, "birthday"));
                userInfo.put("birthyear", get(account, "birthyear"));
                userInfo.put("phoneNumber", get(account, "phone_number"));
            }

            return userInfo;

        } catch (Exception e) {
            log.error("카카오 사용자 정보 조회 예외", e);
            return userInfo;
        }
    }

    //카카오 로그아웃
    public void kakaoLogout(String accessToken) {
        String reqUrl = "https://kapi.kakao.com/v1/user/logout";

        if (accessToken == null || accessToken.isBlank()) return;

        try {
            URL url = new URL(reqUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Authorization", "Bearer " + accessToken);

            int responseCode = conn.getResponseCode();

            BufferedReader br = new BufferedReader(new InputStreamReader(
                    responseCode == 200 ? conn.getInputStream() : conn.getErrorStream(), "UTF-8"
            ));

            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) sb.append(line);
            br.close();

            log.info("카카오 로그아웃 responseCode={}, body={}", responseCode, sb);

        } catch (Exception e) {
            log.error("카카오 로그아웃 실패", e);
        }
    }

    private String get(JsonObject obj, String key) {
        if (obj == null || key == null) return null;
        JsonElement e = obj.get(key);
        return (e == null || e.isJsonNull()) ? null : e.getAsString();
    }
}
