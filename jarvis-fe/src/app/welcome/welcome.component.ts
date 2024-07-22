import { Component, OnInit } from '@angular/core';
import { MealService } from '../meal.service';
import { MealCombo } from '../models/meal';
import { MatButton } from '@angular/material/button';

@Component({
  selector: 'app-welcome',
  templateUrl: './welcome.component.html',
  styleUrls: ['./welcome.component.css'],
  standalone: true,
  imports: [MatButton],
})
export class WelcomeComponent implements OnInit {
  constructor(private mealService: MealService) {}

  mealCombo?: MealCombo;

  ngOnInit(): void {
    this.nextMeal();
  }

  nextMeal() {
    this.mealService
      .getRandomMeals()
      .subscribe((meals) => (this.mealCombo = meals));
  }
}
