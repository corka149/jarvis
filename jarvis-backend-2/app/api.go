package app

import (
	"context"
	"log"
	"net/http"
	"strconv"

	"github.com/corka149/jarvis/datastore"
	"github.com/corka149/jarvis/dto"
	"github.com/gin-gonic/gin"
)

func toMealDto(meal *datastore.Meal) dto.Meal {
	return dto.Meal{
		ID:       meal.ID,
		Name:     meal.Name,
		Category: meal.Category,
	}
}

func randomMealsViaApi(ctx context.Context, queries *datastore.Queries) gin.HandlerFunc {
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

func getMealsViaApi(ctx context.Context, queries *datastore.Queries) gin.HandlerFunc {
	return func(c *gin.Context) {
		meals, err := queries.GetMeals(ctx)

		if err != nil {
			log.Printf("Error while fetching meals: %v\n", err)
			c.Status(http.StatusInternalServerError)
			return
		}

		mealsDto := make([]dto.Meal, len(meals))

		for i, meal := range meals {
			mealsDto[i] = toMealDto(&meal)
		}

		c.JSON(http.StatusOK, mealsDto)
	}
}

func getMealViaApi(ctx context.Context, queries *datastore.Queries) gin.HandlerFunc {
	return func(c *gin.Context) {
		mealIdParam := c.Param("id")

		mealID, err := strconv.Atoi(mealIdParam)

		if err != nil {
			log.Printf("Error while parsing meal ID: %v\n", err)
			c.Status(http.StatusBadRequest)
			return
		}

		meal, err := queries.GetMeal(ctx, int32(mealID))
		if err != nil {
			log.Printf("Error while fetching meal: %v\n", err)
			c.Status(http.StatusInternalServerError)
			return
		}

		mealDto := toMealDto(&meal)

		c.JSON(http.StatusOK, mealDto)
	}
}

func createMealViaApi(ctx context.Context, queries *datastore.Queries) gin.HandlerFunc {
	return func(c *gin.Context) {
		var mealDto dto.Meal

		if err := c.ShouldBindJSON(&mealDto); err != nil {
			log.Printf("Error while binding meal: %v\n", err)
			c.Status(http.StatusBadRequest)
			return
		}

		mealParams := datastore.CreateMealParams{
			Name:     mealDto.Name,
			Category: mealDto.Category,
		}

		createdMeal, err := queries.CreateMeal(ctx, mealParams)

		if err != nil {
			log.Printf("Error while creating meal: %v\n", err)
			c.Status(http.StatusInternalServerError)
			return
		}

		c.JSON(http.StatusCreated, createdMeal)
	}
}

func updateMealViaApi(ctx context.Context, queries *datastore.Queries) gin.HandlerFunc {
	return func(c *gin.Context) {
		mealIdParam := c.Param("id")

		mealID, err := strconv.Atoi(mealIdParam)

		if err != nil {
			log.Printf("Error while parsing meal ID: %v\n", err)
			c.Status(http.StatusBadRequest)
			return
		}

		var mealDto dto.Meal

		if err := c.ShouldBindJSON(&mealDto); err != nil {
			log.Printf("Error while binding meal: %v\n", err)
			c.Status(http.StatusBadRequest)
			return
		}

		mealParams := datastore.UpdateMealParams{
			ID:       int32(mealID),
			Name:     mealDto.Name,
			Category: mealDto.Category,
		}

		updatedMeal, err := queries.UpdateMeal(ctx, mealParams)

		if err != nil {
			log.Printf("Error while updating meal: %v\n", err)
			c.Status(http.StatusInternalServerError)
			return
		}

		c.JSON(http.StatusOK, updatedMeal)
	}
}
