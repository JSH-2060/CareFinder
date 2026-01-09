package com.carefinder.controller.map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;

@Controller
public class NewsController {

    @Value("${naver.news.client-id}")
    private String clientId;

    @Value("${naver.news.client-secret}")
    private String clientSecret;

    @GetMapping("/api/news")
    @ResponseBody
    public String getNews() throws IOException {
//        String clientId = "Ewtp82PQ_BW7KO7AFjRw";
//        String clientSecret = "NTdWlSVlIS";

        String query = URLEncoder.encode("건강 OR 병원 OR 의료", StandardCharsets.UTF_8);
        String apiURL = "https://openapi.naver.com/v1/search/news.json?query="
                + query + "&display=5&sort=date";

        URL url = new URL(apiURL);
        HttpURLConnection con = (HttpURLConnection)url.openConnection();
        con.setRequestMethod("GET");
        con.setRequestProperty("X-Naver-Client-Id", clientId);
        con.setRequestProperty("X-Naver-Client-Secret", clientSecret);

        int responseCode = con.getResponseCode();
        BufferedReader br;

        if(responseCode == 200) {
            br = new BufferedReader(new InputStreamReader(con.getInputStream(), StandardCharsets.UTF_8));
        } else {
            br = new BufferedReader(new InputStreamReader(con.getErrorStream(), StandardCharsets.UTF_8));
        }

        StringBuilder response = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) {
            response.append(line);
        }
        br.close();
        con.disconnect();

        return response.toString();
    }
}