import { Injectable } from '@angular/core';
import { List } from './models/list';
import { Observable, of } from 'rxjs';
import { v4 as uuidv4 } from 'uuid';

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
      done: false,
      products: [
        { name: 'Bread', amount: 1337 },
        { name: 'Bread', amount: 42 },
      ],
    },
    {
      id: '5a76e0f3-9dfa-4acb-9b8f-29eeaca244d5',
      no: 7,
      owner: 'Bob',
      occursAt: new Date(),
      done: true,
      products: [
        { name: 'Bread', amount: 1337 },
        { name: 'Bread', amount: 42 },
      ],
    },
  ];

  constructor() {}

  getLists(showClosed = false): Observable<List[]> {
    const filtered = this.lists.filter((it) => it.done || showClosed);

    return of(filtered);
  }

  getList(id: string): Observable<MaybeList> {
    const list = this.lists.find((list) => list.id === id);
    return of(list);
  }

  saveList(list: List): Observable<MaybeList> {
    if (!!list.id) {
      this.lists = this.lists.map((l) => (l.id === list.id ? list : l));
    } else {
      list.id = uuidv4();
      this.lists.push(list);
    }

    return of(list);
  }

  deleteList(listId: string): Observable<boolean> {
    let deleted = false;
    const newLists = new Array<List>();

    for (const list of this.lists) {
      if (list.id !== listId) {
        newLists.push(list);
      } else {
        deleted = true;
      }
    }

    this.lists = newLists;

    return of(deleted);
  }
}
