import { Injectable } from '@angular/core';
import { List } from './models/list';
import { catchError, map, Observable, of } from 'rxjs';
import { v4 as uuidv4 } from 'uuid';
import { HttpClient, HttpParams, HttpResponse } from '@angular/common/http';
import { ErrorHandlerService } from './error-handler.service';

type MaybeList = List | undefined;

const LIST_API = 'v1/lists';

@Injectable({
  providedIn: 'root',
})
export class ListService {
  constructor(
    private httpClient: HttpClient,
    private errorHandler: ErrorHandlerService
  ) {}

  getLists(showClosed = false): Observable<List[]> {
    const emptyList: List[] = [];

    const params = new HttpParams().set('show_closed', showClosed);

    return this.httpClient
      .get<List[]>(LIST_API, { params: params })
      .pipe(
        map(this.mapFromDtos()),
        catchError(this.errorHandler.handleError(emptyList))
      );
  }

  getList(id: string): Observable<MaybeList> {
    return this.httpClient
      .get<List>(`${LIST_API}/${id}`)
      .pipe(
        map(this.mapFromDto),
        catchError(this.errorHandler.handleError(undefined))
      );
  }

  saveList(list: List): Observable<MaybeList> {
    const dto = this.mapToDto(list);

    if (!list.id) {
      return this.httpClient
        .post<List>(`${LIST_API}`, dto)
        .pipe(
          map(this.mapFromDto),
          catchError(this.errorHandler.handleError(undefined))
        );
    } else {
      return this.httpClient
        .put<List>(`${LIST_API}/${list.id}`, dto)
        .pipe(
          map(this.mapFromDto),
          catchError(this.errorHandler.handleError(undefined))
        );
    }
  }

  deleteList(listId: string): Observable<boolean> {
    return this.httpClient
      .delete(`${LIST_API}/${listId}`, { observe: 'response' })
      .pipe(map((response: HttpResponse<Object>) => response.status === 200));
  }

  private mapFromDtos() {
    const self = this;

    return function (lists: List[]): List[] {
      return lists.map(self.mapFromDto);
    };
  }

  private mapFromDto(list: any) {
    if (list && list['occurs_at']) {
      list['occursAt'] = new Date(list['occurs_at'] * 1000);
    }

    return list;
  }

  private mapToDto(list: any) {
    let numberLong = list.occursAt.getTime
      ? list.occursAt.getTime()
      : +list.occursAt / 1000;

    list['occurs_at'] = Math.round(numberLong);

    return list;
  }
}
