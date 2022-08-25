import { Injectable } from '@angular/core';
import { List } from './models/list';
import { Observable, of } from 'rxjs';

type MaybeList = List | undefined;

@Injectable({
  providedIn: 'root',
})
export class ListService {
  private lists: List[] = [
    {
      id: '0066263e-49b2-4f5b-88b1-f5167b01a098',
      no: 5,
      owner: 'Alice',
      occursAt: new Date(),
      open: true,
    },
    {
      id: '5a76e0f3-9dfa-4acb-9b8f-29eeaca244d5',
      no: 7,
      owner: 'Bob',
      occursAt: new Date(),
      open: false,
    },
  ];

  constructor() {}

  getLists(showClosed = false): Observable<List[]> {
    const filtered = this.lists.filter((it) => it.open || showClosed);

    return of(filtered);
  }

  getList(id: string): Observable<MaybeList> {
    const list = this.lists.find((list) => list.id === id);
    return of(list);
  }
}
