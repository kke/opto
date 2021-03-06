require_relative '../type'
require_relative '../extensions/hash_string_or_symbol_key'
require 'base64'

module Opto
  module Types
    class String < Opto::Type
      using Opto::Extension::HashStringOrSymbolKey

      TRANSFORMATIONS = [ :upcase, :downcase, :strip, :chomp, :capitalize ]

      OPTIONS = {
        min_length: nil,
        max_length: nil,
        empty_is_nil: true,
        encode_64: false,
        decode_64: false
      }.merge(Hash[*TRANSFORMATIONS.flat_map {|tr| [tr, false]}])


      sanitizer :encode_64 do |value|
        (options[:encode_64] && value) ? Base64.encode64(value) : value
      end

      sanitizer :decode_64 do |value|
        (options[:decode_64] && value) ? Base64.decode64(value) : value
      end

      TRANSFORMATIONS.each do |transform|
        sanitizer transform do |value|
          (options[transform] && value.respond_to?(transform)) ? value.send(transform) : value
        end
      end

      sanitizer :empty_is_nil do |value|
        (options[:empty_is_nil] && value.to_s.strip.empty?) ? nil : value.to_s
      end

      validator :min_length do |value|
        if options[:min_length] && value.length < options[:min_length]
          "Too short. Minimum length is #{options[:min_length]}, length is #{value.length}."
        end
      end

      validator :max_length do |value|
        if options[:max_length] && value.length > options[:max_length]
          "Too long. Maximum length is #{options[:max_length]}, length is #{value.length}."
        end
      end
    end
  end
end
