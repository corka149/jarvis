import { Component, Input, OnInit } from '@angular/core';
import { ListService } from '../list.service';
import { List } from '../models/list';
import { ActivatedRoute } from '@angular/router';
import { FormArray, FormBuilder, FormGroup } from '@angular/forms';
import { DateAdapter } from '@angular/material/core';
import { Product } from '../models/product';

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

  addProduct() {
    if (!!this.listForm) {
      const productDetails = this.listForm.get('productDetails') as FormArray;

      productDetails.push(
        this.fb.group({
          name: '',
          amount: 0,
        })
      );
    }
  }

  removeProduct(i: number) {
    if (!!this.listForm) {
      const productDetails = this.listForm.get('productDetails') as FormArray;
      productDetails.removeAt(i);
    }
  }

  get productDetails(): FormArray {
    return this.listForm?.get('productDetails') as FormArray;
  }

  private setupForm(list?: List): void {
    const formData: List = list ?? {
      owner: '',
      occursAt: new Date(),
      open: true,
      products: [],
    };

    const products = formData.products ?? [];

    const productDetails = products.map((product: Product) =>
      this.fb.group(product)
    );

    this.listForm = this.fb.group({
      owner: formData.owner,
      occursAt: formData.occursAt,
      open: formData.open,
      productDetails: this.fb.array(productDetails),
    });
  }
}
