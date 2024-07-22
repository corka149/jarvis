import { Component, Input, OnInit } from '@angular/core';
import { ListService } from '../list.service';
import { List } from '../models/list';
import { FormArray, FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { DateAdapter } from '@angular/material/core';
import { Product } from '../models/product';
import { Location } from '@angular/common';
import { Router } from '@angular/router';
import moment from 'moment';
import { debounceTime } from 'rxjs/operators';
import { MatSnackBar } from '@angular/material/snack-bar';
import { MatCheckbox } from '@angular/material/checkbox';
import { MatIcon } from '@angular/material/icon';
import { MatMiniFabButton, MatIconButton } from '@angular/material/button';
import { MatDivider } from '@angular/material/divider';
import { MatDatepickerInput, MatDatepickerToggle, MatDatepicker } from '@angular/material/datepicker';
import { MatSlideToggle } from '@angular/material/slide-toggle';
import { MatInput } from '@angular/material/input';
import { MatFormField, MatLabel, MatHint, MatSuffix } from '@angular/material/form-field';
import Swal from "sweetalert2";

@Component({
    selector: 'app-list-details',
    templateUrl: './list-details.component.html',
    styleUrls: ['./list-details.component.css'],
    standalone: true,
    imports: [
    ReactiveFormsModule,
    MatFormField,
    MatLabel,
    MatInput,
    MatSlideToggle,
    MatDatepickerInput,
    MatHint,
    MatDatepickerToggle,
    MatSuffix,
    MatDatepicker,
    MatDivider,
    MatMiniFabButton,
    MatIcon,
    MatIconButton,
    MatCheckbox
],
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
    private router: Router,
    private matSnackBar: MatSnackBar,
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

    this.setupAutosave();
  }

  setupAutosave() {
    if (this.listForm) {
      this.listForm.valueChanges.pipe(debounceTime(400)).subscribe((list) => {
        if (this.listForm?.valid) {
          list.id = this.selectList?.id;
          list.no = this.selectList?.no;

          this.listService.saveList(list).subscribe((savedList) => {
            if (savedList) {
              this.selectList = savedList;
              this.listId = savedList.id;
              this.readonly = false;
            }
          });
        }
      });
    }
  }

  deleteList() {
    if (this.listId) {
      const listId = this.listId;

      Swal.fire({
        title: 'Soll die Liste entgültig gelöscht werden?',
        showDenyButton: true,
        confirmButtonText: `Ja`,
        denyButtonText: `Nein`,
      }).then((result) => {
        if (result.isConfirmed) {
          this.listService
            .deleteList(listId)
            .subscribe((_success) => this.location.back());
        }
      });
    }
  }

  addProduct() {
    if (!!this.listForm) {
      const products = this.listForm.get('products') as FormArray;

      products.push(
        this.fb.group({
          name: ['', Validators.required],
          amount: [undefined, Validators.required],
        }),
      );
    }
  }

  removeProduct(i: number) {
    if (
      !!this.listForm &&
      confirm('Soll der Gegenstand von der Liste entfernt werden?')
    ) {
      const products = this.listForm.get('products') as FormArray;
      products.removeAt(i);
    }
  }

  onSubmit() {
    if (this.listForm?.valid) {
      const list: List = this.listForm.value;

      list.id = this.selectList?.id;
      list.no = this.selectList?.no;

      this.listService.saveList(list).subscribe((_list) => {
        this.matSnackBar.open('Erfolgreich gespeichert', '❌', {
          duration: 3 * 1000,
        });

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
      this.fb.group(product, {}),
    );

    this.listForm = this.fb.group({
      reason: [formData.reason, Validators.required],
      occursAt: [formData.occursAt, Validators.required],
      done: formData.done,
      products: this.fb.array(productsForm),
      deleted: formData.deleted || false,
    });

    if (this.isReadonly) {
      this.listForm.disable();
    }
  }
}
