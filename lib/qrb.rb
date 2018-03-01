require "qrb/version"
require 'erb'

module QRB
  class Translator
    attr_reader :sql
    def initialize(sql)
      @sql = sql
    end

    def translate
      sql.gsub(/\/\*\*/, "<%" ).gsub(/\*\// , "%>")
    end
  end
end
