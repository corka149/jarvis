package db

import (
	"context"
	"fmt"
	"github.com/corka149/jarvis/jarvis-cli/config"
	"github.com/google/uuid"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"os"
	"time"
)

type Orga struct {
	ID   primitive.ObjectID `bson:"_id, omitempty"`
	Uuid string             `bson:"uuid,omitempty"`
	Name string             `bson:"name,omitempty"`
}

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

func (c *Client) Disconnect() {
	ctx, cancel := defaultCtx()
	defer cancel()
	err := c.mongoClient.Disconnect(ctx)
	if err != nil {
		fmt.Println(err.Error())
		os.Exit(1)
	}
}

func (c *Client) GetOrga(name string) (*Orga, error) {
	coll := c.orgaColl()
	ctx, cancel := defaultCtx()
	defer cancel()
	cursor, err := coll.Find(ctx, bson.D{{"name", name}})
	if err != nil {
		return nil, err
	}

	if !cursor.Next(ctx) {
		return nil, nil
	}

	var orga Orga
	err = cursor.Decode(&orga)
	if err != nil {
		return nil, err
	}

	return &orga, nil
}

func (c *Client) AddOrga(name string) (*string, error) {
	ctx, cancel := defaultCtx()
	defer cancel()

	newUuid := uuid.New().String()

	orga := bson.D{
		{"uuid", newUuid},
		{"name", name},
	}

	coll := c.orgaColl()

	_, err := coll.InsertOne(ctx, orga)
	if err != nil {
		return nil, err
	}

	return &newUuid, nil
}

func defaultCtx() (context.Context, context.CancelFunc) {
	return context.WithTimeout(context.Background(), 10*time.Second)
}

func (c *Client) orgaColl() *mongo.Collection {
	return c.mongoClient.Database("jarvis").Collection("organization")
}