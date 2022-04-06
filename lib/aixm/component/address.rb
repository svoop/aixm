using AIXM::Refinements

module AIXM
  class Component

    # Address or similar means to contact an entity.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   address = AIXM.address(
    #     type: TYPES
    #     address: AIXM.f (type :radio_frequency) or String (other types)
    #   )
    #   address.remarks = String or nil
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#aha-airport-address
    class Address < Component
      include AIXM::Association
      include AIXM::Memoize
      include AIXM::Concerns::Remarks

      public_class_method :new

      TYPES = {
        POST: :postal_address,
        PHONE: :phone,
        'PHONE-MET': :weather_phone,
        FAX: :fax,
        TLX: :telex,
        SITA: :sita,
        AFS: :aeronautical_fixed_service_address,
        EMAIL: :email,
        URL: :url,
        'URL-CAM': :webcam,
        'URL-MET': :weather_url,
        RADIO: :radio_frequency,
        OTHER: :other   # specify in remarks
      }.freeze

      # @!method addressable
      #   @return [AIXM::Feature] addressable feature
      belongs_to :addressable

      # Type of address
      #
      # @overload type
      #   @return [Symbol] any of {TYPES}
      # @overload type=(value)
      #   @param value [Symbol] any of {TYPES}
      attr_reader :type

      # Postal address, phone number, radio frequency etc
      #
      # @overload address
      #   @return [String]
      # @overload address=(value)
      #   @param value [String]
      attr_reader :address

      # See the {cheat sheet}[AIXM::Component::Address] for examples on how to
      # create instances of this class.
      def initialize(type:, address:)
        self.type, self.address = type, address
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} type=#{type.inspect}>)
      end

      def type=(value)
        @type = TYPES.lookup(value&.to_s&.to_sym, nil) || fail(ArgumentError, "invalid type")
      end

      def address=(value)
        case type
        when :radio_frequency
          fail(ArgumentError, "invalid address frequency") unless value.is_a?(AIXM::F)
          @address = value
        else
          fail(ArgumentError, "invalid address") unless value
          @address = value.to_s
        end
      end

      # @return [String] UID markup
      def to_uid(as:, sequence:)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.tag!(as) do |tag|
          tag << addressable.to_uid.indent(2) if addressable
          tag.codeType(TYPES.key(type).to_s.then_if(AIXM.aixm?) { _1.sub(/-\w+$/, '') })
          tag.noSeq(sequence)
        end
      end
      memoize :to_uid

      # @return [String] AIXM or OFMX markup
      def to_xml(as:, sequence:)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.comment! ["Address: #{TYPES.key(type)}", addressable&.id].compact.join(' for ')
        builder.tag!(as) do |tag|
          tag << to_uid(as: :"#{as}Uid", sequence: sequence).indent(2)
          case type
          when :radio_frequency
            tag.txtAddress(address.freq.to_s)
          else
            tag.txtAddress(address)
          end
          tag.txtRmk(remarks) if remarks
        end
      end
    end

  end
end
