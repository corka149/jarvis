package app_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/corka149/jarvis"
	"github.com/corka149/jarvis/app"
	"github.com/corka149/jarvis/datastore"
	"github.com/corka149/jarvis/schema"
	"github.com/gin-gonic/gin"

	"github.com/stretchr/testify/assert"
)

func TestHomeWithoutMealsAvailable(t *testing.T) {
	// Given
	ctx := context.Background()

	config, err := jarvis.Setup(ctx, getenv)
	assert.Nil(t, err)

	queries := datastore.New(config.DbPool)
	prepareDb(ctx, queries, config)

	router := gin.Default()
	app.Home(router, ctx, queries)

	w := httptest.NewRecorder()
	req, err := http.NewRequest("GET", "/", nil)
	assert.Nil(t, err)

	// When
	router.ServeHTTP(w, req)

	// Then
	assert.Equal(t, http.StatusOK, w.Code)
	assert.Contains(t, w.Body.String(), "<!doctype html>")
}

func TestHomeWithCompleteMeal(t *testing.T) {
	// Given
	ctx := context.Background()

	config, err := jarvis.Setup(ctx, getenv)
	assert.Nil(t, err)

	queries := datastore.New(config.DbPool)
	prepareDb(ctx, queries, config)

	router := gin.Default()
	app.Home(router, ctx, queries)

	pizza, err := queries.CreateMeal(ctx, datastore.CreateMealParams{
		Name:     "Pizza",
		Category: datastore.COMPLETE_CATEGORY,
	})
	assert.Nil(t, err)

	w := httptest.NewRecorder()
	req, err := http.NewRequest("GET", "/", nil)
	assert.Nil(t, err)

	// When
	router.ServeHTTP(w, req)

	// Then
	assert.Equal(t, http.StatusOK, w.Code)
	assert.Contains(t, w.Body.String(), "<!doctype html>")
	assert.Contains(t, w.Body.String(), pizza.Name)
}

func TestHomeWithMainAndSupplementMeal(t *testing.T) {
	// Given
	ctx := context.Background()

	config, err := jarvis.Setup(ctx, getenv)
	assert.Nil(t, err)

	queries := datastore.New(config.DbPool)
	prepareDb(ctx, queries, config)

	router := gin.Default()
	app.Home(router, ctx, queries)

	cheese, err := queries.CreateMeal(ctx, datastore.CreateMealParams{
		Name:     "Cheese",
		Category: datastore.MAIN_CATEGORY,
	})
	assert.Nil(t, err)
	salad, err := queries.CreateMeal(ctx, datastore.CreateMealParams{
		Name:     "Salad",
		Category: datastore.SUPPLEMENT_CATEGORY,
	})
	assert.Nil(t, err)

	w := httptest.NewRecorder()
	req, err := http.NewRequest("GET", "/", nil)
	assert.Nil(t, err)

	// When
	router.ServeHTTP(w, req)

	// Then
	assert.Equal(t, http.StatusOK, w.Code)
	assert.Contains(t, w.Body.String(), "<!doctype html>")
	assert.Contains(t, w.Body.String(), cheese.Name)
	assert.Contains(t, w.Body.String(), salad.Name)
}

func prepareDb(ctx context.Context, queries *datastore.Queries, config *jarvis.Config) {
	schema.RunMigration(ctx, config)

	meals, err := queries.GetMeals(ctx)
	if err != nil {
		return
	}

	for _, meal := range meals {
		queries.DeleteMeal(ctx, meal.ID)
	}
}

func getenv(key string) string {
	switch key {
	case "DB_URL":
		return "postgres://myadmin:mypassword@localhost:5432/test_jarvis_db"
	case "ADMIN_USER":
		return "admin"
	case "ADMIN_PASSWORD":
		return "password"
	}
	return ""
}
