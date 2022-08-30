import { Injectable } from '@angular/core';
import { Observable, of } from 'rxjs';

const USER = {
  name: 'jarvis',
  password: 'password',
};

@Injectable({
  providedIn: 'root',
})
export class AuthenticationService {
  private _isLoggedIn = false;

  constructor() {}

  logIn(username: string, password: string): Observable<boolean> {
    this._isLoggedIn = USER.name === username && USER.password === password;

    return of(this._isLoggedIn);
  }

  get isLoggedIn(): boolean {
    return this._isLoggedIn;
  }
}
