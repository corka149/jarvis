import { ComponentFixture, TestBed } from '@angular/core/testing';

import { MealDetailsComponent } from './meal-details.component';
import { ActivatedRoute } from '@angular/router';
import { MealService } from '../meal.service';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';

const activatedRoute = {
  snapshot: {
    paramMap: {
      get: (key: string) => {},
    },
  },
};

const mockMealService = {};

describe('MealDetailsComponent', () => {
  let component: MealDetailsComponent;
  let fixture: ComponentFixture<MealDetailsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MealDetailsComponent, NoopAnimationsModule],
      providers: [
        {
          provide: ActivatedRoute,
          useValue: activatedRoute,
        },
        {
          provide: MealService,
          useValue: mockMealService,
        },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(MealDetailsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
