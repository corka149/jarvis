import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { ListDetailsComponent } from '../list-details/list-details.component';


type MaybeString = string | null;

@Component({
    selector: 'app-edit-list',
    templateUrl: './edit-list.component.html',
    styleUrls: ['./edit-list.component.css'],
    standalone: true,
    imports: [ListDetailsComponent],
})
export class EditListComponent implements OnInit {
  listId?: MaybeString;

  constructor(private route: ActivatedRoute) {}

  ngOnInit(): void {
    this.listId = this.route.snapshot.paramMap.get('id');
  }
}
