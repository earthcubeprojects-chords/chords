class Site < ApplicationRecord
  has_many :instruments, :dependent => :destroy
  belongs_to :site_type

  def self.initialize
  end

  def to_s
    name
  end

  def self.list_site_options
    Site.select("id, name").map {|site| [site.id, site.name] }
  end
end
