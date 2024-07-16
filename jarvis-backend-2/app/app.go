package app

import (
	"context"
	_ "embed"
	"log"
	"math/rand"

	"github.com/corka149/jarvis/datastore"
	"github.com/corka149/jarvis/dto"
	"github.com/corka149/jarvis/templates"
	"github.com/gin-gonic/gin"
)

func indexHome(ctx context.Context, queries *datastore.Queries) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Pick one random meal from DB
		mealCombo, err := pickRandomMeals(ctx, queries)

		if err != nil {
			log.Printf("Error while picking random meals: %v\n", err)
			c.Redirect(302, "/")
			return
		}

		templates.Layout(templates.Index(mealCombo)).Render(ctx, c.Writer)
	}
}

func pickRandomMeals(ctx context.Context, queries *datastore.Queries) (dto.MealCombo, error) {
	// Pick one random meal from DB
	meals, err := queries.GetMeals(ctx)

	if err != nil {
		return dto.MealCombo{}, err
	}

	rand.Shuffle(len(meals), func(i, j int) {
		meals[i], meals[j] = meals[j], meals[i]
	})

	main := false
	supplement := false

	var first, second datastore.Meal

	for _, meal := range meals {
		if meal.Category == datastore.COMPLETE_CATEGORY && !main && !supplement {
			first = meal
			break
		}

		if meal.Category == datastore.MAIN_CATEGORY && !main {
			first = meal
			main = true
		}

		if meal.Category == datastore.SUPPLEMENT_CATEGORY && !supplement {
			second = meal
			supplement = true
		}

		if main && supplement {
			break
		}
	}

	mealCombo := dto.MealCombo{
		First:          dto.Meal{Name: first.Name, Category: first.Category},
		Second:         dto.Meal{Name: second.Name, Category: second.Category},
		WithSupplement: second.ID != 0,
	}

	return mealCombo, nil
}
