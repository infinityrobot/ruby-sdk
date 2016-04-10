# The namespace from which all magic springs
module RIQ
  # Could fetch defaults or something here
end

# Monkeypatches
# cry about it, nerd
module RIQExtensions
  refine Symbol do
    def to_cam
      temp = self.to_s.split('_').map(&:capitalize).join
      (temp[0].downcase + temp[1..-1]).to_sym
    end

    def to_snake
      # could also change this to self.split(/(?=[A-Z])/).join('_').downcase
      a = self.to_s.split('')
      n = []
      a.each do |l|
        n << '_' if l.is_upper_char?
        n << l.downcase
      end
      n = n[1..-1] if n.first == '_'
      n.join.to_sym
    end
  end

  refine String do
    def is_upper_char?
      !self[/[A-Z]/].nil? && self.length == 1
    end

    def is_lower_char?
      !self[/[a-z]/].nil? && self.length == 1
    end
  end

  refine Fixnum do
    def cut_milis
      self.to_s[0...-3].to_i
    end

    def to_sym
      self.to_s.to_sym
    end
  end

  refine Hash do
    # Converts to RIQ API's [{raw: "VALUE"}] format
    def to_raw
      return {} if self.empty?
      o = {}
      self.each do |k, v|
        # TODO: should all picklists be arrays? right now it's only an array if it's a multipick with > 1 value
        # the api discards extra elements in non-list fields
        # listitem object doesn't know field types though
        if v.is_a? Array
          r = v.map{|x| {raw: x.to_s}}
        else
          r = [{raw: v.to_s}]
        end

        # this is the only user-visible snake_case key supplied by our api and it needs to stay that way
        if k == :primary_contact
          o[k] = r
        else
          o[k.to_cam] = r
        end
      end
      o
    end

    # Converts from RIQ API's [{raw: "VALUE"}] format
    def from_raw
      return {} if self.empty?
      o = {}
      self.each do |k,v|
        if v.is_a?(Array) # && v.length > 0 && v.first.include?(:raw)
          r = v.map{|x| x[:raw]}
          r = r.first if r.size == 1
          o[k.to_sym.to_snake] = r
        else
          o[k.to_sym.to_snake] = v
        end
      end
      o
    end

    def to_cam
      o = {}
      self.each do |k,v|
        o[k.to_cam] = v
      end
      o
    end
  end

  refine Object do
    def symbolize
      return self unless self.respond_to? :keys
      o = {}
      self.each do |k, v|
        if v.respond_to? :keys
          o[k.to_sym.to_snake] = v.symbolize
        else
          if v.respond_to? :each
            v.map! do |i|
              i.symbolize
            end
          end
          o[k.to_sym.to_snake] = v
        end
      end
      o
    end
  end
end

# Base file from which everything else is included
Dir[__dir__ + '/riq/*.rb'].each {|file| require file }
