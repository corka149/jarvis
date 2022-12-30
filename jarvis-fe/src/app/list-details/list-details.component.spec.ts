import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FormBuilder } from '@angular/forms';
import {
  MAT_MOMENT_DATE_ADAPTER_OPTIONS,
  MomentDateAdapter,
} from '@angular/material-moment-adapter';
import { DateAdapter, MAT_DATE_LOCALE } from '@angular/material/core';
import { ListService } from '../list.service';

import { ListDetailsComponent } from './list-details.component';

describe('ListDetailsComponent', () => {
  let component: ListDetailsComponent;
  let fixture: ComponentFixture<ListDetailsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ListDetailsComponent],
      providers: [
        { provide: FormBuilder },
        {
          provide: DateAdapter,
          useClass: MomentDateAdapter,
          deps: [MAT_DATE_LOCALE, MAT_MOMENT_DATE_ADAPTER_OPTIONS],
        },
        {
          provide: ListDetailsComponent,
          useValue: {},
        },
        {
          provide: ListService,
          useValue: {},
        },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(ListDetailsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should be readonly', () => {
    component.listId = '1';
    component.readonly = true;

    expect(component.isReadonly).toBeTruthy();
  });

  it('should not be readonly on existing list in edit mode', () => {
    component.listId = '1';
    component.readonly = false;

    expect(component.isReadonly).toBeFalsy();
  });

  it('should not be readonly on new list', () => {
    component.listId = 'new';
    component.readonly = true;

    expect(component.isReadonly).toBeFalsy();
  });
});
