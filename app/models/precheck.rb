class Precheck < ApplicationRecord
  belongs_to :project
  
  enum :status, {
    loading: 0,
    failed: 1,
    passed: 2
  }
  
  def run_check!
    update!(status: :loading, message: "Running precheck...")
    PrecheckProjectJob.perform_later(self)
  end
end
