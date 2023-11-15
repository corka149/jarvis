package routes

import "github.com/gofiber/fiber/v2"

func RegisterEndpoints(app *fiber.App) {
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
