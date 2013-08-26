class ConfigurableGroup 
  include ConfigurableExt
  attr_accessor :group
  attr_reader :title
  
  def initialize(group, parent = Configurable)
    @parent = parent || Configurable
    @group = group
    @title = @parent.defaults[@group]['name']
  end
  
  def defaults
    d = @parent.defaults[@group]
    d.delete 'type'
    d.delete 'name'
    d
  end
  

end