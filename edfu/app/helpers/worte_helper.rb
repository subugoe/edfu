module WorteHelper
  has_many :stellen, as: :zugehoerigZu
  has_one :wb_berlin
end
