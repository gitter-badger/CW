# encoding: utf-8

require 'wavefile'

class ToneGenerator

  DOT_FILENAME     = "audio/dot.wav"
  DASH_FILENAME    = "audio/dash.wav"
  SPACE_FILENAME   = "audio/space.wav"
  E_SPACE_FILENAME = "audio/e_space.wav"
  TWO_PI           = 2 * Math::PI

  def initialize
    @max_amplitude = 0.5
    @wpm = Params.wpm
    @frequency = Params.frequency
    @effective_wpm = Params.effective_wpm ? Params.effective_wpm : @wpm
    @sample_rate = 2400
    @print = Print.new
  end

  def cw_encoding
    @encoding ||= CwEncoding.new
  end

  def convert_words wrds
    wrds.to_array.collect{ |wrd| wrd.gsub("\n","")}
  end

  def progress
    @progress ||= Progress.new('Compiling')
  end

  def generate wrds
    word_parts(wrds)
#    progress.init elements.size * 3 + (wrds.size)
    create_element_methods
    compile_fundamentals
    write_word_parts
  end

  def play_filename
    "audio/#{Params.audio_filename}"
  end

  def play
    cmd = play_command + ' ' + play_filename
    @pid = ! @dry_run ? Process.spawn(cmd) : cmd
  end
  def data
    { :dot => {:name => :dot,
               :filename => DOT_FILENAME,
               :spb => (@sample_rate * 1.2 / @wpm).to_i },
      :dash  => {:name => :dash,
                 :filename => DASH_FILENAME,
                 :spb => (@sample_rate * 3.6 / @wpm).to_i },
      :space => {:name => :space,
                 :filename   => SPACE_FILENAME   ,
                 :spb => (@sample_rate * 1.2 / @wpm).to_i },
      :e_space => {:name => :e_space,
                   :filename => E_SPACE_FILENAME ,
                   :spb => (@sample_rate * 1.2 / @effective_wpm).to_i }}
  end

  def generate_space number_of_samples
    [].fill(0.0, 0, number_of_samples)
  end

  def filter_maybe(size, count)
    ramp = 0.05
    ramp_point =  @max_amplitude / ramp
    ampl = (count < ramp_point) ? (ramp * count) : @max_amplitude
    (count > (size - ramp_point)) ? (ramp * (size - count)) : ampl
  end

  def generate_tone(number_of_samples)
    position_in_period, position_in_period_delta =  0.0, @frequency / @sample_rate
    audio_samples = [].fill(0.0, 0, number_of_samples)
    number_of_samples.times do |sample_number|
      amplitude = filter_maybe(number_of_samples, sample_number)
      #      amplitude = 1.0 # @max_amplitude
      sine_radians = ((@frequency * TWO_PI) / @sample_rate) * sample_number
      audio_samples[sample_number] = amplitude * Math.sin(sine_radians)
    end
    audio_samples
  end

  def generate_buffer audio_samples, ele
    WaveFile::Buffer.new(audio_samples, WaveFile::Format.new(:mono, :float, data[ele][:spb]))
  end

  def write_element_audio_file ele, buffer
    WaveFile::Writer.new(data[ele][:filename], WaveFile::Format.new(:mono, :pcm_16, @sample_rate)) do |writer|
      writer.write(buffer)
    end
  end

  def elements
    [:dot, :dash, :space, :e_space]
  end

  def create_element_method ele
    define_singleton_method(ele) {data[ele]}
  end

  def create_element_methods
    elements.each do |ele|
#      progress.increment
      create_element_method ele
    end
  end

  def space_sample? ele
    ele == :space || ele == :e_space
  end

  def generate_samples ele
    return generate_space(data[ele][:spb]) if space_sample? ele
    generate_tone(data[ele][:spb])  unless    space_sample? ele
  end

  def compile_fundamentals
    elements.each do |ele|
#      progress.increment
      audio_samples = generate_samples ele
      buffer = generate_buffer(audio_samples, ele)
      write_element_audio_file ele, buffer
    end
  end

  def space_or_espace
    (@effective_wpm == @wpm) ? space : e_space
  end

  def last_element? idx, chr
    idx == chr.size - 1
  end

  def push_enc chr
    arry = []
    chr.each_with_index do |c,idx|
      arry << c
      arry << ((last_element?(idx, chr)) ? (space_or_espace) : space)
    end
    arry += char_space
  end

  def send_char c
    if c == ' '
      enc = word_space
    else
      enc = cw_encoding.fetch(c).map { |enc| send(enc)}
    end
    push_enc enc
  end

  def word_parts str = nil
    return @word_parts if @word_parts
    @word_parts = []
    str.split('').each { |part| @word_parts << part}
    @word_parts
  end


  def make_word_parts words
    parts = []
    @word_parts.each do |part|
#      progress.increment
      parts += send_char part.downcase
    end
    parts
  end

  def prepare_buffers
    @buffers = {}
    elements.each do |ele|
#      progress.increment
      @buffers[ele] = []
      WaveFile::Reader.new(data[ele][:filename]).
        each_buffer(data[ele][:spb]) do |buffer|
        @buffers[ele] = buffer
      end
    end
  end

  def write_word_parts
    prepare_buffers
    write_audio_file
  end

  def char_space
    @effective_wpm == @wpm ? [space,space] : [e_space,e_space]
  end

  def word_space
    @effective_wpm == @wpm ? [space] : [e_space]
  end

  def word_composite word
    send_char word.downcase
  end

  def write_audio
    WaveFile::Writer.new(play_filename, WaveFile::Format.new(:mono, :pcm_16, @sample_rate)) do |writer|
      yield.each do |char|
#        progress.increment
        char.each do |fta|
          writer.write(@buffers[fta[:name]])
        end
      end
    end
  end

  def reset
    @word_parts = @progress = nil
#    puts "\r"
  end

  def write_audio_file
    write_audio { @word_parts.collect {|part| word_composite(part) } }
    reset
  end

end

