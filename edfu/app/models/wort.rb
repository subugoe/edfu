class Wort < ActiveRecord::Base
  has_one :wb_berlin
  has_many :stellen, as: :zugehoerigZu
end
