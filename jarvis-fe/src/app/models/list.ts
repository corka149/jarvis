import { Product } from './product';

export interface List {
  id?: string;
  no?: number;
  reason: string;
  occursAt: Date;
  done: boolean;
  products?: Product[];
}
