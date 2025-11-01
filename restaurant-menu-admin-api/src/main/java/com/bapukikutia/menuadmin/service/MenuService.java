package com.bapukikutia.menuadmin.service;

import com.bapukikutia.menuadmin.exception.ResourceNotFoundException;
import com.bapukikutia.menuadmin.model.Category;
import com.bapukikutia.menuadmin.model.Dish;
import com.bapukikutia.menuadmin.model.MenuData;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class MenuService {

    private final GitService gitService;
    private final ObjectMapper objectMapper;

    // ==================== Menu Data Operations ====================

    public MenuData getMenuData() {
        try {
            String menuJson = gitService.readMenuFile();
            return objectMapper.readValue(menuJson, MenuData.class);
        } catch (IOException e) {
            log.error("Failed to parse menu data", e);
            throw new RuntimeException("Failed to parse menu data: " + e.getMessage(), e);
        }
    }

    private void saveMenuData(MenuData menuData, String commitMessage) {
        try {
            String menuJson = objectMapper.writerWithDefaultPrettyPrinter()
                    .writeValueAsString(menuData);
            gitService.writeMenuFile(menuJson);
            gitService.commitAndPush(commitMessage);
            log.info("Menu data saved and committed: {}", commitMessage);
        } catch (IOException e) {
            log.error("Failed to serialize menu data", e);
            throw new RuntimeException("Failed to serialize menu data: " + e.getMessage(), e);
        }
    }

    // ==================== Category Operations ====================

    public List<Category> getAllCategories() {
        return getMenuData().getCategories();
    }

    public Category getCategoryById(String categoryId) {
        return getMenuData().getCategories().stream()
                .filter(cat -> cat.getId().equals(categoryId))
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Category not found with ID: " + categoryId));
    }

    public Category createCategory(Category category) {
        MenuData menuData = getMenuData();

        // Check if category ID already exists
        boolean exists = menuData.getCategories().stream()
                .anyMatch(cat -> cat.getId().equals(category.getId()));

        if (exists) {
            throw new IllegalArgumentException("Category with ID " + category.getId() + " already exists");
        }

        menuData.getCategories().add(category);
        saveMenuData(menuData, "Add new category: " + category.getName());

        log.info("Created category: {}", category.getId());
        return category;
    }

    public Category updateCategory(String categoryId, Category updatedCategory) {
        MenuData menuData = getMenuData();

        Optional<Category> existingCategory = menuData.getCategories().stream()
                .filter(cat -> cat.getId().equals(categoryId))
                .findFirst();

        if (existingCategory.isEmpty()) {
            throw new ResourceNotFoundException("Category not found with ID: " + categoryId);
        }

        Category category = existingCategory.get();
        category.setName(updatedCategory.getName());
        category.setDisplayOrder(updatedCategory.getDisplayOrder());

        saveMenuData(menuData, "Update category: " + category.getName());

        log.info("Updated category: {}", categoryId);
        return category;
    }

    public void deleteCategory(String categoryId) {
        MenuData menuData = getMenuData();

        boolean removed = menuData.getCategories().removeIf(cat -> cat.getId().equals(categoryId));

        if (!removed) {
            throw new ResourceNotFoundException("Category not found with ID: " + categoryId);
        }

        saveMenuData(menuData, "Delete category: " + categoryId);
        log.info("Deleted category: {}", categoryId);
    }

    // ==================== Dish Operations ====================

    public List<Dish> getAllDishes() {
        return getMenuData().getCategories().stream()
                .flatMap(category -> category.getDishes().stream())
                .toList();
    }

    public List<Dish> getDishesByCategory(String categoryId) {
        Category category = getCategoryById(categoryId);
        return category.getDishes();
    }

    public Dish getDishById(String categoryId, String dishId) {
        Category category = getCategoryById(categoryId);

        return category.getDishes().stream()
                .filter(dish -> dish.getId().equals(dishId))
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Dish not found with ID: " + dishId + " in category: " + categoryId));
    }

    public Dish createDish(String categoryId, Dish dish) {
        MenuData menuData = getMenuData();

        Category category = menuData.getCategories().stream()
                .filter(cat -> cat.getId().equals(categoryId))
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Category not found with ID: " + categoryId));

        // Check if dish ID already exists in this category
        boolean exists = category.getDishes().stream()
                .anyMatch(d -> d.getId().equals(dish.getId()));

        if (exists) {
            throw new IllegalArgumentException(
                    "Dish with ID " + dish.getId() + " already exists in category " + categoryId);
        }

        // Set the category ID
        dish.setCategoryId(categoryId);
        category.getDishes().add(dish);

        saveMenuData(menuData, "Add new dish: " + dish.getName() + " to category: " + category.getName());

        log.info("Created dish: {} in category: {}", dish.getId(), categoryId);
        return dish;
    }

    public Dish updateDish(String categoryId, String dishId, Dish updatedDish) {
        MenuData menuData = getMenuData();

        Category category = menuData.getCategories().stream()
                .filter(cat -> cat.getId().equals(categoryId))
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Category not found with ID: " + categoryId));

        Dish dish = category.getDishes().stream()
                .filter(d -> d.getId().equals(dishId))
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Dish not found with ID: " + dishId));

        // Update dish properties
        dish.setName(updatedDish.getName());
        dish.setPrice(updatedDish.getPrice());
        dish.setImage(updatedDish.getImage());
        dish.setAltText(updatedDish.getAltText());
        dish.setDescription(updatedDish.getDescription());
        dish.setAvailable(updatedDish.getAvailable());
        dish.setIsVegetarian(updatedDish.getIsVegetarian());
        dish.setIsVegan(updatedDish.getIsVegan());
        dish.setIsSpicy(updatedDish.getIsSpicy());
        dish.setTags(updatedDish.getTags());

        saveMenuData(menuData, "Update dish: " + dish.getName() + " (₹" + dish.getPrice() + ")");

        log.info("Updated dish: {} in category: {}", dishId, categoryId);
        return dish;
    }

    public void deleteDish(String categoryId, String dishId) {
        MenuData menuData = getMenuData();

        Category category = menuData.getCategories().stream()
                .filter(cat -> cat.getId().equals(categoryId))
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Category not found with ID: " + categoryId));

        boolean removed = category.getDishes().removeIf(dish -> dish.getId().equals(dishId));

        if (!removed) {
            throw new ResourceNotFoundException("Dish not found with ID: " + dishId);
        }

        saveMenuData(menuData, "Delete dish: " + dishId + " from category: " + category.getName());
        log.info("Deleted dish: {} from category: {}", dishId, categoryId);
    }

    public Dish toggleDishAvailability(String categoryId, String dishId) {
        MenuData menuData = getMenuData();

        Category category = menuData.getCategories().stream()
                .filter(cat -> cat.getId().equals(categoryId))
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Category not found with ID: " + categoryId));

        Dish dish = category.getDishes().stream()
                .filter(d -> d.getId().equals(dishId))
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Dish not found with ID: " + dishId));

        dish.setAvailable(!dish.getAvailable());

        String status = dish.getAvailable() ? "available" : "unavailable";
        saveMenuData(menuData, "Mark dish " + status + ": " + dish.getName());

        log.info("Toggled availability for dish: {} to {}", dishId, status);
        return dish;
    }

    public Dish updateDishPrice(String categoryId, String dishId, Integer newPrice) {
        MenuData menuData = getMenuData();

        Category category = menuData.getCategories().stream()
                .filter(cat -> cat.getId().equals(categoryId))
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Category not found with ID: " + categoryId));

        Dish dish = category.getDishes().stream()
                .filter(d -> d.getId().equals(dishId))
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Dish not found with ID: " + dishId));

        Integer oldPrice = dish.getPrice();
        dish.setPrice(newPrice);

        saveMenuData(menuData, String.format(
                "Update %s price: ₹%d → ₹%d", dish.getName(), oldPrice, newPrice));

        log.info("Updated price for dish: {} from ₹{} to ₹{}", dishId, oldPrice, newPrice);
        return dish;
    }
}
