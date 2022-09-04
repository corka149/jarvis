package org.corka.jarvisbackend.json;

import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import java.util.Collections;
import java.util.Set;

@Path("/v1/lists")
public class ShoppingListResource {

    @GET
    public Set<ShoppingList> list() {
        return Collections.emptySet();
    }

    @POST
    public ShoppingList add(ShoppingList shoppingList) {
        return shoppingList;
    }

    @PUT
    public ShoppingList update(ShoppingList shoppingList) {
        return shoppingList;
    }

    @DELETE
    public Response delete(String listId) {
        return Response.ok().build();
    }
}
