package com.carefinder.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class MainContorller {
    @GetMapping("/")
    public String index(HttpSession session, Model model) {
        model.addAttribute("userPk", session.getAttribute("userPk"));
        return "index";
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/";
    }

}
