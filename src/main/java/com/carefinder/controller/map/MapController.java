package com.carefinder.controller.map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class MapController {

    @Value("${google.maps.key}")
    private String googleMapsKey;

    @Value("${kakao.maps.javascript-key}")
    private String kakaoMapsKey;

    @Value("${kakao.rest-key}")
    private String kakaoRestKey;

    @Value("${tmap.app-key}")
    private String tmapAppKey;

    @GetMapping("/map")
    public String map(Model model) {
        model.addAttribute("kakaoMapsKey", kakaoMapsKey);
        model.addAttribute("kakaoRestKey", kakaoRestKey);
        model.addAttribute("tmapAppKey", tmapAppKey);
        model.addAttribute("googleMapsKey", googleMapsKey);
        return "map/map";
    }
}