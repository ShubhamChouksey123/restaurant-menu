package com.bapukikutia.menuadmin.controller;

import com.bapukikutia.menuadmin.model.Category;
import com.bapukikutia.menuadmin.service.MenuService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
@CrossOrigin(origins = "${cors.allowed-origins}")
public class CategoryController {

    private final MenuService menuService;

    @GetMapping
    public ResponseEntity<List<Category>> getAllCategories() {
        log.info("GET /api/categories - Fetching all categories");
        List<Category> categories = menuService.getAllCategories();
        return ResponseEntity.ok(categories);
    }

    @GetMapping("/{categoryId}")
    public ResponseEntity<Category> getCategoryById(@PathVariable String categoryId) {
        log.info("GET /api/categories/{} - Fetching category", categoryId);
        Category category = menuService.getCategoryById(categoryId);
        return ResponseEntity.ok(category);
    }

    @PostMapping
    public ResponseEntity<Category> createCategory(@Valid @RequestBody Category category) {
        log.info("POST /api/categories - Creating new category: {}", category.getName());
        Category created = menuService.createCategory(category);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{categoryId}")
    public ResponseEntity<Category> updateCategory(
            @PathVariable String categoryId,
            @Valid @RequestBody Category category) {
        log.info("PUT /api/categories/{} - Updating category", categoryId);
        Category updated = menuService.updateCategory(categoryId, category);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{categoryId}")
    public ResponseEntity<Void> deleteCategory(@PathVariable String categoryId) {
        log.info("DELETE /api/categories/{} - Deleting category", categoryId);
        menuService.deleteCategory(categoryId);
        return ResponseEntity.noContent().build();
    }
}
