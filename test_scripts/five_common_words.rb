# five-common-words.rb

require 'cw'

CW.new do
  comment "5 common words at 12 words per minute"
  shuffle
  word_count 5
  wpm 12
end
