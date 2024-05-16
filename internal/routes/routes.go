package routes

import (
	"github.com/corka149/jarvis/internal/store"
	"github.com/corka149/jarvis/internal/views"
	"github.com/julienschmidt/httprouter"
	"html/template"
	"log"
	"net/http"
)

func RegisterEndPoints(router *httprouter.Router, store *store.Store) *httprouter.Router {

	// Templates
	templates := views.Templates()

	router.GET("/", func(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
		renderTemplate(w, templates, "index.gohtml", nil)
	})

	// Display lists
	router.GET("/lists", func(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
		listPage := store.FetchLists(0, 25)

		renderTemplate(w, templates, "lists.gohtml", listPage)
	})
	router.GET("/lists-overview", func(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
		log.Printf("status = %s", r.URL.Query().Get("filter"))

		renderTemplate(w, templates, "lists_overview", nil)
	})
	router.GET("/lists/:id", func(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
		renderTemplate(w, templates, "lists_details.gohtml", nil)
	})

	// Save lists
	router.POST("/lists/:id", func(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
		renderTemplate(w, templates, "lists_details.gohtml", nil)
	})
	// Archive lists
	router.GET("/lists/:id/archived", func(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
		http.Redirect(w, r, "/lists", http.StatusFound)
	})

	// Auth
	router.GET("/login", func(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
		renderTemplate(w, templates, "login.gohtml", nil)
	})
	router.POST("/login", func(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
		http.Redirect(w, r, "/", http.StatusFound)
	})
	router.GET("/logout", func(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
		http.Redirect(w, r, "/", http.StatusFound)
	})

	return router
}

func renderTemplate(w http.ResponseWriter, templates *template.Template, name string, data any) {
	w.Header().Set("Content-Type", "text/html")
	w.WriteHeader(http.StatusOK)

	if err := templates.ExecuteTemplate(w, name, data); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}
