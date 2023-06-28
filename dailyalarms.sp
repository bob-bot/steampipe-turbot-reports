dashboard "turbot_recent_alarms_report" {
  title = "Turbot Recent Alarms Report"
  
  tags = {
    service = "Turbot Recent Alarms Report"
  }

  text {
    value = "Recent Turbot Controls that are in an Alarm State"
  }

  container {

    card {
      sql   = query.turbot_alarms_24_hours_count.sql
      width = 2
    }

    card {
      sql   = query.turbot_alarms_48_hours_count.sql
      width = 2
    }

    card {
      sql   = query.turbot_alarms_1_week_count.sql
      width = 2
    }

    card {
      sql   = query.turbot_alarms_total_count.sql
      width = 2
    }

  }

  text {
    value = "List of Alarms in the last 24 hours"
  }

table {
    sql = query.turbot_alarms_24_hours.sql
  }
  

}

query "turbot_alarms_24_hours_count" {
  sql = <<-EOQ
    select
      count(*) as "value",
      'Alarms within 24 hours' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
        turbot_control
    where
        filter = 'state:alarm stateChangeTimestamp:>=T-1d';
  EOQ
}

query "turbot_alarms_48_hours_count" {
  sql = <<-EOQ
    select
      count(*) as "value",
      'Alarms within 48 hours' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
        turbot_control
    where
        filter = 'state:alarm stateChangeTimestamp:>=T-2d';
  EOQ
}


query "turbot_alarms_1_week_count" {
  sql = <<-EOQ
    select
      count(*) as "value",
      'Alarms within 1 week' as label,
      case count(*) when 0 then 'ok' else 'alert' end as "type"
    from
        turbot_control
    where
        filter = 'state:alarm stateChangeTimestamp:>=T-1w';
  EOQ
}


query "turbot_alarms_total_count" {
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


query "turbot_alarms_24_hours" {
  sql = <<-EOQ
    select
      control_type_trunk_title as "control_name",
      TO_CHAR(DATE_TRUNC('minute', timestamp), 'YYYY-MM-DD HH24:MI') as "last_updated", 
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
      filter = 'state:alarm stateChangeTimestamp:>=T-1d'
    order by
      "control_name" asc;
  EOQ
}

