package com.bapukikutia.menuadmin.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PriceUpdateRequest {

    @NotNull(message = "Price is required")
    @Min(value = 0, message = "Price must be non-negative")
    private Integer price;
}
