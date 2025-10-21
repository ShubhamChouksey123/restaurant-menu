package com.bapukikutia.menuadmin.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Data
@Configuration
@ConfigurationProperties(prefix = "github")
public class GitConfig {

    private Repository repository = new Repository();
    private Menu menu = new Menu();
    private Local local = new Local();

    @Data
    public static class Repository {
        private String url;
        private String branch;
        private String username;
        private String token;
    }

    @Data
    public static class Menu {
        private String filePath;
    }

    @Data
    public static class Local {
        private String cloneDirectory;
    }
}
