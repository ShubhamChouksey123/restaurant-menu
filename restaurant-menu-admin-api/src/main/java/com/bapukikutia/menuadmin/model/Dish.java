package com.bapukikutia.menuadmin.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Dish {

    @NotBlank(message = "Dish ID is required")
    private String id;

    @NotBlank(message = "Dish name is required")
    private String name;

    @NotNull(message = "Price is required")
    @Min(value = 0, message = "Price must be non-negative")
    private Integer price;

    @NotBlank(message = "Image path is required")
    private String image;

    @JsonProperty("alt_text")
    private String altText;

    private String description;

    @Builder.Default
    private Boolean available = true;

    @JsonProperty("category_id")
    @NotBlank(message = "Category ID is required")
    private String categoryId;

    @JsonProperty("is_vegetarian")
    @Builder.Default
    private Boolean isVegetarian = true;

    @JsonProperty("is_vegan")
    @Builder.Default
    private Boolean isVegan = false;

    @JsonProperty("is_spicy")
    @Builder.Default
    private Boolean isSpicy = false;

    @Builder.Default
    private List<String> tags = new ArrayList<>();
}
