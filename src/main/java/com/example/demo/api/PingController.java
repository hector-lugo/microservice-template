package com.example.demo.api;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RequestMapping("api/v1/ping")
@RestController
public class PingController {

    @Autowired
    public PingController() {
    }

    @GetMapping
    public String demo() {
        return "Pong";
    }
}
