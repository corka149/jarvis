package middleware

import (
	"context"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

type AuthChecker interface {
	CheckAuthenticated(ctx context.Context, token string) (bool, error)
}

func AuthCheck(ctx context.Context, authCheck AuthChecker) gin.HandlerFunc {

	return func(c *gin.Context) {
		token := c.GetHeader("Cookie")

		if token == "" {
			c.AbortWithStatus(http.StatusUnauthorized)
			return
		}

		isAuthenticated, err := authCheck.CheckAuthenticated(c.Request.Context(), token)

		if err != nil {
			log.Println("Abort auth check with error: ", err)
		}

		if !isAuthenticated {
			c.AbortWithStatus(http.StatusUnauthorized)
			return
		}

		c.Next()
	}
}
