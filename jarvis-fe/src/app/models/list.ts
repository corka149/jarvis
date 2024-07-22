import { Product } from './product';
import moment from 'moment';

export interface List {
  id?: string;
  no?: number;
  reason: string;
  occursAt: moment.Moment;
  done: boolean;
  products?: Product[];
  deleted?: boolean;
}
