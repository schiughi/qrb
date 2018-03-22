module QRB
  class TypeError < TypeError; end
  class RequiredError < StandardError; end
  class BreachOfContractError < ArgumentError; end

  #
  # class User < QRB::ModelMapper
  #   val name: Name, required: true, immutable: false,
  #     contract: { first: :first_name, last: :last_name }
  # end
  #
  #
  # class Name
  #   attr_reader :first , :last
  #   def initialize(first: , last:)
  #     @first = first
  #     @last = last
  #   end
  # end
  #
  # user = User.new(first_name: "Tyler", last_name: "Durden")
  # user.name.first # => "Tyler"
  #
  class ModelMapper
    class Mapper
      attr_reader :name , :klass, :contract
      def initialize(options = {})
        @name = options.keys.first
        @klass = options.values.first
        @required = options.fetch(:required, false)
        @immutable = options.fetch(:immutable, true)
        @contract = options.fetch(:contract, {})
      end

      def required?
        @required
      end

      def immutable?
        @immutable
      end

      def mutable?
        not immutable?
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
            @attributes_cache ||= {}
            if mapper.mmutable?
              attribute = @attribute[mapper.name.to_sym]
              return attribute unless attribute.nil?
            end

            if mapper.contractable?
              construction = mapper.contract.inject({}) do |con, (key, value)|
                con[key] = @record_cache[value.to_sym]
              end
              begin
                attribute = mapper.klass.new(construction)
              rescue ArgumentError
                raise BreachOfContractError
              end
            else
              attribute = @record_cache[mapper.name.to_sym]
            end

            if mapper.immutable?
              attribute.freeze
            else
              @attributes_cache[mapper.name.to_sym] = attribute
            end
            attribute
          end
        end

        def write_method(mapper)
          define_method("#{mapper.name}=") do |argument|
            raise RequiredError if argument.nil? && mapper.required?
            raise TypeError unless !argument.nil? && argument.is_a? mapper.klass
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
