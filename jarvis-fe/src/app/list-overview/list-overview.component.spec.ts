import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ActivatedRoute } from '@angular/router';

import { ListOverviewComponent } from './list-overview.component';

const activatedRoute = {
  queryParams: {
    subscribe: () => {},
  },
};

describe('ListOverviewComponent', () => {
  let component: ListOverviewComponent;
  let fixture: ComponentFixture<ListOverviewComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ListOverviewComponent],
      providers: [
        {
          provide: ActivatedRoute,
          useValue: activatedRoute,
        },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(ListOverviewComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
