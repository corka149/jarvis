import { ComponentFixture, TestBed } from '@angular/core/testing';

import { WelcomeComponent } from './welcome.component';
import { MealService } from '../meal.service';
import { of } from 'rxjs';
import { MealCombo } from '../models/meal';

const pizza: MealCombo = {
  first: { id: 1, name: 'Pizza', category: 'MAIN' },
  second: { id: 2, name: '', category: '' },
  withSupplement: false,
};

const mealService = {
  getRandomMeals: () => of(pizza),
};

describe('WelcomeComponent', () => {
  let component: WelcomeComponent;
  let fixture: ComponentFixture<WelcomeComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [WelcomeComponent],
      providers: [{ provide: MealService, useValue: mealService }],
    }).compileComponents();

    fixture = TestBed.createComponent(WelcomeComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
    expect(component.mealCombo).toBe(pizza);
  });
});
