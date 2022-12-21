import { Product } from './product';

export interface List {
  id?: string;
  no?: number;
  reason: string;
  occursAt: moment.Moment;
  done: boolean;
  products?: Product[];
}
