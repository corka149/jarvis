package dto

type Meal struct {
	Name     string
	Category string
}

type MealCombo struct {
	First          Meal
	Second         Meal
	WithSupplement bool
}
