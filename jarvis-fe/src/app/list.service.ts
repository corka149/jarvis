import { Injectable } from '@angular/core';
import { List } from './models/list';
import { map, Observable, of } from 'rxjs';
import { v4 as uuidv4 } from 'uuid';
import { HttpClient } from '@angular/common/http';

type MaybeList = List | undefined;

const LIST_API = 'v1/lists';

@Injectable({
  providedIn: 'root',
})
export class ListService {
  private lists: List[] = [
    {
      id: '0066263e-49b2-4f5b-88b1-f5167b01a098',
      no: 5,
      reason: 'Birthday',
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
      reason: 'Family',
      occursAt: new Date(),
      done: true,
      products: [
        { name: 'Bread', amount: 1337 },
        { name: 'Bread', amount: 42 },
      ],
    },
  ];

  constructor(private httpClient: HttpClient) {}

  getLists(showClosed = false): Observable<List[]> {
    return this.httpClient.get<List[]>(LIST_API).pipe(map(this.mapFromDtos()));
  }

  getList(id: string): Observable<List> {
    return this.httpClient
      .get<List>(`${LIST_API}/${id}`)
      .pipe(map(this.mapFromDto));
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

  private mapFromDtos() {
    const self = this;

    return function (lists: List[]): List[] {
      return lists.map(self.mapFromDto);
    };
  }

  private mapFromDto(list: any) {
    if (
      list &&
      list['occurs_at'] &&
      list['occurs_at']['$date'] &&
      list['occurs_at']['$date']['$numberLong']
    ) {
      list['occursAt'] = new Date(+list['occurs_at']['$date']['$numberLong']);
    }

    if (list && list['_id'] && list['_id']['$oid']) {
      list.id = list['_id']['$oid'];
    }

    return list;
  }
}
