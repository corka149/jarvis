import { Product } from './product';

export interface List {
  id?: string;
  no?: number;
  owner: string;
  occursAt: Date;
  open: boolean;
  products?: Product[];
}
