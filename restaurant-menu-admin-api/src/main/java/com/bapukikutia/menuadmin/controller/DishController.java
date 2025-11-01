package com.bapukikutia.menuadmin.controller;

import com.bapukikutia.menuadmin.dto.PriceUpdateRequest;
import com.bapukikutia.menuadmin.model.Dish;
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
@RequestMapping("/api/categories/{categoryId}/dishes")
@RequiredArgsConstructor
@CrossOrigin(origins = "${cors.allowed-origins}")
public class DishController {

    private final MenuService menuService;

    @GetMapping
    public ResponseEntity<List<Dish>> getDishesByCategory(@PathVariable String categoryId) {
        log.info("GET /api/categories/{}/dishes - Fetching dishes", categoryId);
        List<Dish> dishes = menuService.getDishesByCategory(categoryId);
        return ResponseEntity.ok(dishes);
    }

    @GetMapping("/{dishId}")
    public ResponseEntity<Dish> getDishById(
            @PathVariable String categoryId,
            @PathVariable String dishId) {
        log.info("GET /api/categories/{}/dishes/{} - Fetching dish", categoryId, dishId);
        Dish dish = menuService.getDishById(categoryId, dishId);
        return ResponseEntity.ok(dish);
    }

    @PostMapping
    public ResponseEntity<Dish> createDish(
            @PathVariable String categoryId,
            @Valid @RequestBody Dish dish) {
        log.info("POST /api/categories/{}/dishes - Creating dish: {}", categoryId, dish.getName());
        Dish created = menuService.createDish(categoryId, dish);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{dishId}")
    public ResponseEntity<Dish> updateDish(
            @PathVariable String categoryId,
            @PathVariable String dishId,
            @Valid @RequestBody Dish dish) {
        log.info("PUT /api/categories/{}/dishes/{} - Updating dish", categoryId, dishId);
        Dish updated = menuService.updateDish(categoryId, dishId, dish);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{dishId}")
    public ResponseEntity<Void> deleteDish(
            @PathVariable String categoryId,
            @PathVariable String dishId) {
        log.info("DELETE /api/categories/{}/dishes/{} - Deleting dish", categoryId, dishId);
        menuService.deleteDish(categoryId, dishId);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{dishId}/availability")
    public ResponseEntity<Dish> toggleAvailability(
            @PathVariable String categoryId,
            @PathVariable String dishId) {
        log.info("PATCH /api/categories/{}/dishes/{}/availability - Toggling availability",
                categoryId, dishId);
        Dish updated = menuService.toggleDishAvailability(categoryId, dishId);
        return ResponseEntity.ok(updated);
    }

    @PatchMapping("/{dishId}/price")
    public ResponseEntity<Dish> updatePrice(
            @PathVariable String categoryId,
            @PathVariable String dishId,
            @Valid @RequestBody PriceUpdateRequest request) {
        log.info("PATCH /api/categories/{}/dishes/{}/price - Updating price to ₹{}",
                categoryId, dishId, request.getPrice());
        Dish updated = menuService.updateDishPrice(categoryId, dishId, request.getPrice());
        return ResponseEntity.ok(updated);
    }

    // Get all dishes across all categories
    @GetMapping("/all")
    public ResponseEntity<List<Dish>> getAllDishes() {
        log.info("GET /api/categories//all/dishes - Fetching all dishes");
        List<Dish> dishes = menuService.getAllDishes();
        return ResponseEntity.ok(dishes);
    }
}
