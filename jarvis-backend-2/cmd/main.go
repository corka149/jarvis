package main

import (
	"context"
	"log"

	"github.com/corka149/jarvis/datastore"
	pgx "github.com/jackc/pgx/v5"
)

func main() {
	ctx := context.Background()

	conn, err := pgx.Connect(ctx, "postgres://myadmin:mypassword@localhost:5432/jarvis_db")

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

	for _, meal := range meals {
		log.Printf("Meal: %s", meal.Name)
	}
}
