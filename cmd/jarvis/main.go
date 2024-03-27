package main

import (
	"github.com/corka149/jarvis/internal/migrations"
	"github.com/corka149/jarvis/internal/routes"
	"github.com/julienschmidt/httprouter"
	"log"
	"net/http"
)

func main() {
	if err := migrations.Execute(); err != nil {
		log.Fatal(err)
	}

	// ===== WEB =====

	router := httprouter.New()
	routes.RegisterEndPoints(router)

	// router serves static files from ./public directory
	router.ServeFiles("/public/*filepath", http.Dir("./public"))

	// ===== MIDDLEWARE =====
	router.PanicHandler = func(w http.ResponseWriter, r *http.Request, err interface{}) {
		log.Printf("%s\n", err)
	}

	log.Printf("Listening on http://localhost:3000")
	log.Fatal(http.ListenAndServe(":3000", router))
}
