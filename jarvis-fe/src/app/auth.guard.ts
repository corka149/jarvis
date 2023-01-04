import { Injectable } from '@angular/core';
import {
  ActivatedRouteSnapshot,
  CanActivate,
  Router,
  RouterStateSnapshot,
  UrlTree,
} from '@angular/router';
import { catchError, map, Observable, of, tap } from 'rxjs';
import { AuthenticationService } from './authentication.service';

@Injectable({
  providedIn: 'root',
})
export class AuthGuard implements CanActivate {
  private loginUrl: UrlTree;

  constructor(
    private authService: AuthenticationService,
    private router: Router
  ) {
    this.loginUrl = router.parseUrl('/login');
  }

  canActivate(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ):
    | Observable<boolean | UrlTree>
    | Promise<boolean | UrlTree>
    | boolean
    | UrlTree {
    return this.authService.check().pipe(
      tap((success: boolean) => {
        if (!success) this.authService.logOut();
      }),
      map((success: boolean) => (success ? success : this.loginUrl))
    );
  }
}
