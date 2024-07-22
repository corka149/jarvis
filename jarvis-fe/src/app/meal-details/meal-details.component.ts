import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { MealService } from '../meal.service';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { Meal } from '../models/meal';
import { MatFormField, MatLabel } from '@angular/material/form-field';
import { MatInput } from '@angular/material/input';
import { Observable, Observer } from 'rxjs';
import { MatIcon } from '@angular/material/icon';
import { MatMiniFabButton } from '@angular/material/button';
import Swal from 'sweetalert2';

@Component({
  selector: 'app-meal-details',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    MatFormField,
    MatInput,
    MatLabel,
    MatIcon,
    MatMiniFabButton,
  ],
  templateUrl: './meal-details.component.html',
  styleUrl: './meal-details.component.css',
})
export class MealDetailsComponent implements OnInit {
  mealId?: number;
  mealForm?: FormGroup;

  constructor(
    private route: ActivatedRoute,
    private fb: FormBuilder,
    private router: Router,
    private mealService: MealService,
  ) {}

  ngOnInit(): void {
    const maybeId = this.route.snapshot.paramMap.get('id');
    this.mealId = maybeId ? +maybeId : undefined;

    if (this.mealId) {
      this.mealService.getMeal(this.mealId).subscribe((meal) => {
        if (!!meal) {
          this.setupForm(meal);
        }
      });
    } else {
      this.setupForm(undefined);
    }
  }

  setupForm(meal?: Meal) {
    this.mealForm = this.fb.group({
      name: [meal ? meal.name : '', Validators.required],
      category: [meal ? meal.category : '', Validators.required],
    });
  }

  onSubmit() {
    if (this.mealForm?.valid) {
      const meal = this.mealForm.value as Meal;

      let observer: Observable<Meal>;

      if (this.mealId) {
        observer = this.mealService.updateMeal(this.mealId, meal);
      } else {
        observer = this.mealService.addMeal(meal);
      }

      observer.subscribe(async () => {
        await this.router.navigate(['/meals']);
      });
    }
  }

  deleteMeal() {
    if (this.mealId) {
      const mealId = this.mealId;

      Swal.fire({
        title: 'Soll das Gericht endgültig gelöscht werden?',
        showDenyButton: true,
        confirmButtonText: `Ja`,
        denyButtonText: `Nein`,
      }).then((result) => {
        if (result.isConfirmed) {
          this.mealService.deleteMeal(mealId).subscribe(async () => {
            await this.router.navigate(['/meals']);
          });
        }
      });
    }
  }

  get category(): string | undefined {
    return this.mealForm?.get('category')?.value;
  }
}
