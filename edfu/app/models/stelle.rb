class Stelle < ActiveRecord::Base
  belongs_to :zugehoerigZu, polymorphic: true
end
