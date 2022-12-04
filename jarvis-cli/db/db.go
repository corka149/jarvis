package db

import (
	"context"
	"errors"
	"fmt"
	"github.com/corka149/jarvis/jarvis-cli/config"
	"github.com/google/uuid"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/bsontype"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"golang.org/x/crypto/bcrypt"
	"os"
	"time"
)

type Orga struct {
	ID   primitive.ObjectID `bson:"_id, omitempty"`
	Uuid primitive.Binary   `bson:"uuid,omitempty"`
	Name string             `bson:"name,omitempty"`
}

func (o *Orga) String() string {
	oUuid, err := uuid.FromBytes(o.Uuid.Data)

	if err != nil {
		return fmt.Sprintf("Orga{uuid: <%s>, name: %s}", err, o.Name)
	}

	return fmt.Sprintf("Orga{uuid: %s, name: %s}", oUuid, o.Name)
}

type User struct {
	ID               primitive.ObjectID `bson:"_id, omitempty"`
	Uuid             primitive.Binary   `bson:"uuid,omitempty"`
	OrganizationUuid primitive.Binary   `bson:"organization_uuid,omitempty"`
	Name             string             `bson:"name,omitempty"`
	Email            string             `bson:"email,omitempty"`
	Password         string             `bson:"password,omitempty"`
}

func (o *User) String() string {
	oUuid, err := uuid.FromBytes(o.OrganizationUuid.Data)

	var oUuidStr string

	if err != nil {
		oUuidStr = fmt.Sprintf("<%s>", err)
	} else {
		oUuidStr = oUuid.String()
	}

	uUuid, err := uuid.FromBytes(o.Uuid.Data)

	var uUuidStr string

	if err != nil {
		uUuidStr = fmt.Sprintf("<%s>", err)
	} else {
		uUuidStr = uUuid.String()
	}

	fmtStr := "User{uuid: %s, organization_uuid: %s, name: %s, email: %s}"

	return fmt.Sprintf(fmtStr, oUuidStr, uUuidStr, o.Name, o.Email)
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

// ============================
// ===== ===== ORGA ===== =====
// ============================

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

func (c *Client) AddOrga(name string) (*uuid.UUID, error) {
	ctx, cancel := defaultCtx()
	defer cancel()

	newUuid := uuid.New()

	newUuidBinary, err := newUuid.MarshalBinary()
	if err != nil {
		return nil, err
	}

	orga := bson.D{
		{"uuid", primitive.Binary{Subtype: bsontype.BinaryUUID, Data: newUuidBinary}},
		{"name", name},
	}

	coll := c.orgaColl()

	_, err = coll.InsertOne(ctx, orga)
	if err != nil {
		return nil, err
	}

	return &newUuid, nil
}

func (c *Client) DeleteOrga(name string) error {
	ctx, cancel := defaultCtx()
	defer cancel()

	query := bson.D{
		{"name", name},
	}

	result, err := c.orgaColl().DeleteOne(ctx, query)

	if result.DeletedCount != 1 {
		return errors.New("could not delete user")
	}

	return err
}

// ============================
// ===== ===== USER ===== =====
// ============================

func (c *Client) GetUser(email string) (*User, error) {
	coll := c.userColl()
	ctx, cancel := defaultCtx()
	defer cancel()
	cursor, err := coll.Find(ctx, bson.D{{"email", email}})
	if err != nil {
		return nil, err
	}

	if !cursor.Next(ctx) {
		return nil, nil
	}

	var user User
	err = cursor.Decode(&user)
	if err != nil {
		return nil, err
	}

	return &user, nil
}

func (c *Client) AddUser(name string, email string, password string, orga Orga) (*uuid.UUID, error) {
	ctx, cancel := defaultCtx()
	defer cancel()

	newUuid := uuid.New()

	newUuidBinary, err := newUuid.MarshalBinary()
	if err != nil {
		return nil, err
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	hashedPasswordPwd := string(hashedPassword)

	if err != nil {
		return nil, err
	}

	user := bson.D{
		{"uuid", primitive.Binary{Subtype: bsontype.BinaryUUID, Data: newUuidBinary}},
		{"organization_uuid", orga.Uuid},
		{"name", name},
		{"email", email},
		{"password", hashedPasswordPwd},
	}

	coll := c.userColl()

	_, err = coll.InsertOne(ctx, user)
	if err != nil {
		return nil, err
	}

	return &newUuid, nil
}

func (c *Client) DeleteByOrga(orga *Orga) (int64, error) {
	ctx, cancel := defaultCtx()
	defer cancel()

	query := bson.D{
		{"organization_uuid", orga.Uuid},
	}

	result, err := c.userColl().DeleteMany(ctx, query)

	return result.DeletedCount, err
}

func (c *Client) DeleteUser(email string) error {
	ctx, cancel := defaultCtx()
	defer cancel()

	query := bson.D{
		{"email", email},
	}

	result, err := c.userColl().DeleteOne(ctx, query)

	if result.DeletedCount != 1 {
		return errors.New("could not delete user")
	}

	return err
}

// ==============================
// ===== ===== HELPER ===== =====
// ==============================

func defaultCtx() (context.Context, context.CancelFunc) {
	return context.WithTimeout(context.Background(), 10*time.Second)
}

func (c *Client) orgaColl() *mongo.Collection {
	return c.mongoClient.Database("jarvis").Collection("organizations")
}

func (c *Client) userColl() *mongo.Collection {
	return c.mongoClient.Database("jarvis").Collection("users")
}
