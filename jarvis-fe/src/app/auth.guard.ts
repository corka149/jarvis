import { inject, Injectable } from '@angular/core';
import {
  ActivatedRouteSnapshot,
  CanActivateFn,
  Router,
  RouterStateSnapshot,
  UrlTree,
} from '@angular/router';
import { map, Observable, tap } from 'rxjs';
import { AuthenticationService } from './authentication.service';

@Injectable({
  providedIn: 'root',
})
class PermissionsService {
  private loginUrl: UrlTree;

  constructor(
    private authService: AuthenticationService,
    private router: Router,
  ) {
    this.loginUrl = router.parseUrl('/login');
  }

  canActivate(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot,
  ): Observable<boolean | UrlTree> {
    return this.authService.check().pipe(
      tap((success: boolean) => {
        if (!success) this.authService.logOut();
      }),
      map((success: boolean) => (success ? success : this.loginUrl)),
    );
  }
}

export const AuthGuard: CanActivateFn = (
  next: ActivatedRouteSnapshot,
  state: RouterStateSnapshot,
): Observable<boolean | UrlTree> => {
  return inject(PermissionsService).canActivate(next, state);
};
