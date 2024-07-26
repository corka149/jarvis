import { Injectable } from '@angular/core';
import {HttpClient, HttpParams} from '@angular/common/http';
import { Observable } from 'rxjs';
import { Meal, MealCombo } from './models/meal';

const MEAL_URL = 'v6/api/meals';

@Injectable({
  providedIn: 'root',
})
export class MealService {
  constructor(private http: HttpClient) {}

  getRandomMeals(): Observable<MealCombo> {
    return this.http.get<MealCombo>(MEAL_URL + '/random');
  }

  getMeals(searchTerm?: string): Observable<Meal[]> {
    let params = new HttpParams();

    if (searchTerm) {
      params = params.set('search', searchTerm);
    }

    return this.http.get<Meal[]>(MEAL_URL, { params });
  }

  getMeal(id: number): Observable<Meal> {
    return this.http.get<Meal>(`${MEAL_URL}/${id}`);
  }

  addMeal(meal: Meal): Observable<Meal> {
    return this.http.post<Meal>(MEAL_URL, meal);
  }

  updateMeal(mealId: number, meal: Meal): Observable<Meal> {
    return this.http.put<Meal>(`${MEAL_URL}/${mealId}`, meal);
  }

  deleteMeal(mealId: number): Observable<void> {
    return this.http.delete<void>(`${MEAL_URL}/${mealId}`);
  }
}
