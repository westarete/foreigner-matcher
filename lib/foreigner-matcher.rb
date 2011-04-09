module ForeignerMatcher

  class HaveForeignKeyFor
    def initialize(parent, options={})
      @parent  = parent.to_s
      @options = options
    end

    def matches?(child)
      @child = child
      child_foreign_keys.include? foreign_key_definition
    end

    def description
      desc  = "have a foreign key for #{@parent}"
      desc += " with #{@options.inspect}" unless @options.empty?
      desc
    end

    def failure_message_for_should
      "expected #{child_foreign_keys} to include #{foreign_key_definition}"
    end

    def failure_message_for_should_not
      "expected #{child_foreign_keys} to exclude #{foreign_key_definition}"
    end

    private

    def foreign_key_definition
      defaults        = { :primary_key => "id", :column => "#{@parent.singularize}_id" }
      defaults[:name] = "#{@child.class.table_name}_#{defaults[:column]}_fk"
      full_options    = defaults.merge(@options)
      Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(@child.class.table_name, @parent.pluralize, full_options)
    end

    def child_foreign_keys
      @child.connection.foreign_keys(@child.class.table_name)
    end
  end

end

def have_foreign_key_for(parent, options={})
  ForeignerMatcher::HaveForeignKeyFor.new(parent, options)
end