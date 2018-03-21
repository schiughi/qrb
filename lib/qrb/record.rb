module QRB
  class TypeError < TypeError; end
  class RequiredError < StandardError; end

  #
  # class User < QRB::Record
  #   val name: Name, required: true, imutable: true,
  #     contract: { first: :first_name, last: :last_name }
  # end
  #
  #
  # class Name
  #   attr_accessor :first , :last
  # end
  #
  class Record
    class Mapper
      attr_reader :name , :klass, :contract
      def initialize(options = {})
        @name = options.keys.first
        @klass = options.values.first
        @required = options.fetch(:required, false)
        @imutable = options.fetch(:imutable, false)
        @contract = options.fetch(:contract, {})
      end

      def required?
        @required
      end

      def imutable?
        @imutable
      end
      
      def contractable?
        not @contract.empty?
      end
    end

    class << self

      def val(options = {})
        mapper = Mapper.new(options)
        read_method(mapper)
      end

      def var(options = {})
        mapper = Mapper.new(options)
        read_method(mapper)
        write_method(mapper)
      end

      private
        def read_method(mapper)
          define_method(mapper.name) do
            if mapper.contractable?
              attribute = mapper.klass.new
              mapper.contract.each do |key, value|
                attribute.__send__("#{key}=", @record_cache[value.to_sym])
              end
            else
              attribute = @record_cache[mapper.name.to_sym]
            end

            attribute.freeze if mapper.imutable?
            attribute
          end
        end
        
        def write_method(mapper)
          define_method("#{mapper.name}=") do |argument|
            raise RequiredError if argument.nil? && mapper.required?
            raise TypeError unless argument.is_a? mapper.klass
            if mapper.contractable?
              mapper.contract.each do |key, value|
                @record_cache[value.to_sym] = argument.send(key)
              end
            else
              @record_cache[value.to_sym] = argument
            end
          end
      end
    end

    def initialize(record = {})
      @record_cache = record
    end
  end
end
