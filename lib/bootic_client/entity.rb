module BooticClient
  class Entity

    def initialize(attrs, client)
      @attrs, @client = attrs, client
      build!
    end

    def [](key)
      attrs[key.to_sym]
    end

    def method_missing(name, *args, &block)
      if !block_given?
        name = name.to_sym
        if has_property?(name)
          self[name]
        elsif has_entity?(name)
          entities[name]
        else
          super
        end
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name = method_name.dup.to_sym
      has_property?(method_name) || has_entity?(method_name)
    end

    protected

    attr_reader :attrs, :client, :entities

    def has_property?(prop_name)
      attrs.has_key?(prop_name.to_sym)
    end

    def has_entity?(prop_name)
      entities.has_key? prop_name.to_sym
    end

    def build!
      @entities = attrs.fetch(:_embedded, {}).each_with_object({}) do |(k,v),memo|
        memo[k] = if v.kind_of?(Array)
          v.map{|ent_attrs| Entity.new(ent_attrs, client)}
        else
          Entity.new(v, client)
        end
      end
    end
  end
end