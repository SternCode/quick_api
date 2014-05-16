require 'active_support'

require 'quick_api/version'

module QuickApi

end

# include in AR
ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:include, QuickApi)
end
