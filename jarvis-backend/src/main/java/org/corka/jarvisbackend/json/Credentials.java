package org.corka.jarvisbackend.json;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class Credentials {

    private String userName;
    private String password;

}
