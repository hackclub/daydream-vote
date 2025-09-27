class SyncProjectsToAirtableJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting Airtable project sync job"
    
    # Get projects to sync in priority order:
    # 1. Submitted projects without airtable_record_id (never synced)
    # 2. Submitted projects with oldest last_synced_to_airtable_at (needs update)
    projects_to_sync = Project.where(aasm_state: 'submitted')
                             .order(
                               Arel.sql("CASE WHEN airtable_record_id IS NULL THEN 0 ELSE 1 END"),
                               :last_synced_to_airtable_at
                             )
                             .limit(10)

    if projects_to_sync.empty?
      Rails.logger.info "No projects to sync to Airtable"
      return
    end

    Rails.logger.info "Syncing #{projects_to_sync.count} projects to Airtable"
    
    # Sync projects to Airtable
    synced_records = AirtableService.sync_projects_batch(projects_to_sync)
    
    # Update local records with sync information
    synced_records.each_with_index do |airtable_record, index|
      next unless airtable_record && airtable_record["id"]
      
      project = projects_to_sync[index]
      next unless project
      
      project.update!(
        airtable_record_id: airtable_record["id"],
        last_synced_to_airtable_at: Time.current
      )
      
      Rails.logger.info "Updated project #{project.id} with Airtable record #{airtable_record['id']}"
    end
    
    Rails.logger.info "Completed Airtable project sync job"
  rescue => e
    Rails.logger.error "Airtable sync job failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end
end
