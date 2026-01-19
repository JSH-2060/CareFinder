package com.carefinder.service.google;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.carefinder.dto.member.GooglePeopleDTO;
import com.carefinder.dto.member.GoogleTokenResponseDTO;
import com.carefinder.dto.member.GoogleUserInfoDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class GoogleServiceImpl implements GoogleService {

    @Value("${google.oauth.client-id}")
    private String CLIENT_ID;

    @Value("${google.oauth.client-secret}")
    private String CLIENT_SECRET;

    @Value("${google.oauth.redirect-uri}")
    private String REDIRECT_URI;

    // access_token 발급
    @Override
    public GoogleTokenResponseDTO getAccessToken(String code) {

        String tokenUrl = "https://oauth2.googleapis.com/token";

        RestTemplate restTemplate = new RestTemplate();
        ObjectMapper objectMapper = new ObjectMapper();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("code", code);
        params.add("client_id", CLIENT_ID);
        params.add("client_secret", CLIENT_SECRET);
        params.add("redirect_uri", REDIRECT_URI);
        params.add("grant_type", "authorization_code");

        try {
            ResponseEntity<String> response =
                    restTemplate.postForEntity(
                            tokenUrl,
                            new HttpEntity<>(params, headers),
                            String.class
                    );

            return objectMapper.readValue(
                    response.getBody(),
                    GoogleTokenResponseDTO.class
            );

        } catch (Exception e) {
            throw new RuntimeException("구글 access_token 발급 실패", e);
        }
    }

    // OpenID userinfo
    @Override
    public GoogleUserInfoDTO getUserInfo(String accessToken) {

        String url = "https://openidconnect.googleapis.com/v1/userinfo";

        RestTemplate restTemplate = new RestTemplate();
        ObjectMapper objectMapper = new ObjectMapper();

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);
        headers.setAccept(List.of(MediaType.APPLICATION_JSON));

        try {
            ResponseEntity<String> response =
                    restTemplate.exchange(
                            url,
                            HttpMethod.GET,
                            new HttpEntity<>(headers),
                            String.class
                    );

            return objectMapper.readValue(
                    response.getBody(),
                    GoogleUserInfoDTO.class
            );

        } catch (Exception e) {
            throw new RuntimeException("구글 userinfo 조회 실패", e);
        }
    }

    // People API
    @Override
    public GooglePeopleDTO getPeopleInfo(String accessToken) {

        String url =
                "https://people.googleapis.com/v1/people/me"
                        + "?personFields=genders,phoneNumbers,birthdays";

        RestTemplate restTemplate = new RestTemplate();
        ObjectMapper objectMapper = new ObjectMapper();
        GooglePeopleDTO people = new GooglePeopleDTO();

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);
        headers.setAccept(List.of(MediaType.APPLICATION_JSON));

        try {
            ResponseEntity<String> response =
                    restTemplate.exchange(
                            url,
                            HttpMethod.GET,
                            new HttpEntity<>(headers),
                            String.class
                    );

            Map<String, Object> body =
                    objectMapper.readValue(response.getBody(), Map.class);

            // gender
            List<Map<String, Object>> genders =
                    (List<Map<String, Object>>) body.get("genders");
            if (genders != null && !genders.isEmpty()) {
                people.setGender((String) genders.get(0).get("value"));
            }

            // phone
            List<Map<String, Object>> phones =
                    (List<Map<String, Object>>) body.get("phoneNumbers");
            if (phones != null && !phones.isEmpty()) {
                people.setPhonenumber((String) phones.get(0).get("value"));
            }

            // birthday
            List<Map<String, Object>> birthdays =
                    (List<Map<String, Object>>) body.get("birthdays");
            if (birthdays != null && !birthdays.isEmpty()) {

                Map<String, Object> date =
                        (Map<String, Object>) birthdays.get(0).get("date");

                Integer year = (Integer) date.get("year");
                Integer month = (Integer) date.get("month");
                Integer day = (Integer) date.get("day");

                if (year != null) {
                    int currentYear = java.time.LocalDate.now().getYear();
                    people.setAge(currentYear - year);
                }

                if (year != null && month != null && day != null) {

                    String birth =
                            String.format("%04d%02d%02d", year, month, day);

                    people.setBirth(birth);
                }
            }

        } catch (Exception e) {

        }

        return people;
    }
}
