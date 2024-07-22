import {Component, OnInit} from '@angular/core';
import {MealService} from "../meal.service";
import {Meal} from "../models/meal";
import {RouterLink} from "@angular/router";
import {MatList, MatListItem} from "@angular/material/list";
import {MatLine} from "@angular/material/core";
import {MatAnchor} from "@angular/material/button";

@Component({
  selector: 'app-meal-overview',
  standalone: true,
  imports: [
    RouterLink,
    MatList,
    MatLine,
    MatListItem,
    MatAnchor
  ],
  templateUrl: './meal-overview.component.html',
  styleUrl: './meal-overview.component.css'
})
export class MealOverviewComponent implements OnInit {

  meals?: Meal[];

  constructor(
    private mealService: MealService
  ) {

  }

  ngOnInit(): void {
    this.mealService.getMeals().subscribe(meals => this.meals = meals);
    }


}
