class Upload < ActiveRecord::Base


#  after_save :log_saved
  attr_accessor :formular, :ort, :gott, :wort, :email


  private


#  def log_saved
#    logger.info "[INFO]  after save: #{id}"
#  end


end
