# Ruby 2.7.1

class Normalizer
  attr_reader :input

  MAKES = {
    /fo/i => 'Ford',
    /chev/i => 'Chevrolet'
  }

  MODELS = {
    /impala/i => 'Impala',
    /focus/i => 'Focus'
  }

  TRIMS = {
    /se/i => 'SE',
    /st/i => 'ST'
  }

  def normalize_data(input)
    if input.kind_of?(Array)
      input.map { |record| normalize_data(record) }

    else
      @input = input

      handle_blanks
      extract_trim_from_model
      normalize_year
      normalize_make(MAKES)
      normalize_model(MODELS)
      normalize_trim(TRIMS)

      @input
    end
  end

  private
    # Converts 'blank' to nil for all fields.
    def handle_blanks
      @input = @input.map do |key, value|
        return [key, value] unless value.respond_to?(:match?)

        updated_value = value.match(/^blank/i) ? nil : value

        [key, updated_value]
      end.to_h
    end

    # If the trim is empty or nil this method tries to extract the value from
    # the model. It assumes that the first word is alays the model and the rest
    # describes the trim.
    def extract_trim_from_model
      trim = @input[:trim]
      return unless trim.nil? || trim.strip.empty?

      model, *trims = @input[:model]&.split(' ') || []
      @input.update(trim: trims.join(' ')) unless trims.empty?
    end

    def is_literaly_blank(value)
      value&.match?(/^blank/i) ? nil : value
    end

    # Valids years are between 1900 and two years from the current year.
    # If a match is found update the input.
    def normalize_year
      min_year = 1900
      max_year = Time.new.year + 2
      year = @input[:year].to_i

      @input.update(year: year) if year.between?(min_year, max_year)
    end

    # looks up each key from their associated dictionary. If a match is found
    # update the input records, otherwise return it as is.
    [:make, :model, :trim].each do |type|
      define_method("normalize_#{type}") do |dict|
        original_value = @input[type]
        value = dict.find { |key, _| original_value&.match?(key) }&.last

        @input.update(type => value ? value : original_value)
      end
    end
end
