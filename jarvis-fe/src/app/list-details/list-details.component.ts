import { Component, Input, OnInit } from '@angular/core';
import { ListService } from '../list.service';
import { List } from '../models/list';
import { FormArray, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { DateAdapter } from '@angular/material/core';
import { Product } from '../models/product';
import { Location } from '@angular/common';
import { Router } from '@angular/router';
import * as moment from 'moment';

@Component({
  selector: 'app-list-details',
  templateUrl: './list-details.component.html',
  styleUrls: ['./list-details.component.css'],
})
export class ListDetailsComponent implements OnInit {
  listForm?: FormGroup;

  selectList?: List;

  readonly = true;

  @Input('list-id') listId?: string;

  constructor(
    private location: Location,
    private listService: ListService,
    private fb: FormBuilder,
    private _adapter: DateAdapter<any>,
    private router: Router
  ) {}

  ngOnInit(): void {
    this._adapter.setLocale('de');

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

  deleteList() {
    if (!!this.listId) {
      this.listService
        .deleteList(this.listId)
        .subscribe((_success) => this.location.back());
    }
  }

  addProduct() {
    if (!!this.listForm) {
      const products = this.listForm.get('products') as FormArray;

      products.push(
        this.fb.group({
          name: '',
          amount: 0,
        })
      );
    }
  }

  removeProduct(i: number) {
    if (!!this.listForm) {
      const products = this.listForm.get('products') as FormArray;
      products.removeAt(i);
    }
  }

  onSubmit() {
    if (!!this.listForm && this.listForm.valid) {
      const list: List = this.listForm.value;

      list.id = this.selectList?.id;
      list.no = this.selectList?.no;

      this.listService.saveList(list).subscribe((_list) => {
        if (!!this.listId) {
          this.location.back();
        } else {
          this.router.navigate(['lists']);
        }
      });
    }
  }

  toggleReadonly() {
    this.readonly = !this.readonly;

    if (this.readonly) {
      this.listForm?.disable();
    } else {
      this.listForm?.enable();
    }
  }

  get products(): FormArray {
    return this.listForm?.get('products') as FormArray;
  }

  get isReadonly(): boolean {
    return this.listId !== 'new' && this.readonly;
  }

  private setupForm(list?: List): void {
    const formData: List = list ?? {
      reason: '',
      occursAt: moment(),
      done: false,
      products: [],
    };

    const products = formData.products ?? [];

    const productsForm = products.map((product: Product) =>
      this.fb.group(product, {})
    );

    this.listForm = this.fb.group({
      reason: [formData.reason, Validators.required],
      occursAt: [formData.occursAt, Validators.required],
      done: formData.done,
      products: this.fb.array(productsForm),
    });

    this.listForm.disable();
  }
}
