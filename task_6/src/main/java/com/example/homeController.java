package com.example;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;


@Controller
public class homeController {
    @GetMapping({"/", "/home", "/index"})
    public String index() {
        return "index";
    }
}
