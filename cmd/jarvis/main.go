package main

import (
	"github.com/corka149/jarvis/internal/migrations"
	"github.com/corka149/jarvis/internal/routes"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/gofiber/template/html/v2"
	"log"
)

func main() {
	if err := migrations.Execute(); err != nil {
		log.Fatal(err)
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

	routes.RegisterEndpoints(app)

	log.Fatal(app.Listen(":3000"))
}
