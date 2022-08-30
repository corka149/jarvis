import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { EditListComponent } from './edit-list/edit-list.component';
import { ListOverviewComponent } from './list-overview/list-overview.component';
import { LogInComponent } from './log-in/log-in.component';
import { NewListComponent } from './new-list/new-list.component';
import { WelcomeComponent } from './welcome/welcome.component';

const routes: Routes = [
  { path: '', redirectTo: '/welcome', pathMatch: 'full' },
  { path: 'welcome', component: WelcomeComponent },
  { path: 'lists', component: ListOverviewComponent },
  { path: 'lists/details/new', component: NewListComponent },
  { path: 'lists/details/:id', component: EditListComponent },
  { path: 'login', component: LogInComponent },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule],
})
export class AppRoutingModule {}
