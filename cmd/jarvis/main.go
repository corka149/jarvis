package main

import (
	"github.com/corka149/jarvis/internal/migrations"
	"github.com/corka149/jarvis/internal/routes"
	"github.com/corka149/jarvis/internal/store"
	"github.com/julienschmidt/httprouter"
	"log"
	"net/http"
	"time"
)

func main() {
	if err := migrations.Execute(); err != nil {
		log.Fatal(err)
	}

	s := store.NewStore()
	s.SaveList(store.List{
		UpdateOn: time.Now(),
		Reason:   "Food",
		On:       time.Now(),
		Items: []store.Item{
			{
				Name:   "Bread",
				Amount: 1,
			},
		},
	})

	// ===== WEB =====

	router := httprouter.New()
	routes.RegisterEndPoints(router, s)

	// router serves static files from ./public directory
	router.ServeFiles("/public/*filepath", http.Dir("./public"))

	// ===== MIDDLEWARE =====
	router.PanicHandler = func(w http.ResponseWriter, r *http.Request, err interface{}) {
		log.Printf("%s\n", err)
	}

	log.Printf("Listening on http://localhost:3000")
	log.Fatal(http.ListenAndServe(":3000", router))
}
