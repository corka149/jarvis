import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { Observable, of } from 'rxjs';
import { AuthenticationService } from './authentication.service';
import { MatSnackBar } from '@angular/material/snack-bar';

@Injectable({
  providedIn: 'root',
})
export class ErrorHandlerService {
  constructor(
    private authService: AuthenticationService,
    private router: Router,
    private matSnackBar: MatSnackBar,
  ) {}

  public handleError<T>(
    elseReturn: T,
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

      const status = error.status ? error.status : 'Error';
      const errMsg = error.error ? error.error : 'Something went wrong';
      const msg = `${status}: ${errMsg}`;

      self.matSnackBar.open(msg, '❌');

      if (!elseReturn) {
        throw error;
      }

      return of(elseReturn);
    };
  }
}
