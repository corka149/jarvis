import { TestBed } from '@angular/core/testing';
import { AppComponent } from './app.component';
import { AuthenticationService } from './authentication.service';
import { MatSnackBar } from '@angular/material/snack-bar';
import { NoopAnimationsModule } from "@angular/platform-browser/animations";
import {MAT_DATE_FORMATS} from "@angular/material/core";
import {ActivatedRoute} from "@angular/router";

const matSnackBar = jasmine.createSpyObj('MatSnackBar', ['open']);

describe('AppComponent', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
    imports: [AppComponent, NoopAnimationsModule],
    providers: [
        {
            provide: AuthenticationService,
            useValue: {},
        },
        { provide: MatSnackBar, useValue: matSnackBar },
        { provide: MAT_DATE_FORMATS, useValue: {}},
        { provide: ActivatedRoute, useValue: {}}
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
