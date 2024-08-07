package app

import (
	"context"
	"log"
	"strconv"

	"github.com/corka149/jarvis/datastore"
	"github.com/corka149/jarvis/templates"
	"github.com/gin-gonic/gin"
)

func indexMeals(ctx context.Context, queries *datastore.Queries) gin.HandlerFunc {
	return func(c *gin.Context) {
		meals, err := queries.GetMeals(ctx)

		if err != nil {
			log.Println("Error getting meals: ", err)
		}

		if meals == nil {
			meals = []datastore.Meal{}
		}

		templates.Layout(templates.MealsIndex(meals)).Render(ctx, c.Writer)
	}
}

func createMeal(ctx context.Context, queries *datastore.Queries) gin.HandlerFunc {
	return func(c *gin.Context) {
		name := c.PostForm("name")
		category := c.PostForm("category")

		_, err := queries.CreateMeal(ctx, datastore.CreateMealParams{
			Name:     name,
			Category: category,
		})

		if err != nil {
			log.Println("Error creating meal: ", err)
		}

		c.Redirect(302, "/meals")
	}
}

func editMeal(ctx context.Context, queries *datastore.Queries) gin.HandlerFunc {
	return func(c *gin.Context) {
		idStr := c.Param("id")

		id, err := strconv.ParseInt(idStr, 10, 32)

		if err != nil {
			log.Println("Error parsing id: ", err)
			c.Redirect(302, "/meals")
			return
		}

		meal, err := queries.GetMeal(ctx, int32(id))

		if err != nil {
			log.Println("Error getting meal: ", err)
			c.Redirect(302, "/meals")
			return
		}

		templates.Layout(templates.MealsEdit(meal)).Render(ctx, c.Writer)
	}
}

func updateMeal(ctx context.Context, queries *datastore.Queries) gin.HandlerFunc {
	return func(c *gin.Context) {
		idStr := c.Param("id")

		id, err := strconv.ParseInt(idStr, 10, 32)

		if err != nil {
			log.Println("Error parsing id: ", err)
			c.Redirect(302, "/meals")
			return
		}

		meal, err := queries.GetMeal(ctx, int32(id))

		if err != nil {
			log.Println("Error getting meal: ", err)
			c.Redirect(302, "/meals")
			return
		}

		meal.Name = c.PostForm("name")
		meal.Category = c.PostForm("category")

		_, err = queries.UpdateMeal(ctx, datastore.UpdateMealParams{
			ID:       meal.ID,
			Name:     meal.Name,
			Category: meal.Category,
		})

		if err != nil {
			log.Println("Error updating meal: ", err)
			c.Redirect(302, "/meals")
			return
		}

		c.Redirect(302, "/meals")
	}
}

func deleteMeal(ctx context.Context, queries *datastore.Queries) gin.HandlerFunc {
	return func(c *gin.Context) {
		idStr := c.Param("id")

		id, err := strconv.ParseInt(idStr, 10, 32)

		if err != nil {
			log.Println("Error parsing id: ", err)
			c.Redirect(302, "/meals")
			return
		}

		err = queries.DeleteMeal(ctx, int32(id))

		if err != nil {
			log.Println("Error deleting meal: ", err)
		}

		c.Redirect(302, "/meals")
	}
}
