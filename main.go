package main

import (
	"database/sql"
	"embed"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/gofiber/template/html/v2"
	"github.com/golang-migrate/migrate/v4"
	"log"

	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	"github.com/golang-migrate/migrate/v4/source/iofs"
	_ "github.com/lib/pq"
)

const dbURL = "postgres://postgres:postgres@localhost:54321/jarvis?sslmode=disable"

//go:embed migrations/*.sql
var migrationsFS embed.FS

func main() {
	// ===== DATABASE =====
	dbConn, err := sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatal(err)
	}
	defer func(dbConn *sql.DB) {
		err := dbConn.Close()
		if err != nil {
			log.Fatal(err)
		}
	}(dbConn)

	if runMigrate(err) {
		return
	}

	// ===== WEB =====

	engine := html.New("./views", ".gohtml")

	app := fiber.New(fiber.Config{
		Views:       engine,
		ViewsLayout: "_root",
	})

	app.Static("/", "./public")

	// Middleware
	app.Use(recover.New())

	registerEndpoints(app)

	log.Fatal(app.Listen(":3000"))
}

func registerEndpoints(app *fiber.App) {
	app.Get("/", func(c *fiber.Ctx) error {
		return c.Render("index", fiber.Map{
			"Title": "Welcome to Jarvis!",
		})
	})

	// Lists
	app.Get("/lists", func(c *fiber.Ctx) error {
		return c.Render("lists", fiber.Map{})
	})

	app.Get("/lists/:id", func(c *fiber.Ctx) error {
		return c.Render("lists_details", fiber.Map{})
	})

	// Auth
	app.Get("/login", func(c *fiber.Ctx) error {
		return c.Render("login", fiber.Map{})
	})
	app.Get("/logout", func(c *fiber.Ctx) error {
		return c.Render("logout", fiber.Map{})
	})
}

func runMigrate(err error) bool {
	d, err := iofs.New(migrationsFS, "migrations")
	if err != nil {
		log.Println(err)
		return true
	}

	migrations, err := migrate.NewWithSourceInstance("iofs", d, dbURL)
	if err != nil {
		log.Println(err)
		return true
	}

	err = migrations.Up()
	if err != nil && err.Error() != "no change" {
		log.Println(err)
		return true
	}

	return false
}
