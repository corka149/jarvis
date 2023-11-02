package main

import (
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/gofiber/template/html/v2"
	"log"
)

func main() {
	engine := html.New("./views", ".gohtml")

	app := fiber.New(fiber.Config{
		Views:       engine,
		ViewsLayout: "_root",
	})

	app.Use(recover.New())

	app.Static("/", "./public")

	app.Get("/", func(c *fiber.Ctx) error {
		return c.Render("index", fiber.Map{
			"Title": "Welcome to Jarvis!",
		})
	})

	app.Get("/lists", func(c *fiber.Ctx) error {
		return c.Render("lists", fiber.Map{})
	})

	log.Fatal(app.Listen(":3000"))
}
