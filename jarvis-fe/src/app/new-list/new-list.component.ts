import { Component, OnInit } from '@angular/core';
import { ListDetailsComponent } from '../list-details/list-details.component';

@Component({
    selector: 'app-new-list',
    templateUrl: './new-list.component.html',
    styleUrls: ['./new-list.component.css'],
    standalone: true,
    imports: [ListDetailsComponent],
})
export class NewListComponent implements OnInit {
  constructor() {}

  ngOnInit(): void {}
}
