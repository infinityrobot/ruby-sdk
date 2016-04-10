require_relative 'riq_obj'
using RIQExtensions

# RIQ module.
module RIQ
  # A List is an object that can be created & customized by a User to represent
  # Accounts (companies) or Contacts (people) in a process (sales pipeline).
  class List < RIQObject
    # Constants.
    INTEGER_REGEXP = /\A[-+]?\d+\z/

    # Can't create a list through API, so these don't need to write
    attr_reader :title
    attr_reader :type
    attr_reader :list_items
    alias name title

    # (see RIQObject#initialize)
    def initialize(id = nil)
      super
      @list_items = ListItemManager.new(@id)
    end

    # (see RIQObject#node)
    def node
      self.class.node(@id)
    end

    # (see RIQObject.node)
    def self.node(id = nil)
      "lists/#{id}"
    end

    # (see RIQObject#data)
    def data
      {
        id: @id,
        title: @title,
        type: @type,
        fields: @fields
      }
    end

    # Overwriting parent because lists can't be saved through the API
    def save
      raise NotImplementedError, "Lists can't be edited through the API"
    end

    # Returns the attributes of a provided field
    # @param lookup [Symbol, String or Integer] field name or ID
    # @return [Hash, nil] field attributes
    def field(lookup = nil)
      if !(lookup.to_s =~ INTEGER_REGEXP).nil?
        field_by_id(lookup)
      else
        field_by_name(lookup)
      end
    end

    # Returns the attributes of a field found by name
    # @param name [Symbol or String] field name
    # @return [Hash, nil] field attributes
    def field_by_name(name = nil)
      @fields.find { |h| h[:name].to_snym == name.to_snym }
    end

    # Returns the attributes of a field found by ID
    # @param id [Integer or String] field ID
    # @return [Hash, nil] field attributes
    def field_by_id(id = nil)
      @fields.find { |h| h[:id] == id.to_s }
    end

    # Alias of #field which returns all fields if no lookup found
    # @param lookup [String, Integer] field name or ID
    # @return [Hash, nil] info on the field specified
    def fields(lookup = nil)
      lookup ? field(lookup) : @fields
    end

    # Returns a field's ID
    # @param lookup [Symbol, String or Integer] field name or ID
    # @return [Integer, nil] field ID
    def field_id(lookup = nil)
      field = field(lookup)
      field[:id].to_i if field
    end

    # Returns hash of available list options for a given name
    # @param lookup [Symbol, String or Integer] field name or ID
    # @return [Hash, nil] list options
    def list_options(lookup = nil)
      field = field(lookup)
      field.dig(:list_options) if field
    end

    # Returns the attributes of the provided list option
    # @param field_name [Symbol, String or Integer] field name or ID
    # @param lookup [Symbol, String or Integer] list option name or ID
    # @return [Hash, nil] field attributes
    def list_option(field_name = nil, lookup = nil)
      if !(lookup.to_s =~ INTEGER_REGEXP).nil?
        list_option_by_id(field_name, lookup)
      else
        list_option_by_name(field_name, lookup)
      end
    end

    # Returns the attributes of the provided list option
    # @param field_name [Symbol, String or Integer] field ID
    # @param option_id [Symbol, String or Integer] list option ID
    # @return [Hash, nil] field attributes
    def list_option_by_id(field_name = nil, option_id = nil)
      list_options = list_options(field_name)
      return nil unless list_options
      list_options.find { |h| h[:id] == option_id.to_s }
    end

    # Returns the attributes of the provided list option
    # @param field_name [Symbol, String or Integer] field ID
    # @param option_name [Symbol, String or Integer] list option name
    # @return [Hash, nil] field attributes
    def list_option_by_name(field_name = nil, option_name = nil)
      list_options = list_options(field_name)
      return nil unless list_options
      list_options.find { |h| h[:display].to_snym == option_name.to_snym }
    end

    # Returns a list options's ID
    # @param field_name [Symbol, String or Integer] field ID
    # @param lookup [Symbol, String or Integer] list option name or ID
    # @return [Integer, nil] list option ID
    def list_option_id(field_name = nil, lookup = nil)
      list_option = list_option(field_name, lookup)
      list_option[:id].to_i if list_option
    end

    # Returns a coded Hash with all inputs converted to an API digestible Hash.
    # @param field_values [Hash] Hash of field values
    # @return [Hash, nil] field values coded with relevant IDs
    def coded_field_values(field_values = nil)
      return nil unless field_values
      coded_values = {}
      field_values.each do |k, v|
        value = v.is_a?(Symbol) ? list_option_id(k, v) : v
        coded_values[field_id(k)] = value
      end
      coded_values
    end

    # Returns a Hash with a ready to submit list item properties hash for the
    # specified list.
    # @param options [Hash] Hash of property options
    def list_item_properties(properties = {})
      {
        id: properties[:id],
        list_id: @id,
        name: @title,
        contact_ids: [properties[:contact_ids]].flatten,
        account_id: properties[:account_id],
        field_values: coded_field_values(properties[:field_values])
      }
    end

    # Convenience method for fetching or creating a listitem from the given list
    # @param oid [String, nil] ObjectId
    def list_item(oid = nil)
      RIQ::ListItem.new(oid, lid: @id)
    end

    private

    def init(obj = nil)
      obj ? init_from(obj) : init_nil
      self
    end

    def init_nil
      @id = nil
      @title = nil
      @type = nil
      @fields = nil
    end

    def init_from(obj)
      @id = obj[:id]
      @title = obj[:title]
      @type = obj[:listType]
      @fields = obj[:fields]
    end
  end

  class << self
    # Convenience method to create new Lists
    # @param id [String, nil] create a blank List object or
    #   fetch an existing one by id.
    # @return [List]
    def list(id = nil)
      List.new(id)
    end
  end
end
