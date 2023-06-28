dashboard "turbot_oldest_alarms_report" {
  title = "Turbot Oldest Alarms Report"
  
  tags = {
    service = "Turbot Oldest Alarms Report"
  }

  text {
    value = "Oldest Turbot Controls that are in an Alarm State"
  }

  container {

    card {
      sql   = query.turbot_oldest_alarms_1_month_count.sql
      width = 2
    }

    card {
      sql   = query.turbot_oldest_alarms_3_month_count.sql
      width = 2
    }

    card {
      sql   = query.turbot_oldest_alarms_6_month_count.sql
      width = 2
    }
    
    card {
      sql   = query.turbot_oldest_alarms_12_month_count.sql
      width = 2
    }
    
    card {
      sql   = query.turbot_oldest_alarms_over_1_year_count.sql
      width = 2
    }

    card {
      sql   = query.turbot_oldest_alarms_total_count.sql
      width = 2
    }

  }

  text {
    value = "List of Oldest Alarms (limited to 50)"
  }

table {
    sql = query.turbot_oldest_alarms.sql
  }
  

}

query "turbot_oldest_alarms_1_month_count" {
  sql = <<-EOQ
    select
      count(*) as "value",
      'Alarms within 1 month old' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
        turbot_control
    where
        filter = 'state:alarm stateChangeTimestamp:>=T-30d';
  EOQ
}

query "turbot_oldest_alarms_3_month_count" {
  sql = <<-EOQ
    select
      count(*) as "value",
      'Alarms 1 to 3 months old' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
        turbot_control
    where
        filter = 'state:alarm stateChangeTimestamp:<=T-30d stateChangeTimestamp:>=T-90d';
  EOQ
}


query "turbot_oldest_alarms_6_month_count" {
  sql = <<-EOQ
    select
      count(*) as "value",
      'Alarms 3 to 6 months old' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
        turbot_control
    where
        filter = 'state:alarm stateChangeTimestamp:<=T-90d stateChangeTimestamp:>=T-180d';
  EOQ
}

query "turbot_oldest_alarms_12_month_count" {
  sql = <<-EOQ
    select
      count(*) as "value",
      'Alarms 6 to 12 months old' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
        turbot_control
    where
        filter = 'state:alarm stateChangeTimestamp:<=T-180d stateChangeTimestamp:>=T-365d';
  EOQ
}

query "turbot_oldest_alarms_over_1_year_count" {
  sql = <<-EOQ
    select
      count(*) as "value",
      'Alarms over 1 year old' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
        turbot_control
    where
        filter = 'state:alarm stateChangeTimestamp:<=T-365d';
  EOQ
}

query "turbot_oldest_alarms_total_count" {
  sql = <<-EOQ
    select
      count(*) as "value",
      'Total Alarms' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
        turbot_control
    where
        filter = 'state:alarm';
  EOQ
}


query "turbot_oldest_alarms" {
  sql = <<-EOQ
    select
      TO_CHAR(DATE_TRUNC('minute', timestamp), 'YYYY-MM-DD HH24:MI') as "last_updated", 
      control_type_trunk_title as "control_name",
      state,
      reason,
      resource_trunk_title as "resource_name",
      CASE
        WHEN control_type_uri LIKE 'tmod:@turbot/aws-%' THEN 'AWS'
        WHEN control_type_uri LIKE 'tmod:@turbot/azure-%' THEN 'Azure'
        WHEN control_type_uri LIKE 'tmod:@turbot/gcp-%' THEN 'GCP'
        ELSE 'Other'
    END as "cloud_provider"
    from
      turbot_control
    where
      filter = 'state:alarm'
    order by
      "last_updated" asc
    limit
      50;
  EOQ
}