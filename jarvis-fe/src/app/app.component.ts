import { Component } from '@angular/core';
import { BreakpointObserver, Breakpoints } from '@angular/cdk/layout';
import { Observable } from 'rxjs';
import { map, shareReplay } from 'rxjs/operators';
import { AuthenticationService } from './authentication.service';
import { Router, RouterLink, RouterOutlet } from '@angular/router';
import {
  MatSidenav,
  MatSidenavContainer,
  MatSidenavContent,
} from '@angular/material/sidenav';
import { MatSnackBar } from '@angular/material/snack-bar';
import { MatIcon } from '@angular/material/icon';
import { MatIconButton, MatMiniFabAnchor } from '@angular/material/button';
import { MatDivider } from '@angular/material/divider';
import { MatNavList, MatListItem } from '@angular/material/list';
import { AsyncPipe, NgOptimizedImage } from '@angular/common';
import { MatToolbar } from '@angular/material/toolbar';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
  standalone: true,
  imports: [
    MatSidenavContainer,
    MatSidenav,
    MatToolbar,
    MatNavList,
    MatListItem,
    RouterLink,
    MatDivider,
    MatSidenavContent,
    MatIconButton,
    MatIcon,
    MatMiniFabAnchor,
    RouterOutlet,
    AsyncPipe,
    NgOptimizedImage,
  ],
})
export class AppComponent {
  title = 'jARVIS';

  isHandset$: Observable<boolean> = this.breakpointObserver
    .observe(Breakpoints.Handset)
    .pipe(
      map((result) => result.matches),
      shareReplay(),
    );

  constructor(
    private breakpointObserver: BreakpointObserver,
    private router: Router,
    public authService: AuthenticationService,
    private matSnackBar: MatSnackBar,
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
