import { TestBed } from '@angular/core/testing';
import { AppComponent } from './app.component';
import { AuthenticationService } from './authentication.service';
import { MatSnackBar } from '@angular/material/snack-bar';

const matSnackBar = jasmine.createSpyObj('MatSnackBar', ['open']);

describe('AppComponent', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [AppComponent],
      providers: [
        {
          provide: AuthenticationService,
          useValue: {},
        },
        { provide: MatSnackBar, useValue: matSnackBar },
      ],
    }).compileComponents();
  });

  it('should create the app', () => {
    const fixture = TestBed.createComponent(AppComponent);
    const app = fixture.componentInstance;
    expect(app).toBeTruthy();
  });

  it(`should have as title 'jARVIS'`, () => {
    const fixture = TestBed.createComponent(AppComponent);
    const app = fixture.componentInstance;
    expect(app.title).toEqual('jARVIS');
  });
});
