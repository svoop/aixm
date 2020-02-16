using AIXM::Refinements

module AIXM
  class Feature

    # Address or similar means to contact an entity.
    #
    # ===Cheat Sheet in Pseudo Code:
    #   address = AIXM.address(
    #     source: String or nil
    #     type: TYPES
    #     address: String
    #   )
    #   service.remarks = String or nil
    #
    # @see https://gitlab.com/openflightmaps/ofmx/wikis/Airport#aha-airport-address
    class Address < Feature
      include AIXM::Association

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
      }

      # @!method addressable
      #   @return [AIXM::Feature] addressable feature
      belongs_to :addressable

      # @return [Symbol] type of address (see {TYPES})
      attr_reader :type

      # @return [String] postal address, phone number, radio frequency etc
      attr_reader :address

      # @return [String, nil] free text remarks
      attr_reader :remarks

      def initialize(source: nil, region: nil, type:, address:)
        super(source: source, region: region)
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
          tag.codeType(TYPES.key(type).to_s.then_if(AIXM.aixm?) { _1.sub(/-\w+$/, '') })
          tag.noSeq(sequence)
        end
      end

      # @return [String] AIXM or OFMX markup
      def to_xml(as:, sequence:)
        builder = Builder::XmlMarkup.new(indent: 2)
        builder.comment! ["Address: #{TYPES.key(type)}", addressable&.id].compact.join(' for ')
        builder.tag!(as, { source: (source if AIXM.ofmx?) }.compact) do |tag|
          tag << to_uid(as: :"#{as}Uid", sequence: sequence).indent(2)
          tag.txtAddress(address)
          tag.txtRmk(remarks) if remarks
        end
      end
    end

  end
end
