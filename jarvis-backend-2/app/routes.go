package app

import (
	"context"
	"net/http"

	"github.com/corka149/jarvis"
	"github.com/corka149/jarvis/datastore"
	"github.com/corka149/jarvis/static"
	"github.com/gin-gonic/gin"
)

func RegisterRoutes(router *gin.Engine, ctx context.Context, queries *datastore.Queries, config *jarvis.Config) {

	// ==================== HOME ====================
	router.GET("/", indexHome(ctx, queries))

	// ==================== MEALS ====================
	admin := router.Group("/meals", gin.BasicAuth(gin.Accounts{
		config.AdminUsername: config.AdminUserPassword,
	}))
	admin.GET("", indexMeals(ctx, queries))
	admin.POST("", createMeal(ctx, queries))
	admin.GET("/:id", editMeal(ctx, queries))
	admin.POST("/:id", updateMeal(ctx, queries))
	admin.POST("/:id/delete", deleteMeal(ctx, queries))

	router.StaticFS("/static", http.FS(static.Assets))
}
