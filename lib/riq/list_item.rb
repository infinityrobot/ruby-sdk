require_relative 'riq_obj'
using RIQExtensions

module RIQ
  # A List Item is a row in a List.
  class ListItem < RIQObject
    attr_accessor :name
    attr_accessor :field_values
    attr_accessor :account_id
    attr_accessor :contact_ids
    attr_accessor :list_id

    attr_reader :modified_date
    attr_reader :created_date

    # @example create a list item
    #   # vanilla
    #   RIQ::ListItem.new
    #   # with a list id
    #   RIQ::ListItem(lid: 'abc123') # OR RIQ.list('abc123').list_item
    def initialize(id = nil, lid = nil)
      if id.is_a? Hash
        # init with data
        super(id)
      elsif id.nil?
        # vanilla object
        super(nil)
        # maybe init with lid
        @list_id = lid unless lid.nil?
      elsif lid.nil?
        # has id, but not lid, that's an error
        raise RIQError, 'ObjectID and List ID are required'
      else
        # grabbing a specific listitem, fetch it
        super("#{lid}/listitems/#{id}")
      end
    end

    # (see RIQObject#node)
    def node
      self.class.node(@list_id, @id)
    end

    # @note this is the only object for which you have to include two params
    # @param lid [String] ListId that the lit item belongs to
    # @param oid [String] ObjectId for the object
    def self.node(lid = nil, oid = nil)
      # weird workaround for fetching node on init
      if lid.nil? && !oid.nil?
        "lists/#{oid}"
      else
        "lists/#{lid || @list_id}/listitems/#{oid}"
      end
    end

    # (see RIQObject#data)
    def data
      {
        name: @name,
        account_id: @account_id,
        contact_ids: @contact_ids.flatten,
        id: @id,
        list_id: @list_id,
        field_values: @field_values,
        modified_date: @modified_date
      }
    end

    # (see RIQObject#payload)
    def payload
      pld = {}
      data.each do |k, v|
        if k == :field_values
          pld['fieldValues'] = @field_values.to_raw
        elsif k['_']
          pld[k.to_cam] = v
        else
          pld[k] = v
        end
      end
      pld.to_json
    end

    # @overload field_value(key)
    #   @param key [String, Integer]
    #   @return [String, Array] Value of key
    # @overload field_value(key, value)
    #   Sets key to value
    #   @param key [String, Integer] Key to set
    #   @param value [String, Integer, Array] Sets key to value
    def field_value(key, value = nil)
      # TODO: double check that this works with arrays of stuff
      # or, have a format function that casts ints to string on save
      if value.nil?
        @field_values.fetch(key.to_sym, nil)
      else
        unless value.is_a? Array
          value = value.to_s
        end
        @field_values[key.to_sym] = value
        {key.to_sym => value}
      end
    end

    private

    def init(obj = nil)
      unless obj.nil?
        @id = obj[:id]
        @list_id = obj[:list_id]
        @name = obj[:name]
        @field_values = obj[:field_values] ? obj[:field_values].from_raw : {}
        @account_id = obj[:account_id]
        @contact_ids = obj[:contact_ids] || []
        @modified_date = obj[:modified_date].cut_milis if obj[:modified_date]
        @created_date = obj[:created_date].cut_milis if obj[:created_date]
      else
        @id = nil
        @list_id = nil
        @name = nil
        @field_values = {}
        @account_id = nil
        @contact_ids = []
        @modified_date = nil
        @created_date = nil
      end
      self
    end

    def pre_save
      if @list_id.nil?
        raise RIQError, 'List ID is required'
      end
    end
  end
end
