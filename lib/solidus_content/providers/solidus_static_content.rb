# frozen_string_literal: true

module SolidusContent
  module Providers
    class SolidusStaticContent
      class << self
        def call(input)
          slug = input.dig(:options, :slug) || input[:slug]

          input.merge(data: Spree::Page.find_by!(slug: slug).attributes.symbolize_keys)
        end

        def entry_type_fields
          []
        end

        def entry_fields
          %i[slug]
        end
      end
    end
  end
end
