require_relative 'riq_obj'

# RIQ module.
module RIQ
  # A List is an object that can be created & customized by a User to represent
  # Accounts (companies) or Contacts (people) in a process (sales pipeline).
  class List < RIQObject
    # can't create a list through API, so these don't need to write
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

    # Gets field if it exists
    # @param id [String, Integer] field ID
    # @return [Hash, nil] info on the field specified
    def fields(id = nil)
      unless id.nil?
        @fields.select{|f| f[:id] == id.to_s}.first
      else
        @fields
      end
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
