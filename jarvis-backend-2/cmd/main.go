package main

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"log"
	"os"

	"github.com/corka149/jarvis"
	"github.com/corka149/jarvis/datastore"
	templates "github.com/corka149/jarvis/templ"
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

	_, err = queries.CreateMeal(ctx, datastore.CreateMealParams{
		Name:     "Pizza",
		Category: "COMPLETE",
	})

	if err != nil {
		log.Fatal(err)
	}

	meals, err := queries.GetMeals(ctx)

	if err != nil {
		log.Fatal(err)
	}

	var buf bytes.Buffer
	err = templates.MealsIndex(meals).Render(ctx, &buf)

	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(buf.String())
}
