import {Injectable} from "@angular/core";
import {HttpClient} from "@angular/common/http";
import {Observable} from "rxjs";
import {Meal, MealCombo} from "./models/meal";

const MEAL_URL = "v6/api/meals";

@Injectable({
  providedIn: 'root',
})
export class MealService {
  constructor(private http: HttpClient) { }

  getRandomMeals(): Observable<MealCombo> {
    return this.http.get<MealCombo>(MEAL_URL + "/random");
  }

  getMeals(): Observable<Meal[]> {
    return this.http.get<Meal[]>(MEAL_URL);
  }

  getMeal(id: number): Observable<Meal> {
    return this.http.get<Meal>(`${MEAL_URL}/${id}`);
  }

  addMeal(meal: Meal): Observable<Meal> {
    return this.http.post<Meal>(MEAL_URL, meal);
  }

  updateMeal(meal: Meal): Observable<Meal> {
    return this.http.put<Meal>(`${MEAL_URL}/${meal.id}`, meal);
  }
}
