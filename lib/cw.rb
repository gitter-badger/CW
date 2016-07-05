# encoding: utf-8

require_relative 'cw/file_details'
require_relative 'cw/process'
require_relative 'cw/text_helpers'
require_relative 'cw/tone_helpers'
require_relative 'cw/element'
require_relative 'cw/current_word'
require_relative 'cw/cw_dsl'
require_relative 'cw/randomize'
require_relative 'cw/sentence'
require_relative 'cw/alphabet'
require_relative 'cw/numbers'
require_relative 'cw/str'
require_relative 'cw/rss'
require_relative 'cw/words'
require_relative 'cw/cl'
require_relative 'cw/params'
require_relative 'cw/key_input'
require_relative 'cw/cw_stream'
require_relative 'cw/timing'
require_relative 'cw/print'
require_relative 'cw/audio_player'
require_relative 'cw/cw_threads'
require_relative 'cw/book_details'
require_relative 'cw/tester'
require_relative 'cw/test_words'
require_relative 'cw/test_letters'
require_relative 'cw/repeat_word'
require_relative 'cw/reveal'
require_relative 'cw/book'
require_relative 'cw/cw_encoding'
require_relative 'cw/tone_generator'
require_relative 'cw/progress'
require_relative 'cw/config_file'

# CW provides Morse code generation functionality

def cw &block
  CW.new do
    instance_eval &block
  end
end

class CW < CwDsl

#FIXME dry_run
#  attr_accessor :dry_run

  # Initialize CW class. Eval block if passed in.

  def initialize(&block)

    super

    load_common_words# unless @words.exist?
    ConfigFile.new.apply_config self
    instance_eval(&block) if block
    run if block
  end

  # Test user against letters rather than words.
  #

  def test_letters
    Params.pause = true
    test_letters = TestLetters.new
    test_letters.run @words
  end

  # Test user against complete words rather than letters.
  #

  def test_words
    Params.pause = true
    tw = TestWords.new
    tw.run @words
  end

  # Repeat word repeats the current word if the word is entered incorrectly (or not entered at all).
  #

  def repeat_word
    Params.pause = true
    repeat_word = RepeatWord.new
    repeat_word.run @words
  end

  # Reveal words only at end of test.
  # Useful for learning to copy `in the head'

  def reveal
    Params.pause = true
    reveal = Reveal.new
    reveal.run @words
  end

  # Return string containing name or comment of test.
  # @return [String] comment / name

  def to_s
    @str.to_s
  end

  def list
    Print.new.list self.to_s
    puts
  end

  # Play book using provided arguments.
  # @param [Hash] args the options to play book with.
  # @option args [Integer] :sentences Number of sentences to play
  # @option args [Integer] :duration  Number of minutes to play
  # @option args [Boolean] :letter Mark by letter if true else mark by word

  def play_book args = {}
    Params.pause = true
    details = BookDetails.new
    details.arguments(args)
    book = Book.new details
    book.run @words
  end

  # Convert book to mp3.

  def convert_book args = {}
    details = BookDetails.new
    details.arguments(args)
    book = Book.new details
    Params.pause = true
    book.convert
  end

  # Reads RSS feed (requires an internet connection). Feed can be one of:
  # - bbc:
  # - reuters:
  # - guardian:
  # - quotation:
  # @param [Symbol] source The source of the feed.
  # @param [Integer] article_count Number of articles to play.

  def read_rss(source, article_count = 3)
    Params.pause = true
    rss, = Rss.new
    rss.read_rss(source, article_count)
    loop do
      article = rss.next_article
      return unless article
      @words.assign article
      run
    end
  end

  # Run word test
  def run
    return if Params.pause
    test_words
  end

  alias_method :ewpm,                  :effective_wpm
  alias_method :no_run,                :pause
  alias_method :comment,               :name
  alias_method :word_length,           :word_size
  alias_method :word_shuffle,          :shuffle
  alias_method :having_size_of,        :word_size
  alias_method :number_of_words,       :word_count
  alias_method :words_including,       :including
  alias_method :words_ending_with,     :ending_with
  alias_method :random_alphanumeric,   :random_letters_numbers
  alias_method :words_beginning_with,  :beginning_with
  alias_method :words_no_longer_than,  :no_longer_than
  alias_method :words_no_shorter_than, :no_shorter_than

end
