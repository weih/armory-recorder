class History < ActiveRecord::Base
  belongs_to :character, :counter_cache => true
end
