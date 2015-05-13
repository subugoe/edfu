class StellenSzenen < ActiveRecord::Base

  belongs_to :stelle
  belongs_to :szene

  @@stellenszenen = Hash.new


  def self.stellenszenen
    return @@stellenszenen
  end


  def self.fetch(stelle, szene)

    stelleszene = @@stellenszenen["stelle-szene_#{stelle.id}_#{szene.id}"]

    if stelleszene != nil
      return stelleszene
    else

      sz = StellenSzenen.new(stelle: stelle, szene: szene)

      @@stellenszenen["stelle-szene_#{stelle.id}_#{szene.id}"] = sz

      return [sz]

    end

  end


end
