class StellenSzenen < ActiveRecord::Base
  belongs_to :stelle
  belongs_to :szene


  @@stellenszenen = Hash.new

  def self.fetch(
      stelle,
          szene
  )


    # todo: remove this
    #puts "stellenszenen.size: #{@@stellenszenen.size}"

    #Rails.cache.fetch("stelle-szene_#{stelle.id}_#{szene.id}") {

    stelleszene = @@stellenszenen["stelle-szene_#{stelle.id}_#{szene.id}"]

    if stelleszene != nil
      return stelleszene
    else

      sz                                                       = StellenSzenen.new(
          stelle: stelle,
          szene:  szene
      )

      #Rails.cache.write("stelle-szene_#{stelle.id}_#{szene.id}", sz)

      @@stellenszenen["stelle-szene_#{stelle.id}_#{szene.id}"] = sz

      return [sz]

      # }
    end

  end


  # def to_s
  #   return "Stelle_Id: #{stelle.id}, Szene_Id: #{szene.id}"
  # end

end
