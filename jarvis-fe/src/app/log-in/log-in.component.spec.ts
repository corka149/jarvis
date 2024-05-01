import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FormBuilder } from '@angular/forms';
import { MatLegacySnackBar as MatSnackBar } from '@angular/material/legacy-snack-bar';
import { Router } from '@angular/router';
import { AuthenticationService } from '../authentication.service';

import { LogInComponent } from './log-in.component';

const routerSpy = jasmine.createSpyObj('Router', ['navigate']);
const authService = jasmine.createSpyObj('AuthenticationService', ['logIn']);
const matSnackBar = jasmine.createSpyObj('MatSnackBar', ['open']);

describe('LogInComponent', () => {
  let component: LogInComponent;
  let fixture: ComponentFixture<LogInComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [LogInComponent],
      providers: [
        { provide: Router, useValue: routerSpy },
        { provide: FormBuilder },
        { provide: AuthenticationService, useValue: authService },
        { provide: MatSnackBar, useValue: matSnackBar },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(LogInComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
