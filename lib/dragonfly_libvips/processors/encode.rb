# frozen_string_literal: true

require 'vips'
require 'dragonfly_libvips/processors'

module DragonflyLibvips
  module Processors
    class Encode
      include DragonflyLibvips::Processors

      def call( *args, **options)
        content, format = args

        raise UnsupportedOutputFormat unless SUPPORTED_OUTPUT_FORMATS.include?(format.downcase)

        if content.mime_type == Rack::Mime.mime_type(".#{format}")
          content.ext ||= format
          content.meta['format'] = format
          return
        end

        options['format'] = format
        wrap_process(content, **options) do |img |
          img
        end
      end
    end
  end
end
