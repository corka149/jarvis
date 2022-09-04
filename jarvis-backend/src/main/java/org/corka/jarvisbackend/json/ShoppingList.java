package org.corka.jarvisbackend.json;

import io.quarkus.runtime.annotations.RegisterForReflection;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

@Data
@NoArgsConstructor
@RegisterForReflection
public class ShoppingList {

    private String id;
    private int number;
    private String reason;
    private LocalDate occursAt;
    private boolean done;
    private List<Product> products;

}
