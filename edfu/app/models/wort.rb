class Wort < ActiveRecord::Base
  has_one :wb_berlin
  has_many :stellen, as: :zugehoerigZu

  after_update :log_updated
  after_create :log_created

  searchable do

    integer :uid, stored: true
    text :transliteration, stored: true # todo transliteration_highlight hinzufügen
    text :transliteration_nosuffix, stored: true
    text :uebersetzung, stored: true
    text :hieroglyph, stored: true
    text :weiteres, stored: true
    text :belegstellenEdfu, stored: true # todo in was indexiert? stelle_id?
    text :belegstellenWb, stored: true   # todo in was indexiert? stelle_berlin_id?
    text :anmerkung, stored: true
    # todo stelle_id und attr. aus Stelle hinzufügen, und bandseitezeile_highlight hinzufügen
    # todo id hinzufügen, typ hinzufügen,
    # todo attr. aus Szene hinzufügen
    # todo felder prüfen

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
