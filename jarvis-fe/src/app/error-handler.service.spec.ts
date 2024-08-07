import { TestBed } from '@angular/core/testing';
import { AuthenticationService } from './authentication.service';

import { ErrorHandlerService } from './error-handler.service';
import { MatSnackBar } from '@angular/material/snack-bar';

const matSnackBar = jasmine.createSpyObj('MatSnackBar', ['open']);

describe('ErrorHandlerService', () => {
  let service: ErrorHandlerService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        {
          provide: AuthenticationService,
          useValue: {},
        },
        { provide: MatSnackBar, useValue: matSnackBar },
      ],
    });
    service = TestBed.inject(ErrorHandlerService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
