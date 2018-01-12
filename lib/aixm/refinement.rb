module AIXM
  module Refinement

    module Digest
      refine Array do
        ##
        # Build 8 character hex digest from payload (one or more strings)
        def to_digest
          ::Digest::MD5.hexdigest(join('|'))[0, 8]
        end
      end
    end

  end
end
