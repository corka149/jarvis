import { Injectable } from '@angular/core';
import { List } from './models/list';
import { Observable, of } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class ListServiceService {
  private lists: List[] = [{ id: 5, owner: 'Alice', occursAt: new Date() }];

  constructor() {}

  getAllLists(): Observable<List[]> {
    return of(this.lists);
  }
}
