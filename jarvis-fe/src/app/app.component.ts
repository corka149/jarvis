import { Component } from '@angular/core';
import { BreakpointObserver, Breakpoints } from '@angular/cdk/layout';
import { Observable } from 'rxjs';
import { map, shareReplay } from 'rxjs/operators';
import { AuthenticationService } from './authentication.service';
import { Router } from '@angular/router';
import { MatSidenav } from '@angular/material/sidenav';
import { MatLegacySnackBar as MatSnackBar } from '@angular/material/legacy-snack-bar';
@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
})
export class AppComponent {
  title = 'jARVIS';

  isHandset$: Observable<boolean> = this.breakpointObserver
    .observe(Breakpoints.Handset)
    .pipe(
      map((result) => result.matches),
      shareReplay()
    );

  constructor(
    private breakpointObserver: BreakpointObserver,
    private router: Router,
    public authService: AuthenticationService,
    private matSnackBar: MatSnackBar
  ) {}

  logOut() {
    this.authService.logOut();
    this.router.navigate(['welcome']);
    this.matSnackBar.open('Bye bye', '❌', {
      duration: 3 * 1000,
    });
  }

  toggleDrawer(drawer: MatSidenav) {
    if (window.screen.width < 960) {
      drawer.toggle();
    }
  }
}
