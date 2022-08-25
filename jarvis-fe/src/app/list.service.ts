import { Injectable } from '@angular/core';
import { List } from './models/list';
import { Observable, of } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class ListService {
  private lists: List[] = [
    { no: 5, owner: 'Alice', occursAt: new Date(), open: true },
    { no: 7, owner: 'Bob', occursAt: new Date(), open: false },
  ];

  constructor() {}

  getLists(showClosed = false): Observable<List[]> {
    const filtered = this.lists.filter((it) => it.open || showClosed);

    return of(filtered);
  }
}
