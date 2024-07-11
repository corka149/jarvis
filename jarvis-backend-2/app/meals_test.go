package app_test

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/corka149/jarvis"
	"github.com/corka149/jarvis/app"
	"github.com/corka149/jarvis/datastore"
	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

func TestIndexMeals(t *testing.T) {
	// Given
	ctx := context.Background()

	config, err := jarvis.Setup(ctx, getenv)
	assert.Nil(t, err)

	queries := datastore.New(config.DbPool)
	prepareDb(ctx, queries, config)

	router := gin.Default()
	app.Meals(router, ctx, queries, config)

	w := httptest.NewRecorder()
	req, err := http.NewRequest("GET", "/meals", nil)
	req.SetBasicAuth(config.AdminUsername, config.AdminUserPassword)
	assert.Nil(t, err)

	// When
	router.ServeHTTP(w, req)

	// Then
	assert.Equal(t, http.StatusOK, w.Code)
	assert.Contains(t, w.Body.String(), "<!doctype html>")
}

func TestCreateMeal(t *testing.T) {
	// Given
	ctx := context.Background()

	config, err := jarvis.Setup(ctx, getenv)
	assert.Nil(t, err)

	queries := datastore.New(config.DbPool)
	prepareDb(ctx, queries, config)

	router := gin.Default()
	app.Meals(router, ctx, queries, config)

	w := httptest.NewRecorder()

	// Form data
	formData := fmt.Sprintf("name=%s&category=%s", "Bread", datastore.COMPLETE_CATEGORY)
	req, err := http.NewRequest("POST", "/meals", strings.NewReader(formData))
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	req.SetBasicAuth(config.AdminUsername, config.AdminUserPassword)
	assert.Nil(t, err)

	// When
	router.ServeHTTP(w, req)

	// Then
	assert.Equal(t, http.StatusFound, w.Code)

	meals, err := queries.GetMeals(ctx)
	assert.Nil(t, err)
	assert.Len(t, meals, 1)

	bread := meals[0]
	assert.Equal(t, "Bread", bread.Name)
	assert.Equal(t, datastore.COMPLETE_CATEGORY, bread.Category)
}

func TestUpdateMeal(t *testing.T) {
	// Given
	ctx := context.Background()

	config, err := jarvis.Setup(ctx, getenv)
	assert.Nil(t, err)

	queries := datastore.New(config.DbPool)
	prepareDb(ctx, queries, config)

	router := gin.Default()
	app.Meals(router, ctx, queries, config)

	bread, err := queries.CreateMeal(ctx, datastore.CreateMealParams{
		Name:     "Bread",
		Category: datastore.COMPLETE_CATEGORY,
	})
	assert.Nil(t, err)

	w := httptest.NewRecorder()

	// Form data
	formData := fmt.Sprintf("name=%s&category=%s", "Bread with butter", datastore.MAIN_CATEGORY)
	req, err := http.NewRequest("POST", fmt.Sprintf("/meals/%d", bread.ID), strings.NewReader(formData))
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	req.SetBasicAuth(config.AdminUsername, config.AdminUserPassword)
	assert.Nil(t, err)

	// When
	router.ServeHTTP(w, req)

	// Then
	assert.Equal(t, http.StatusFound, w.Code)

	meals, err := queries.GetMeals(ctx)
	assert.Nil(t, err)
	assert.Len(t, meals, 1)

	bread = meals[0]
	assert.Equal(t, "Bread with butter", bread.Name)
	assert.Equal(t, datastore.MAIN_CATEGORY, bread.Category)
}

func TestDeleteMeal(t *testing.T) {
	// Given
	ctx := context.Background()

	config, err := jarvis.Setup(ctx, getenv)
	assert.Nil(t, err)

	queries := datastore.New(config.DbPool)
	prepareDb(ctx, queries, config)

	router := gin.Default()
	app.Meals(router, ctx, queries, config)

	bread, err := queries.CreateMeal(ctx, datastore.CreateMealParams{
		Name:     "Bread",
		Category: datastore.COMPLETE_CATEGORY,
	})
	assert.Nil(t, err)

	w := httptest.NewRecorder()
	req, err := http.NewRequest("POST", fmt.Sprintf("/meals/%d/delete", bread.ID), nil)
	req.SetBasicAuth(config.AdminUsername, config.AdminUserPassword)
	assert.Nil(t, err)

	// When
	router.ServeHTTP(w, req)

	// Then
	assert.Equal(t, http.StatusFound, w.Code)

	meals, err := queries.GetMeals(ctx)
	assert.Nil(t, err)
	assert.Len(t, meals, 0)
}
