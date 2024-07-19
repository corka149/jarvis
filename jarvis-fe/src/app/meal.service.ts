import {Injectable} from "@angular/core";
import {HttpClient} from "@angular/common/http";
import {Observable} from "rxjs";
import {MealCombo} from "./models/meal";

const MEAL_URL = "v6/api/meals";

@Injectable({
  providedIn: 'root',
})
export class MealService {
  constructor(private http: HttpClient) { }

  getRandomMeals(): Observable<MealCombo> {
    return this.http.get<MealCombo>(MEAL_URL + "/random");
  }
}
