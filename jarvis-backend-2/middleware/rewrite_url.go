package middleware

import (
	"bytes"
	"fmt"
	"strings"

	"github.com/gin-gonic/gin"
)

// responseBodyWriter is a wrapper around http.ResponseWriter that allows us to read the response body
type responseBodyWriter struct {
	gin.ResponseWriter
	urlPrefix string
}

// Write intercepts the body content
func (w responseBodyWriter) Write(b []byte) (int, error) {
	var body bytes.Buffer

	body.Write(b)

	s := body.String()

	// Rewrite href
	newHref := fmt.Sprintf("href=\"%s/", w.urlPrefix)
	newBody := strings.ReplaceAll(s, "href=\"/", newHref)

	// Rewrite src
	newSrc := fmt.Sprintf("src=\"%s/", w.urlPrefix)
	newBody = strings.ReplaceAll(newBody, "src=\"/", newSrc)

	// Rewrite action
	newAction := fmt.Sprintf("action=\"%s/", w.urlPrefix)
	newBody = strings.ReplaceAll(newBody, "action=\"/", newAction)

	return w.ResponseWriter.Write([]byte(newBody))
}

func RewriteURL(urlPrefix string) gin.HandlerFunc {
	return func(c *gin.Context) {

		if urlPrefix == "" {
			c.Next()
			return
		}

		w := &responseBodyWriter{urlPrefix: urlPrefix, ResponseWriter: c.Writer}
		c.Writer = w

		// Process request
		c.Next()

		currentLocation := c.Writer.Header().Get("Location")

		if c.Writer.Status() == 302 && currentLocation != "" {
			newLocation := urlPrefix + currentLocation
			c.Writer.Header().Set("Location", newLocation)
		}
	}
}
