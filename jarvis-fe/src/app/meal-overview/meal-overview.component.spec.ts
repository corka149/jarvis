import { ComponentFixture, TestBed } from '@angular/core/testing';

import { MealOverviewComponent } from './meal-overview.component';
import {MealService} from "../meal.service";
import {of} from "rxjs";


const mealService = {
  getMeals: () => of([])
};

describe('MealOverviewComponent', () => {
  let component: MealOverviewComponent;
  let fixture: ComponentFixture<MealOverviewComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MealOverviewComponent],
      providers: [
        { provide: MealService, useValue: mealService }
      ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(MealOverviewComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
