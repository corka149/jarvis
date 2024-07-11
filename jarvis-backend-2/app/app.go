package app

import (
	"context"
	_ "embed"
	"log"
	"math/rand"

	"github.com/corka149/jarvis/datastore"
	"github.com/corka149/jarvis/templates"
	"github.com/gin-gonic/gin"
)

func Home(router *gin.Engine, ctx context.Context, queries *datastore.Queries) {
	router.GET("/", indexHome(ctx, queries))
}

func indexHome(ctx context.Context, queries *datastore.Queries) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Pick one random meal from DB
		meals, err := queries.GetMeals(ctx)

		if err != nil {
			log.Println(err)
			c.Redirect(302, "/")
			return
		}

		rand.Shuffle(len(meals), func(i, j int) {
			meals[i], meals[j] = meals[j], meals[i]
		})

		randomMeals := make([]datastore.Meal, 0, 2)
		main := false
		supplement := false

		for _, meal := range meals {
			if meal.Category == datastore.COMPLETE_CATEGORY && !main && !supplement {
				randomMeals = append(randomMeals, meal)
				break
			}

			if meal.Category == datastore.MAIN_CATEGORY && !main {
				randomMeals = append(randomMeals, meal)
				main = true
			}

			if meal.Category == datastore.SUPPLEMENT_CATEGORY && !supplement {
				randomMeals = append(randomMeals, meal)
				supplement = true
			}

			if main && supplement {
				break
			}
		}

		templates.Layout(templates.Index(randomMeals)).Render(ctx, c.Writer)
	}
}
