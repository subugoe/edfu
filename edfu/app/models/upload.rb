class Upload < ActiveRecord::Base


  after_save :log_saved


  private


  def log_saved
    logger.info "[INFO]  after save: #{id}"
  end


end
