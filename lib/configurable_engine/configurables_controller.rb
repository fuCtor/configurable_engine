module ConfigurableEngine
  module ConfigurablesController
    def show
      @groups = []
      @groups += Configurable.groups.map {|g| ConfigurableGroup.new(g) }
    end

    def update
      Configurable.values.each do |key|
        Configurable[key] = params[key]
      end
      
      Configurable.groups.each do |group|
        g = ConfigurableGroup.new(group)
        g.values.each do |key|
          g_key= g.form_key(key)
          puts g_key
          g[key] = params[g_key]
        end
      end
      
      redirect_to admin_configurable_path
    end
  end
end