package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"os"
	"os/signal"

	"github.com/corka149/jarvis"
	"github.com/corka149/jarvis/app"
	"github.com/corka149/jarvis/datastore"
	"github.com/corka149/jarvis/middleware"
	"github.com/corka149/jarvis/schema"
	"github.com/gin-gonic/gin"

	"github.com/gin-contrib/gzip"
	"github.com/joho/godotenv"
)

func main() {
	err := Run(context.Background(), os.Getenv)

	log.Fatalln(err)
}

func Run(ctx context.Context, getenv func(string) string) error {
	ctx, cancel := signal.NotifyContext(ctx, os.Interrupt)
	defer cancel()

	// Load .env file
	err := godotenv.Load()

	if err != nil && !errors.Is(err, os.ErrNotExist) {
		return fmt.Errorf("failed to load .env file: %w", err)
	}

	config, err := jarvis.Setup(ctx, getenv)

	if err != nil {
		return fmt.Errorf("failed to setup config: %w", err)
	}

	defer config.DbPool.Close()

	err = schema.RunMigration(ctx, config)

	if err != nil {
		return fmt.Errorf("failed to run migration: %w", err)
	}

	queries := datastore.New(config.DbPool)

	router := gin.Default()
	router.Use(gzip.Gzip(gzip.DefaultCompression))
	router.Use(middleware.RewriteURL(config.UrlPrefix))

	app.RegisterRoutes(router, ctx, queries, config)

	err = router.Run()

	if err != nil {
		return fmt.Errorf("failed to run server: %w", err)
	}

	return nil
}
