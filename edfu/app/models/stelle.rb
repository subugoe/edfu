class Stelle < ActiveRecord::Base
  belongs_to :zugehoerigZu, polymorphic: true


  after_update :log_updated
  after_create :log_created

  searchable do

    integer :uid, stored: true
    text :tempel, stored: true
    integer :band, stored: true
    integer :seite_start, stored: true
    integer :seite_stop, stored: true
    integer :zeile_start, stored: true
    integer :zeile_stop, stored: true
    text :stelle_anmerkung, stored: true
    boolean :stelle_unsicher, stored: true
    integer :start, stored: true
    integer :stop, stored: true
    boolean :zerstoerung, stored: true
    boolean :freigegeben, stored: true
    # t.references :zugehoerigZu, polymorphic: true
    # todo besitzer hinzufügen, id hinzufügen, typ hinzufügen


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
    logger.info "[---] after update: #{id}"
  end


  # todo add doc to solr
  # todo log created
  def log_created

    logger.info "[---] before save: #{id}"

  end



end

