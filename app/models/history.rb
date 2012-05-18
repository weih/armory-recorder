class History < ActiveRecord::Base
  belongs_to :character, :counter_cache => true

  validates :target_page, :presence => true
  validates :record_at, :presence => true
end
