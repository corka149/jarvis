// / This file contains the setup function for the Jarvis package.
// / The configuration can be done by the following environment variables:
// / - ADMIN_USER: The username for the admin user. Default is "admin".
// / - ADMIN_PASSWORD: The password for the admin user. Default is "password".
// / - DB_URL: The URL for the database. Default is "postgres://myadmin:mypassword@localhost:5432/jarvis_db".
package jarvis

import (
	"cmp"
	"context"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Config struct {
	AdminUsername     string
	AdminUserPassword string
	DbPool            *pgxpool.Pool
}

const defaultDbURL = "postgres://myadmin:mypassword@localhost:5432/jarvis_db"

func Setup(ctx context.Context) (*Config, error) {
	dbUrl := cmp.Or(os.Getenv("DB_URL"), defaultDbURL)

	dbpool, err := pgxpool.New(ctx, dbUrl)

	if err != nil {
		return nil, err
	}

	adminUser := cmp.Or(os.Getenv("ADMIN_USER"), "admin")
	adminPassword := cmp.Or(os.Getenv("ADMIN_PASSWORD"), "password")

	return &Config{
		AdminUsername:     adminUser,
		AdminUserPassword: adminPassword,
		DbPool:            dbpool,
	}, nil
}
