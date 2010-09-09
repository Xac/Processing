module Processing  
  class ModuleNotFound < StandardError; end
  
  class << self
    attr_accessor :modules
  end
  @modules = {}
    
  def self.load
    load_required_files
    load_modules
  end
  
  def self.load_required_files
    ['helpers','namespace','process_module'].each do |file|
      require_lib_file file
    end
  end
  
  def self.require_lib_file(file)
    require File.join(File.dirname(__FILE__),'..','lib', 'processing', "#{file}.rb")
  end
  
  def self.load_module(name)
    require File.join('lib', 'processing', 'modules', "#{name}.rb")
  rescue MissingSourceFile
    raise ModuleNotFound, "Could not find the module '#{ref}' to extend."
  end
  
  def self.load_modules    
    Dir[File.join('lib', 'processing', 'modules', '**', '*.rb')].each do |file|
      require file
    end
  end
  
  def self.find_module_by_code(code)
    m = modules.detect{|k,v| v.code == code }
    m[1] if m
  end
  
  def self.find_module(ref)
    modules[ref]
  end
  
  def self.define_module(ref, options={}, &block)
    modules[ref] = Processing::ProcessModule.new(options)
    modules[ref].instance_eval(&block)
  end
  
  def self.extend_module(ref, options={}, &block)
    load_module(ref) unless modules[ref]
    modules[ref].instance_eval(&block)
  end
end

Processing.load