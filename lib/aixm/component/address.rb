using AIXM::Refinements

module AIXM
  class Component

    # Address or similar means to contact an entity.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   address = AIXM.address(
    #     type: TYPES
    #     address: String
    #   )
    #   service.remarks = String or nil
    #
    # @see https://github.com/openflightmaps/ofmx/wiki/Airport#aha-airport-address
    class Address
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
      }

      # @return [AIXM::Feature] addressable feature
      attr_reader :addressable

      # @return [Symbol] type of address (see {TYPES})
      attr_reader :type

      # @return [String] postal address, phone number, radio frequency etc
      attr_reader :address

      # @return [String, nil] free text remarks
      attr_reader :remarks

      def initialize(type:, address:)
        self.type, self.address = type, address
      end

      # @return [String]
      def inspect
        %Q(#<#{self.class} type=#{type.inspect}>)
      end

      def addressable=(value)
        fail(ArgumentError, "invalid addressable") unless value.is_a? AIXM::Feature
        @addressable = value
      end
      private :addressable=

      def type=(value)
        @type = TYPES.lookup(value&.to_s&.to_sym, nil) || fail(ArgumentError, "invalid type")
      end

      def address=(value)
        fail(ArgumentError, "invalid address") unless value.is_a? String
        @address = value&.to_s
      end

      def remarks=(value)
        @remarks = value&.to_s
      end

      # @return [String] UID markup
      def to_uid(as:, sequence:)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.tag!(as) do |tag|
          tag << addressable.to_uid.indent(2) if addressable
          tag.codeType(TYPES.key(type).to_s.then { |t| AIXM.aixm? ? t.sub(/-\w+$/, '') : t })
          tag.noSeq(sequence)
        end
      end

      # @return [String] AIXM or OFMX markup
      def to_xml(as:, sequence:)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.tag!(as) do |tag|
          tag << to_uid(as: :"#{as}Uid", sequence: sequence).indent(2)
          tag.txtAddress(address)
          tag.txtRmk(remarks) if remarks
        end
      end
    end

  end
end
