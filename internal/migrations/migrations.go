package migrations

import (
	"database/sql"
	"embed"
	"github.com/golang-migrate/migrate/v4"
	"log"

	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	"github.com/golang-migrate/migrate/v4/source/iofs"
	_ "github.com/lib/pq"
)

const dbURL = "postgres://postgres:postgres@localhost:54321/jarvis?sslmode=disable"

//go:embed migrations/*.sql
var migrationsFS embed.FS

func Execute() error {
	// ===== DATABASE =====
	dbConn, err := sql.Open("postgres", dbURL)
	if err != nil {
		return err
	}
	defer func(dbConn *sql.DB) {
		err := dbConn.Close()
		if err != nil {
			log.Fatal(err)
		}
	}(dbConn)

	d, err := iofs.New(migrationsFS, "migrations")
	if err != nil {
		return err
	}

	migrations, err := migrate.NewWithSourceInstance("iofs", d, dbURL)
	if err != nil {
		return err
	}

	err = migrations.Up()
	if err != nil && err.Error() != "no change" {
		return err
	}

	return nil
}
