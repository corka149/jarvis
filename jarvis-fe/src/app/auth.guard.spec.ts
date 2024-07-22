import { TestBed } from '@angular/core/testing';

import { AuthGuard } from './auth.guard';
import { AuthenticationService } from './authentication.service';

describe('AuthGuard', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        {
          provide: AuthenticationService,
          useValue: {},
        },
      ],
    });
  });

  it('should be created', () => {
    expect(AuthGuard).toBeTruthy();
  });
});
