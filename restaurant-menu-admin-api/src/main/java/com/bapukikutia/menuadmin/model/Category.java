package com.bapukikutia.menuadmin.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.Valid;
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
public class Category {

    @NotBlank(message = "Category ID is required")
    private String id;

    @NotBlank(message = "Category name is required")
    private String name;

    @JsonProperty("display_order")
    @NotNull(message = "Display order is required")
    @Min(value = 1, message = "Display order must be at least 1")
    private Integer displayOrder;

    @Valid
    @Builder.Default
    private List<Dish> dishes = new ArrayList<>();
}
