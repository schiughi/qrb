require "qrb/version"
require 'erb'

module QRB
  class Translator
    attr_reader :sql
    def initialize(sql)
      @sql = sql
    end

    def call
      sql.gsub(/\/\*\*/, "<%" ).gsub(/\*\// , "%>")
    end
  end

  class Query
    attr_reader :file
    def initialize(file)
      @file = file
    end

    def call
      ERB.new(translated).result
    end

    def translated
      Translator.new(file)
    end
  end
end
