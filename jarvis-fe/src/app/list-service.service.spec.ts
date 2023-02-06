import { HttpClient } from '@angular/common/http';
import { TestBed } from '@angular/core/testing';
import { MatSnackBar } from '@angular/material/snack-bar';

import { ListService } from './list.service';

const matSnackBar = jasmine.createSpyObj('MatSnackBar', ['open']);

describe('ListService', () => {
  let service: ListService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        {
          provide: HttpClient,
          useValue: {},
        },
        { provide: MatSnackBar, useValue: matSnackBar },
      ],
    });
    service = TestBed.inject(ListService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
