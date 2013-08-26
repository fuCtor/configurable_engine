class ConfigurableGroup < ActiveResource::Base

  attr_accessor :group
  attr_reader :title
  
  validates_presence_of :group

  def initialize(group)
    @group = group
    @title = Configurable.defaults[@group]['name']
  end
  
  def defaults
    d = Configurable.defaults[@group]
    d.delete 'type'
    d.delete 'name'
    d
  end
  
  def keys
    self.defaults.collect { |k,v| k.to_s }.sort
  end
  
  def values
    @values = self.defaults.select { |key, value| value['type'].to_s.downcase != 'group' } 
    @values.collect { |k,v| k.to_s }.sort
  end

  def []=(key, value)
    key = value_key(key)
    exisiting = Configurable.find_by_name(key)
    if exisiting
      exisiting.update_attribute(:value, value)
    else
      Configurable.create(:name => key.to_s, :value => value)
    end
  end

  def [](key)
    return defaults[key][:default] unless Configurable.table_exists?
            
    value = Configurable.find_by_name(value_key(key)).try(:value) || defaults[key][:default]
    case defaults[key][:type]
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

  def method_missing(name, *args)
    name_stripped = name.to_s.sub(/[\?=]$/, '')    
    if keys.include?(name_stripped)
      if name.to_s.end_with?('=')
        self[name_stripped] = args.first
      else
        self[name_stripped]
      end
    else
      super
    end
  end
  
  def value_key(key)
    File.join(@group, key)
  end

  alias_method :form_key, :value_key
end