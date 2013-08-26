class Configurable < ActiveRecord::Base
  
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

  def self.keys
    self.defaults.collect { |k,v| k.to_s }.sort
  end
  
  def self.groups
    @groups = self.defaults.select { |key, value| value['type'].to_s.downcase == 'group' } 
    #@groups.to_a.map {|key, value| ConfigurableGroup.new(key) }
    @groups.collect { |k,v| k.to_s }.sort
  end
  
  def self.values
    @values = self.defaults.select { |key, value| value['type'].to_s.downcase != 'group' } 
    @values.collect { |k,v| k.to_s }.sort
  end

  def self.[]=(key, value)
    exisiting = find_by_name(key)
    if exisiting
      exisiting.update_attribute(:value, value)
    else
      create(:name => key.to_s, :value => value)
    end
  end

  def self.[](key)
    return self.defaults[key][:default] unless table_exists?

    value = find_by_name(key).try(:value) || self.defaults[key][:default]
    case self.defaults[key][:type]
    when 'boolean'
      [true, 1, "1", "t", "true"].include?(value)
    when 'decimal'
      BigDecimal.new(value.to_s)
    when 'integer'
      value.to_i
    when 'list'
      return value if value.is_a?(Array)
      value.split("\n").collect{ |v| v.split(',') }
    else
      value
    end
  end

  def self.method_missing(name, *args)
    name_stripped = name.to_s.sub(/[\?=]$/, '')
    if self.values.include?(name_stripped)
      if name.to_s.end_with?('=')
        self[name_stripped] = args.first
      else
        self[name_stripped]
      end
    elsif self.groups.include?(name_stripped)
      ConfigurableGroup.new(name_stripped)
    else
      super
    end
  end
  
  def self.form_key(key)
    key
  end
end