package main

import (
	"context"
	"errors"
	"log"
	"os"

	"github.com/corka149/jarvis"
	"github.com/corka149/jarvis/app"
	"github.com/corka149/jarvis/datastore"
	"github.com/corka149/jarvis/templates"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	ctx := context.Background()

	// Load .env file
	err := godotenv.Load()

	if err != nil && !errors.Is(err, os.ErrNotExist) {
		log.Printf("Error loading .env file, reading from system env: %s\n", err)
	}

	conn, err := jarvis.CreateDbConn(ctx)

	if err != nil {
		log.Fatal(err)
	}

	defer conn.Close(ctx)

	queries := datastore.New(conn)
	router := gin.Default()

	app.Meals(router, ctx, queries)

	router.GET("/", func(c *gin.Context) {
		templates.Layout(templates.Index()).Render(ctx, c.Writer)
	})
	router.Static("/static", "./static")

	log.Fatal(router.Run())
}
