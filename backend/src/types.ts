export interface Referendum {
  id: number;
  title: string;
  description: string;
  start_at: string;
  end_at: string;
  status: string;
}

export interface Choice {
  id: number;
  referendum_id: number;
  label: string;
  sort_order: number;
}
