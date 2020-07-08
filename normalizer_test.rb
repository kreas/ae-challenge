require 'minitest/autorun'
require_relative 'normalizer'

describe 'Normalizer' do
  before do
    @normalizer = Normalizer.new
  end

  describe 'When passed an array of inputs' do
    before do
      @examples = [
        [{ :year => '2018', :make => 'fo', :model => 'focus', :trim => 'blank' },
         { :year => 2018, :make => 'Ford', :model => 'Focus', :trim => nil }],
        [{ :year => '200', :make => 'blah', :model => 'foo', :trim => 'bar' },
         { :year => '200', :make => 'blah', :model => 'foo', :trim => 'bar' }],
        [{ :year => '1999', :make => 'Chev', :model => 'IMPALA', :trim => 'st' },
         { :year => 1999, :make => 'Chevrolet', :model => 'Impala', :trim => 'ST' }],
        [{ :year => '2000', :make => 'ford', :model => 'focus se', :trim => '' },
         { :year => 2000, :make => 'Ford', :model => 'Focus', :trim => 'SE' }]
      ]
    end

    it 'normalizes an array of records' do
      test_data = @examples.map(&:first)
      expected_data = @examples.map(&:last)

      _(@normalizer.normalize_data(test_data)).must_equal(expected_data)
    end
  end

  describe 'When passed a single input' do
    before do
      @example = { :year => '2018', :make => 'fo', :model => 'focus', :trim => 'blank' }
    end

    describe 'handling blanks' do
      it 'replaces blanks with nil' do
        @example.update(model: 'blank', make: 'not blank')
        # pp @normalizer.normalize_data(@example)[:model]

        _(@normalizer.normalize_data(@example)[:model]).must_be_nil
        _(@normalizer.normalize_data(@example)[:make]).must_equal 'not blank'
      end
    end

    describe 'normalizing the year' do
      it 'converts the year to an integer when valid' do
        @example.update(year: '2018')

        _(@normalizer.normalize_data(@example)[:year]).must_equal 2018
      end

      it 'returns the year as is if invalid' do
        @example.update(year: '2222')

        _(@normalizer.normalize_data(@example)[:year]).must_equal '2222'

        @example.update(year: '200')

        _(@normalizer.normalize_data(@example)[:year]).must_equal '200'
      end
    end

    describe 'normalizing the make' do
      it 'returns the make in a proper format' do
        @example.update(make: 'fo')
        _(@normalizer.normalize_data(@example)[:make]).must_equal 'Ford'

        @example.update(make: 'ford')
        _(@normalizer.normalize_data(@example)[:make]).must_equal 'Ford'

        @example.update(make: 'Chev')
        _(@normalizer.normalize_data(@example)[:make]).must_equal 'Chevrolet'
      end

      it 'returns the make as is if invalid' do
        @example.update(make: 'blah')
        _(@normalizer.normalize_data(@example)[:make]).must_equal 'blah'
      end
    end

    describe 'normalizes the model' do
      it 'returns the model in a proper format' do
        @example.update(model: 'focus')
        _(@normalizer.normalize_data(@example)[:model]).must_equal 'Focus'

        @example.update(model: 'IMPALA')
        _(@normalizer.normalize_data(@example)[:model]).must_equal 'Impala'

        @example.update(model: 'impala se')
        _(@normalizer.normalize_data(@example)[:model]).must_equal 'Impala'
      end

      it 'returns the model as is if invalid' do
        @example.update(model: 'nope')

        _(@normalizer.normalize_data(@example)[:model]).must_equal 'nope'
      end
    end

    describe 'normalizes the trim' do
      it 'returns the trim in a proper format' do
        @example.update(trim: 'se')
        _(@normalizer.normalize_data(@example)[:trim]).must_equal 'SE'

        @example.update(trim: 'st')
        _(@normalizer.normalize_data(@example)[:trim]).must_equal 'ST'
      end

      it 'returns the trim as is if invalid' do
        @example.update(trim: 'nope')
        _(@normalizer.normalize_data(@example)[:trim]).must_equal 'nope'
      end

      it 'extracts the trim from the model if needed xxx' do
        @example.update(model: 'ford se', trim: nil)
        _(@normalizer.normalize_data(@example)[:trim]).must_equal 'SE'

        @example.update(model: 'ford blah', trim: nil)
        _(@normalizer.normalize_data(@example)[:trim]).must_equal 'blah'

        @example.update(model: 'ford st', trim: '')
        _(@normalizer.normalize_data(@example)[:trim]).must_equal 'ST'
      end
    end
  end
end
