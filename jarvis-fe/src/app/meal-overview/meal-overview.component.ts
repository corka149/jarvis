import {Component, OnDestroy, OnInit} from '@angular/core';
import { MealService } from '../meal.service';
import { Meal } from '../models/meal';
import { RouterLink } from '@angular/router';
import { MatList, MatListItem } from '@angular/material/list';
import { MatLine } from '@angular/material/core';
import { MatAnchor } from '@angular/material/button';
import {FormControl, ReactiveFormsModule} from "@angular/forms";
import {debounceTime, distinctUntilChanged} from "rxjs/operators";

@Component({
  selector: 'app-meal-overview',
  standalone: true,
  imports: [RouterLink, MatList, MatLine, MatListItem, MatAnchor, ReactiveFormsModule],
  templateUrl: './meal-overview.component.html',
  styleUrl: './meal-overview.component.css',
})
export class MealOverviewComponent implements OnInit {
  meals?: Meal[];
  searchControl = new FormControl();

  constructor(private mealService: MealService) {}

  ngOnInit(): void {
    this.getMeals();

    this.searchControl.valueChanges
      .pipe(debounceTime(500), distinctUntilChanged())
      .subscribe((searchTerm) => {
        this.searchFor(searchTerm);
      });
  }

  private getMeals(searchTerm?: string) {
    this.mealService.getMeals(searchTerm).subscribe((meals) => (this.meals = meals));
  }

  searchFor(searchTerm?: string) {
    if (searchTerm) {
      this.getMeals(searchTerm);
    } else {
      this.getMeals();
    }
  }
}
