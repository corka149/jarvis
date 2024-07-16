package app

import (
	"context"
	"log"
	"net/http"

	"github.com/corka149/jarvis/datastore"
	"github.com/gin-gonic/gin"
)

func randomMeals(ctx context.Context, queries *datastore.Queries) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Pick one random meal from DB
		mealCombo, err := pickRandomMeals(ctx, queries)

		if err != nil {
			log.Printf("Error while picking random meals: %v\n", err)
			c.Status(http.StatusInternalServerError)
			return
		}

		c.JSON(http.StatusOK, mealCombo)
	}
}
