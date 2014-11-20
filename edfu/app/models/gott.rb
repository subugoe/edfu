class Gott < ActiveRecord::Base
  has_many :stellen, as: :zugehoerigZu
end
