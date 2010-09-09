require File.dirname(__FILE__) + '/test_helper'

Processing.define_module :sample do
  code        "SP"
  description "Sample"
  
  namespace :friendly do
    namespace :verbal do
      define_process :say_hola do |name|
        "Hola, #{name}!"
      end
      define_process :say_hi do |name|
        "Hello #{name}!"
      end
    end
  end
end

Processing.define_module :guy, :template => :sample do
  code        "GY"
  description "Some guy"
  
  namespace :friendly do
    namespace :verbal do
      define_process :say_hi do |name|
        "Hi there, #{name}!"
      end
    end
  end
end

Processing.define_module :multiple_namespaces do
  code        "MN"
  description "Multiple Namespaces"
  
  namespace :one do
    define_process :test do
      "ONE"
    end
  end
  
  namespace :two do
    define_process :test do
      "TWO"
    end
  end
end

Processing.extend_module :guy do
  namespace :friendly do
    namespace :verbal do
      define_process :say_goodbye do |name|
        "Goodbye, #{name}!"
      end
    end
  end
end

class Processing::ProcessingTest < Test::Unit::TestCase
  context Processing do
    context "The MN Module" do
      setup do
        @mod = Processing.find_module_by_code("MN")
      end
      
      should "have 2 namespaces" do
        assert_nothing_raised do
          @mod.process('one', :test, nil)
          @mod.process('two', :test, nil)
        end
      end
      
      should "return ONE" do
        assert_equal "ONE", @mod.process('one', :test, nil)
      end
      
      should "return TWO" do
        assert_equal "TWO", @mod.process('two', :test, nil)
      end
    end
    
    context "The SP module" do
      setup do
        @mod = Processing.find_module_by_code("SP")
      end
      
      should "say hello" do
        assert_equal "Hello John!", @mod.process('friendly.verbal', :say_hi, "John")
      end
    end
    
    context "The GY module" do
      setup do
        @mod = Processing.find_module_by_code("GY")
      end
      
      should "be found by code" do
        assert @mod.is_a? Processing::ProcessModule
        assert @mod.code == "GY"
      end
    
      should "create methods on ProcessingModule for namespaces" do
        assert @mod.friendly.is_a? Processing::Namespace
      end      
      
      should "create methods on Namespace for namespace" do
        assert @mod.friendly.verbal.is_a? Processing::Namespace
      end
      
      should "raise NamespaceNotFound if process is called for an invalid namespace" do
        assert_raise Processing::ProcessModule::NamespaceNotFound do
          @mod.process('friendly.foo', :bar, "Baz")
        end
      end
      
      should "raise ProcessNotFound when a valid namespace is passed with an invalid process" do
        assert_raise Processing::ProcessModule::ProcessNotFound do
          @mod.process('friendly.verbal', :bar, "Baz")
        end
      end
      
      should "be successfully extended using extend_module" do
        assert_equal "Goodbye, Mike!", @mod.process('friendly.verbal', :say_goodbye, "Mike")
      end
            
      should "say hi" do
        assert_equal "Hi there, John!", @mod.process('friendly.verbal', :say_hi, "John")
      end
      
      should "inherit 'say hola' from sample module" do
        assert_equal "Hola, Pedro!", @mod.process('friendly.verbal', :say_hola, "Pedro")        
      end
    end
  end
end
