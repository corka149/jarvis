package dto

type Meal struct {
	ID       int32  `json:"id"`
	Name     string `json:"name"`
	Category string `json:"category"`
}

type MealCombo struct {
	First          Meal `json:"first"`
	Second         Meal `json:"second"`
	WithSupplement bool `json:"withSupplement"`
}
