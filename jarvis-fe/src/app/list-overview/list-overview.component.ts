import { Component, OnInit } from '@angular/core';
import { ListService } from '../list.service';
import { List } from '../models/list';
import { Router, ActivatedRoute } from '@angular/router';
import { DatePipe } from '@angular/common';
import {
  MatTable,
  MatColumnDef,
  MatHeaderCellDef,
  MatHeaderCell,
  MatCellDef,
  MatCell,
  MatHeaderRowDef,
  MatHeaderRow,
  MatRowDef,
  MatRow,
} from '@angular/material/table';

@Component({
  selector: 'app-list-overview',
  templateUrl: './list-overview.component.html',
  styleUrls: ['./list-overview.component.css'],
  standalone: true,
  imports: [
    MatTable,
    MatColumnDef,
    MatHeaderCellDef,
    MatHeaderCell,
    MatCellDef,
    MatCell,
    MatHeaderRowDef,
    MatHeaderRow,
    MatRowDef,
    MatRow,
    DatePipe,
  ],
})
export class ListOverviewComponent implements OnInit {
  displayedColumns: string[] = ['no', 'reason', 'occursAt'];
  lists: List[] = [];
  showClosed: boolean = false;

  constructor(
    private listService: ListService,
    private route: ActivatedRoute,
    private router: Router,
  ) {}

  ngOnInit(): void {
    this.route.queryParams.subscribe((params) => {
      this.showClosed = params['showClosed'] === 'true';

      this.listService
        .getLists(this.showClosed)
        .subscribe((lists) => (this.lists = lists));
    });
  }

  openDetails(list: List) {
    this.router.navigate(['lists', 'details', list.id]);
  }
}
