import { ComponentFixture, TestBed } from '@angular/core/testing';

import { MealOverviewComponent } from './meal-overview.component';

describe('MealOverviewComponent', () => {
  let component: MealOverviewComponent;
  let fixture: ComponentFixture<MealOverviewComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MealOverviewComponent]
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
