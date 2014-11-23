class Formular < ActiveRecord::Base
  has_many :stellen, as: :zugehoerigZu

  after_update :log_updated
  after_create :log_created




  private


  def self.update_or_create(attributes)
    assign_or_new(attributes).save
  end

  def self.assign_or_new(attributes)
    obj = first || new
    obj.assign_attributes(attributes)
    obj
  end



  # todo update solr doc
  # todo log updated
  def log_updated
    logger.info "[---] after update: #{id}"
  end



  # todo add doc to solr
  # todo log created
  def log_created

    logger.info "[---] before save: #{id}"

  end





  # todo
  def create_photo_pfad(photo)

  end

  # todo
  def create_photo_commentar(photo)

  end

  # todo
  def push_to_solr

  end

end
