-- +goose Up
-- +goose StatementBegin
CREATE TABLE meals (
  id SERIAL PRIMARY KEY,
  name VARCHAR(64) NOT NULL,
  category VARCHAR(32) NOT NULL
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE meals;
-- +goose StatementEnd
