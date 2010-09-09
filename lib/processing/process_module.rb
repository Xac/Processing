module Processing
  class ProcessModule
    class NamespaceNotFound < StandardError; end
    class ProcessNotFound < StandardError; end
    
    include Helpers
        
    def initialize(options={})
      @template_ref      = options[:template]
      @current_namespace = namespaces
    end
    
    def namespace(name)
      add_namespace name
      yield
      revert_namespace
    end
    
    def code(val=nil)
      @code ||= val
    end
        
    def description(val=nil)
      @description ||= val
    end
    
    def process(namespace_chain, process_name, data)
      namespace   = get_namespace(namespace_chain)
      namespace ||= template.get_namespace(namespace_chain) if template
      raise NamespaceNotFound, "Invalid namespace #{namespace_chain}" unless namespace
      
      process = namespace[process_name]
      if !process && template
        namespace = template.get_namespace(namespace_chain)
        process   = namespace[process_name] if namespace
      end
      raise ProcessNotFound, "There is no process '#{process_name}' defined for namespace #{namespace}" unless process
      process.call(data)
    end
            
    def define_process(name)
      @current_namespace[name] = Proc.new do |data|
        yield data
      end
    end
    
    def template
      @template_module ||= Processing.find_module(@template_ref)
    end
    
    def namespaces
      @namespaces ||= Namespace.new(:name => 'base')
    end
    
    def get_namespace(namespace_chain)
      namespace_by_string(namespace_chain)
    end
        
    private
        
    def namespace_by_string(namespace_chain)
      result = namespace_chain.split('.').inject do |current_ns, next_ns|
        cur = namespaces[current_ns.to_sym] unless current_ns.is_a? Namespace
        this_ns = cur[next_ns.to_sym]
        break unless this_ns
        this_ns
      end
      result.is_a?(String) ? namespaces[namespace_chain.to_sym] : result
    end
            
    def add_namespace(name)
      @current_namespace = @current_namespace.namespace(name)
    end
    
    def revert_namespace
      @current_namespace = @current_namespace.parent
    end
    
    def method_missing(method, *args)
      if namespaces[method]
        namespaces[method]
      elsif template && template.namespaces[method]
        template.namespaces[method]
      else
        super(method, *args)
      end
    end
  end
end
