package datastore_test

import (
	"context"
	"database/sql"
	"errors"
	"testing"

	"github.com/corka149/jarvis/datastore"
	pgx "github.com/jackc/pgx/v5"
)

func TestQueries_CreateMeal(t *testing.T) {
	// Open a database connection
	conn, err := pgx.Connect(context.Background(), "postgres://myadmin:mypassword@localhost:5432/jarvis_db")
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close(context.Background())

	// Create a new instance of the Queries struct
	queries := datastore.New(conn)

	// Create a new meal
	pizza, err := queries.CreateMeal(context.Background(), datastore.CreateMealParams{
		Name:     "Pizza",
		Category: "COMPLETE",
	})

	if err != nil {
		t.Fatal(err)
	}

	// Get the meal
	meal, err := queries.GetMeal(context.Background(), pizza.ID)

	if err != nil {
		t.Fatal(err)
	}

	if meal.Name != "Pizza" {
		t.Errorf("Expected meal name to be Pizza, but got %s", meal.Name)
	}

	// Delete the meal
	err = queries.DeleteMeal(context.Background(), pizza.ID)

	if err != nil {
		t.Fatal(err)
	}

	// Get the meal
	meal, err = queries.GetMeal(context.Background(), pizza.ID)

	if errors.Is(err, sql.ErrNoRows) {
		t.Errorf("Expected no rows, but got %s", err)
	}
}
