import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { Observable, of } from 'rxjs';
import { AuthenticationService } from './authentication.service';

@Injectable({
  providedIn: 'root',
})
export class ErrorHandlerService {
  constructor(
    private authService: AuthenticationService,
    private router: Router
  ) {}

  public handleError<T>(
    elseReturn: T
  ): (error: any, caught: Observable<T>) => Observable<T> {
    const self = this;

    return function (error, caught: Observable<T>): Observable<T> {
      if (
        error &&
        error.status &&
        (error.status === 403 || error.status === 401)
      ) {
        self.authService.logOut();
        self.router.navigate(['/login']);
      }

      return of(elseReturn);
    };
  }
}
