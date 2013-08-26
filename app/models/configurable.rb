class Configurable < ActiveRecord::Base
  extend ConfigurableExt
  attr_protected :id
  validates_presence_of :name
  validates_uniqueness_of :name

  def self.defaults
    HashWithIndifferentAccess.new(
      YAML.load_file(
        Rails.root.join('config', 'configurable.yml')
      )
    )
  end

  
end