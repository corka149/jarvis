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

  constructor() {
    this.loadState();
  }

  logIn(username: string, password: string): Observable<boolean> {
    this._isLoggedIn = USER.name === username && USER.password === password;
    this.storeState();
    return of(this._isLoggedIn);
  }

  logOut() {
    this._isLoggedIn = false;
    this.storeState();
  }

  get isLoggedIn(): boolean {
    return this._isLoggedIn;
  }

  private loadState() {
    const isLoggedIn = localStorage.getItem('isLoggedIn');
    this._isLoggedIn = isLoggedIn ? JSON.parse(isLoggedIn) : false;
  }

  private storeState() {
    const isLoggedIn = JSON.stringify(this._isLoggedIn);
    localStorage.setItem('isLoggedIn', isLoggedIn);
  }
}
