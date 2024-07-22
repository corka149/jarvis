import { Component, OnInit } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  Validators,
  ReactiveFormsModule,
} from '@angular/forms';
import { Router } from '@angular/router';
import { catchError, of } from 'rxjs';
import { AuthenticationService } from '../authentication.service';
import { Credentials } from '../models/credentials';
import { MatSnackBar } from '@angular/material/snack-bar';
import { MatButton } from '@angular/material/button';
import { MatInput } from '@angular/material/input';
import { MatFormField, MatLabel, MatError } from '@angular/material/form-field';

@Component({
  selector: 'app-log-in',
  templateUrl: './log-in.component.html',
  styleUrls: ['./log-in.component.css'],
  standalone: true,
  imports: [
    ReactiveFormsModule,
    MatFormField,
    MatLabel,
    MatInput,
    MatButton,
    MatError,
  ],
})
export class LogInComponent implements OnInit {
  loginForm?: FormGroup;
  error?: string;

  constructor(
    private fb: FormBuilder,
    private authService: AuthenticationService,
    private router: Router,
    private snackBar: MatSnackBar,
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
          catchError((err) => {
            this.error = 'Anmeldung fehlgeschlagen';
            return of(false);
          }),
        )
        .subscribe((success) => {
          if (success) {
            this.snackBar.open('Anmeldung erfolgreich', '❌', {
              duration: 3 * 1000,
            });
            this.router.navigate(['/welcome']);
          } else {
            this.error = 'Anmeldung fehlgeschlagen';
          }
        });
    }
  }
}
