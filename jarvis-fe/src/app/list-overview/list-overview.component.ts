import { Component, OnInit } from '@angular/core';
import { ListService } from '../list.service';
import { List } from '../models/list';
import { Router, ActivatedRoute, ParamMap } from '@angular/router';

@Component({
  selector: 'app-list-overview',
  templateUrl: './list-overview.component.html',
  styleUrls: ['./list-overview.component.css'],
})
export class ListOverviewComponent implements OnInit {
  displayedColumns: string[] = ['no', 'owner', 'occursAt'];
  lists: List[] = [];
  showClosed: boolean = false;

  constructor(
    private listService: ListService,
    private route: ActivatedRoute
  ) {}

  ngOnInit(): void {
    this.route.queryParams.subscribe((params) => {
      this.showClosed = params['showClosed'] === 'true';

      this.listService
        .getLists(this.showClosed)
        .subscribe((lists) => (this.lists = lists));
    });
  }
}
