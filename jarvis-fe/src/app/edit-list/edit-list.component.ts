import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';

type MaybeString = string | null;

@Component({
  selector: 'app-edit-list',
  templateUrl: './edit-list.component.html',
  styleUrls: ['./edit-list.component.css'],
})
export class EditListComponent implements OnInit {
  listId?: MaybeString;

  constructor(private route: ActivatedRoute) {}

  ngOnInit(): void {
    this.listId = this.route.snapshot.paramMap.get('id');
  }
}
