package db

import (
	"context"
	"fmt"
	"github.com/corka149/jarvis/jarvis-cli/config"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"time"
)

type Client struct {
	mongoClient *mongo.Client
}

func New() (*Client, error) {
	client, err := mongo.NewClient(options.Client().ApplyURI(config.Config.Database.Connection))
	if err != nil {
		return nil, err
	}

	ctx, cancel := defaultCtx()
	defer cancel()
	err = client.Connect(ctx)
	if err != nil {
		return nil, err
	}

	return &Client{mongoClient: client}, nil
}

func (c *Client) Disconnect() error {
	ctx, cancel := defaultCtx()
	defer cancel()
	return c.mongoClient.Disconnect(ctx)
}

func (c *Client) AddOrga() error {
	ctx, cancel := defaultCtx()
	defer cancel()
	databases, err := c.mongoClient.ListDatabaseNames(ctx, bson.M{})
	if err != nil {
		return err
	}
	fmt.Println(databases)

	return nil
}

func defaultCtx() (context.Context, context.CancelFunc) {
	return context.WithTimeout(context.Background(), 10*time.Second)
}
