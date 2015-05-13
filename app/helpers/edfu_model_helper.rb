module EdfuModelHelper

    def assign_or_new(attributes)
      obj = first || new
      obj.assign_attributes(attributes)
      obj
    end

    def update_or_create(attributes)
      assign_or_new(attributes).save
    end

    def update_or_create!(attributes)
      assign_or_new(attributes).save!
    end

end



