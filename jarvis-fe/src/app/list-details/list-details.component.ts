import { Component, Input, OnInit } from '@angular/core';
import { ListService } from '../list.service';
import { List } from '../models/list';
import { ActivatedRoute } from '@angular/router';
import { FormBuilder, FormGroup } from '@angular/forms';
import { DateAdapter } from '@angular/material/core';

@Component({
  selector: 'app-list-details',
  templateUrl: './list-details.component.html',
  styleUrls: ['./list-details.component.css'],
})
export class ListDetailsComponent implements OnInit {
  listForm?: FormGroup;

  selectList?: List;

  @Input('list-id') listId?: string;

  constructor(
    private listService: ListService,
    private route: ActivatedRoute,
    private fb: FormBuilder,
    private _adapter: DateAdapter<any>
  ) {}

  ngOnInit(): void {
    this._adapter.setLocale('de');
    console.log(this.listId);

    if (!!this.listId && this.listId !== 'new') {
      this.listService.getList(this.listId).subscribe((list) => {
        if (!!list) {
          this.selectList = list;
        }

        this.setupForm(this.selectList);
      });
    } else {
      this.setupForm(this.selectList);
    }
  }

  private setupForm(list?: List): void {
    let formData: List = list ?? {
      owner: '',
      occursAt: new Date(),
      open: true,
      products: [],
    };

    this.listForm = this.fb.group({
      owner: formData.owner,
      occursAt: formData.occursAt,
      open: formData.open,
    });
  }
}
