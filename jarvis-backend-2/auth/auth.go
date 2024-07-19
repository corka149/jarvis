package auth

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"time"
)

type AuthClient struct {
	Url              string
	SuccessFullCheck map[string]time.Time
}

func NewAuthClient(url string) *AuthClient {
	return &AuthClient{
		Url:              url,
		SuccessFullCheck: make(map[string]time.Time),
	}
}

func (a *AuthClient) CheckAuthenticated(ctx context.Context, token string) (bool, error) {
	// Check if the token was already checked in last 5 minutes
	if wasChecked, ok := a.SuccessFullCheck[token]; ok {
		if time.Since(wasChecked) < 5*time.Minute {
			return true, nil
		} else {
			log.Println("Token was checked more than 5 minutes ago. Checking again.")
			delete(a.SuccessFullCheck, token)
		}
	}

	req, err := http.NewRequest("HEAD", a.Url+"/v1/auth/check", nil)

	if err != nil {
		return false, fmt.Errorf("error creating request: %w", err)
	}

	req.Header.Set("Cookie", token)

	client := &http.Client{}

	resp, err := client.Do(req)

	if err != nil {
		return false, fmt.Errorf("error checking authentication: %w", err)
	}

	isAuthenticated := resp.StatusCode == http.StatusOK

	if isAuthenticated {
		a.SuccessFullCheck[token] = time.Now()
	}

	return isAuthenticated, nil
}
