package com.bapukikutia.menuadmin.model;

import jakarta.validation.Valid;
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
public class MenuData {

    @Valid
    @Builder.Default
    private List<Category> categories = new ArrayList<>();
}
