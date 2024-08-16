package com.example.ezlearnacademy;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
public class EzLearnAcademyApplication extends SpringBootServletInitializer {

    public static void main(String[] args) {
        SpringApplication.run(EzLearnAcademyApplication.class, args);
    }

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder builder) {
        return builder.sources(EzLearnAcademyApplication.class);
    }
}

@RestController
class WelcomeController {
    @GetMapping("/")
    public String welcome() {
        return "<html><body>"
                + "<h1>Welcome to EzLearn Academy</h1>"
                + "<p>Happy Learning! &#128187;</p>"
                + "</body></html>";
    }
}