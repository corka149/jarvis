// / This file contains the setup function for the Jarvis package.
// / The configuration can be done by the following environment variables:
// / - ADMIN_USER: The username for the admin user. Default is "admin".
// / - ADMIN_PASSWORD: The password for the admin user. Default is "password".
// / - DB_URL: The URL for the database. Default is "postgres://myadmin:mypassword@localhost:5432/jarvis_db".
// / - URL_PREFIX: The URL prefix for the application. Default is "".
package jarvis

import (
	"cmp"
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Config struct {
	AdminUsername     string
	AdminUserPassword string
	DbPool            *pgxpool.Pool
	UrlPrefix         string
}

const (
	defaultDbURL         = "postgres://myadmin:mypassword@localhost:5432/jarvis_db"
	defaultAdminUser     = "admin"
	defaultAdminPassword = "password"
	defaultUrlPrefix     = ""
)

func Setup(ctx context.Context, getenv func(string) string) (*Config, error) {
	dbUrl := cmp.Or(getenv("DB_URL"), defaultDbURL)

	dbpool, err := pgxpool.New(ctx, dbUrl)

	if err != nil {
		return nil, err
	}

	adminUser := cmp.Or(getenv("ADMIN_USER"), defaultAdminUser)
	adminPassword := cmp.Or(getenv("ADMIN_PASSWORD"), defaultAdminPassword)
	urlPrefix := cmp.Or(getenv("URL_PREFIX"), defaultUrlPrefix)

	return &Config{
		AdminUsername:     adminUser,
		AdminUserPassword: adminPassword,
		DbPool:            dbpool,
		UrlPrefix:         urlPrefix,
	}, nil
}
