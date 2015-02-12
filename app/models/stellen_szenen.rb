class StellenSzenen < ActiveRecord::Base
  belongs_to :stelle
  belongs_to :szene


  def self.fetch(
      stelle,
          szene
  )


    Rails.cache.fetch("stelle-szene_#{stelle.id}_#{szene.id}") {


      sz = StellenSzenen.new(
          stelle: stelle,
          szene:  szene
      )

      Rails.cache.write("stelle-szene_#{stelle.id}_#{szene.id}", sz)

      return [sz]
    }


  end


  def to_s
    return "Stelle_Id: #{stelle.id}, Szene_Id: #{szene.id}"
  end
end
