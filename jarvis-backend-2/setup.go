package jarvis

import (
	"cmp"
	"context"
	"os"

	pgx "github.com/jackc/pgx/v5"
)

const defaultDbURL = "postgres://myadmin:mypassword@localhost:5432/jarvis_db"

func CreateDbConn(ctx context.Context) (*pgx.Conn, error) {
	dbUrl := cmp.Or(os.Getenv("DB_URL"), defaultDbURL)

	return pgx.Connect(ctx, dbUrl)
}
