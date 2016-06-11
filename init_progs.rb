["audio_dir",
"audio_filename",
"author",
"book_dir",
"command_line",
"config_file",
"double_words",
"effective_wpm",
"ewpm",
"frequency",
"mark_words",
"name",
"no_noise",
"no_shuffle",
"noise",
"pause",
"print_letters",
"quality",
"shuffle",
"single_words",
"title",
"un_pause",
"use_ebook2cw",
"use_ruby_tone",
"word_spacing",
"wpm"].each do |name|
  File.open("cw_scripts/#{name}.rb", 'w') do |file|

    file.puts "require \"cw\""
    file.puts ""
    file.puts "CW.new do"
    file.puts "# TODO:  #{name}()"
    file.puts "  word_count 4"
    file.puts "end"
  end
end
