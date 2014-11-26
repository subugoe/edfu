class Gott < ActiveRecord::Base
  has_many :stellen, as: :zugehoerigZu

  after_update :log_updated
  after_create :log_created

  searchable do

    integer :uid, stored: true
    text :transliteration, stored: true # todo transliteration_highlight hinzufügen
    text :transliteration_nosuffix, stored: true
    text :ort, stored: true
    text :eponym, stored: true
    text :beziehung, stored: true
    text :funktion, stored: true
    integer :band, stored: true
    text :seitezeile, stored: true  # todo wirklich in den index?
    text :anmerkung, stored: true
    # todo stelle_id und attr. aus Stelle hinzufügen, und bandseitezeile_highlight hinzufügen
    # todo id hinzufügen, typ hinzufügen,

  end


  private


  # todo in ein Modul packen und in Modell-Klassen wiederverwenden
  def self.update_or_create(attributes)
    assign_or_new(attributes).save
  end


  # todo in ein Modul packen und in Modell-Klassen wiederverwenden
  def self.assign_or_new(attributes)
    obj = first || new
    obj.assign_attributes(attributes)
    obj
  end


  # todo update solr doc
  # todo log updated
  def log_updated
    logger.info "[INFO]  after update: #{id}"
  end


  # todo add doc to solr
  # todo log created
  def log_created

    logger.info "[INFO]  before save: #{id}"

  end



end
