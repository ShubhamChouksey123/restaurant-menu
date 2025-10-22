package com.bapukikutia.menuadmin.controller;

import com.bapukikutia.menuadmin.model.MenuData;
import com.bapukikutia.menuadmin.service.MenuService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/api/menu")
@RequiredArgsConstructor
@CrossOrigin(origins = "${cors.allowed-origins}")
public class MenuController {

    private final MenuService menuService;

    @GetMapping
    public ResponseEntity<MenuData> getMenuData() {
        log.info("GET /api/menu - Fetching complete menu data");
        MenuData menuData = menuService.getMenuData();
        return ResponseEntity.ok(menuData);
    }
}
