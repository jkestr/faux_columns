class Hash
  def map_values(&block)
    Hash[*self.map{ |i| i[1] = yield(i[1]); i }.flatten]
  end
end



module FauxColumns

  def self.included(receiver)    
    receiver.extend(ClassMethods)
  end
  
  module ClassMethods
    
    def faux_columns_in(real_column, faux_columns)
      write_inheritable_attribute :faux_column_container, real_column
      write_inheritable_attribute :faux_columns, faux_columns.map_values{ |i| FauxColumns::Imitator.new(i) }
      class_inheritable_reader :faux_column_container, :faux_columns
      
      faux_columns.each_pair do |faux_column, faux_type|
        
        define_method(faux_column) do
          val = self[self.faux_column_container][faux_column]
          if    faux_type == Integer; val.to_i
          elsif faux_type == Float;   val.to_f
          else  val
          end
        end
        
        define_method("#{faux_column}=") do |value|
          self[self.faux_column_container] ||= {}
          # When just setting keys within #data hash and not reseting 
          # the whole thing, ActiveRecord wasn't seeing that the 
          # attribute had changed, and therefore wasn't saving it.
          # We get around that by merging it instead.
          self[self.faux_column_container] = self[self.faux_column_container].merge({ faux_column => value })
        end
      end
      
      serialize self.faux_column_container, Hash      
      include FauxColumns::InstanceMethods
    end

  end
  
  module InstanceMethods

    def after_initialize
      self[self.faux_column_container] ||= {}
    end
    
    # Overriding this to grab the faux-column type if 
    # the attribute in question is one of our data fields.
    def column_for_attribute(name)
      name = name.to_sym
      return self.faux_columns[name] if self.faux_columns.has_key?(name)
      super
    end

  end
  
  class Imitator
    attr_reader :klass
    def initialize(klass)
      @klass = klass
    end
  end

end

ActiveRecord::Base.send(:include, FauxColumns)