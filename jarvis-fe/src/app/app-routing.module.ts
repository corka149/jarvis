import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { AuthGuard } from './auth.guard';
import { EditListComponent } from './edit-list/edit-list.component';
import { ListOverviewComponent } from './list-overview/list-overview.component';
import { LogInComponent } from './log-in/log-in.component';
import { NewListComponent } from './new-list/new-list.component';
import { WelcomeComponent } from './welcome/welcome.component';
import { MealOverviewComponent } from './meal-overview/meal-overview.component';
import { MealDetailsComponent } from './meal-details/meal-details.component';

const routes: Routes = [
  { path: '', redirectTo: '/welcome', pathMatch: 'full' },
  { path: 'welcome', component: WelcomeComponent },
  { path: 'lists', component: ListOverviewComponent, canActivate: [AuthGuard] },
  {
    path: 'lists/details/new',
    component: NewListComponent,
    canActivate: [AuthGuard],
  },
  {
    path: 'lists/details/:id',
    component: EditListComponent,
    canActivate: [AuthGuard],
  },
  {
    path: 'meals',
    component: MealOverviewComponent,
    canActivate: [AuthGuard],
  },
  {
    path: 'meals/:id',
    component: MealDetailsComponent,
    canActivate: [AuthGuard],
  },
  {
    path: 'meals/new',
    component: MealDetailsComponent,
    canActivate: [AuthGuard],
  },
  { path: 'login', component: LogInComponent },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule],
})
export class AppRoutingModule {}
