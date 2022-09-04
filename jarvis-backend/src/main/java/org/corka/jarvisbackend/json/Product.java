package org.corka.jarvisbackend.json;

import io.quarkus.runtime.annotations.RegisterForReflection;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@RegisterForReflection
public class Product {

    private String name;
    private int amount;

}
