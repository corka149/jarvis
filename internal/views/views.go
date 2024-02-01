package views

import (
	"html/template"
	"log"
)

func Templates() *template.Template {
	templates, err := template.ParseGlob("./views/*.gohtml")
	if err != nil {
		log.Fatal(err)
	}

	return templates
}
