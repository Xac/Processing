module Processing
  class Namespace < Hash
    attr_reader :name
    attr_reader :parent
    
    def initialize(options)
      @name   = options[:name]
      @parent = options[:parent]
    end
    
    def namespace(name)
      self[name] ||= Namespace.new(:name => name, :parent => self)
    end
    
    def to_s
      "#{name}:Namespace"
    end
    
    def method_missing(method)
      if self[method]   
        self[method]
      else
        super(method)
      end
    end
  end
end
