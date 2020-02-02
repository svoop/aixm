using AIXM::Refinements

module AIXM

  # OFMX-compliant +mid+ value
  #
  # For the +mid+ values to be calculated OFMX-compliant, you must either:
  # * set the region on the document beforehand
  # * set AIXM.config.region beforehand
  #
  # The `mid` values are only calculated and re-calculated when +to_uid+ is
  # called on a feature which happens implicitly when calling +to_xml+.
  # Subsequent changes on the payload of a feature won't automatically update
  # the +mid+ value.
  #
  # @see https://gitlab.com/openflightmaps/ofmx/wikis/Identifiers#mid
  module Mid

    # @return [String] UUIDv3 payload hash
    attr_reader :mid

    private

    def insert_mid(uid, set_attribute: true)
      region = AIXM.config.region || 'XX'
      warn "incompliant mid due to undefined region" if AIXM.ofmx? && region == 'XX'
      mid = uid.payload_hash
      @mid = mid if set_attribute
      AIXM.ofmx? && AIXM.config.mid ? uid.sub(/>/, %Q( mid="#{mid}">)) : uid
    end
  end
end
