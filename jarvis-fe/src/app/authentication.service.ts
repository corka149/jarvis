import { HttpClient, HttpResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable, of } from 'rxjs';
import { catchError, map } from 'rxjs/operators';

const AUTH_API = '/v1/auth';

@Injectable({
  providedIn: 'root',
})
export class AuthenticationService {
  private _isLoggedIn = false;

  constructor(private httpClient: HttpClient) {
    this.loadState();
  }

  logIn(email: string, password: string): Observable<boolean> {
    const credentials = {
      email: email,
      password: password,
    };

    return this.httpClient
      .post(`${AUTH_API}/login`, credentials, { observe: 'response' })
      .pipe(map(this.handleLogin));
  }

  logOut() {
    this.httpClient.post(`${AUTH_API}/logout`, {}).subscribe();

    this._isLoggedIn = false;
    this.storeState();
  }

  /**
   * Checks if client is authenticated.
   */
  check(): Observable<boolean> {
    return this.httpClient
      .head(`${AUTH_API}/check`, { observe: 'response' })
      .pipe(
        map((response: HttpResponse<Object>) => response.status === 200),
        catchError((_err) => of(false))
      );
  }

  set isLoggedIn(loggedIn: boolean) {
    this._isLoggedIn = loggedIn;
  }

  get isLoggedIn(): boolean {
    this.loadState();
    return this._isLoggedIn;
  }

  private handleLogin(response: HttpResponse<Object>): boolean {
    let isLoggedIn = response.status === 200;
    localStorage.setItem('isLoggedIn', JSON.stringify(isLoggedIn));
    return isLoggedIn;
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
