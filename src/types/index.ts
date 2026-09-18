export interface Profile {
  id: string;
  role: string;
  status: string;
  full_name: string;
  email?: string;
}

export interface Position {
  id: string;
  name: string;
}

export interface EmployeeAssignment {
  id: string;
  employee_id: string;
  position_id: string;
  status: string;
  effective_from: string;
  effective_to?: string;
  positions?: Position;
  position?: Position;
}

export interface Employee {
  id: string;
  profile_id: string;
  profiles?: Profile;
  employee_position_assignments?: EmployeeAssignment[];
}

export interface Journal {
  id: string;
  employee_id: string;
  target_id: string;
  activity_date: string;
  description: string;
  realization_quantity: number;
  realization: number;
  status: string;
  created_at: string;
  target_snapshot?: number;
  unit_snapshot?: string;
  item_name_snapshot?: string;
  group_name_snapshot?: string;
  note?: string;
  return_reason?: string;
  start_time?: string;
  end_time?: string;
  location?: string;
  group_name?: string;
  name?: string;
  target?: number;
  unit?: string;
  journal_evidence?: unknown[];
  employees?: { profiles?: Profile };
  performance_targets?: {
    item_id: string;
    target_quantity: number;
    performance_items?: {
      name: string;
      performance_groups?: {
        name: string;
      }
    }
  };
}

export interface JournalEvidence {
  id: string;
  journal_id: string;
  file_path: string;
  file_name: string;
  content_type: string;
}

export interface PerformanceItem {
  id: string;
  group_id: string;
  name: string;
}

export interface PerformanceGroup {
  id: string;
  matrix_version_id: string;
  name: string;
  count?: number;
}

export interface MatrixVersion {
  id: string;
  position_id: string;
  version_number: number;
  status: string;
  effective_from: string;
  effective_to?: string;
  positions?: Position;
  performance_groups?: PerformanceGroup[];
}

export interface TukinPeriod {
  id: string;
  period_month: string;
  status: string;
}

export interface TukinCalculation {
  id: string;
  period_id: string;
  employee_id: string;
  tukin_formula_role: string;
  pagu_snapshot: number;
  formula_version: string;
  hk: number;
  mk: number;
  pb: number;
  tkb: number;
  ckb: number;
  actual_kb: number;
  kb_used_for_npk: number;
  npk: number;
  tukin_percentage: number;
  gross_tukin: number;
  adjustment_amount: number;
  final_tukin: number;
  tukin_periods?: TukinPeriod;
  tukin_calculation_components?: unknown[];
  count?: number;
}

export interface AuditLog {
  id: string;
  actor_type: string;
  action: string;
  entity_type: string;
  entity_id: string;
  created_at: string;
  profiles?: Profile;
}
