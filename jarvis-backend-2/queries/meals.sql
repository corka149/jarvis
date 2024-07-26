-- name: GetMeals :many
SELECT * FROM meals;

-- name: SearchMeals :many
SELECT * FROM meals WHERE name ILIKE '%' || @searchTerm::text || '%';

-- name: GetMeal :one
SELECT * FROM meals WHERE id = $1;

-- name: CreateMeal :one
INSERT INTO meals (name, category) VALUES ($1, $2) RETURNING *;

-- name: UpdateMeal :one
UPDATE meals SET name = $1, category = $2 WHERE id = $3 RETURNING *;

-- name: DeleteMeal :exec
DELETE FROM meals WHERE id = $1;
