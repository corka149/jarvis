import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { catchError, of } from 'rxjs';
import { AuthenticationService } from '../authentication.service';
import { Credentials } from '../models/credentials';

@Component({
  selector: 'app-log-in',
  templateUrl: './log-in.component.html',
  styleUrls: ['./log-in.component.css'],
})
export class LogInComponent implements OnInit {
  loginForm?: FormGroup;
  error?: string;

  constructor(
    private fb: FormBuilder,
    private authService: AuthenticationService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.loginForm = this.fb.group({
      username: ['', Validators.required],
      password: ['', Validators.required],
    });
  }

  onSubmit() {
    this.error = undefined;

    if (this.loginForm?.valid) {
      const creds: Credentials = this.loginForm.value;
      this.authService
        .logIn(creds.username, creds.password)
        .pipe(
          catchError(err => {
            this.error = 'Anmeldung fehlgeschlagen';
            console.log(err);
            return of(false);
          })
        )
        .subscribe((success) => {
          if (success) {
            this.router.navigate(['/welcome']);
          } else {
            this.error = 'Anmeldung fehlgeschlagen';
          }
        });
    }
  }
}
