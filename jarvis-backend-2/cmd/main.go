package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"os"

	"github.com/corka149/jarvis"
	"github.com/corka149/jarvis/app"
	"github.com/corka149/jarvis/datastore"
	"github.com/corka149/jarvis/schema"
	"github.com/corka149/jarvis/static"
	"github.com/gin-gonic/gin"

	"github.com/gin-contrib/gzip"
	"github.com/joho/godotenv"
)

func main() {
	ctx := context.Background()

	// Load .env file
	err := godotenv.Load()

	if err != nil && !errors.Is(err, os.ErrNotExist) {
		log.Printf("Error loading .env file, reading from system env: %s\n", err)
	}

	config, err := jarvis.Setup(ctx, os.Getenv)

	if err != nil {
		log.Fatal(err)
	}

	defer config.DbPool.Close()

	err = schema.RunMigration(ctx, config)

	if err != nil {
		log.Fatal(err)
	}

	queries := datastore.New(config.DbPool)

	router := gin.Default()
	router.Use(gzip.Gzip(gzip.DefaultCompression))

	app.Meals(router, ctx, queries, config)
	app.Home(router, ctx, queries)

	router.StaticFS("/static", http.FS(static.Assets))

	log.Fatal(router.Run())
}
