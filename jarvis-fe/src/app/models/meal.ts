
export interface Meal {
  id: number
  name: string
  category: string
}

export interface MealCombo {
  first: Meal
  second: Meal
  withSupplement: boolean
}
