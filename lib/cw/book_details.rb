# encoding: utf-8

module CWG

  class BookDetails

    attr_reader :args

    include FileDetails

    def initialize
      book_directory
      book_name
    end

    def book_name
      Cfg.config["book_name"]
    end

    def book_directory
      File.join ROOT, Cfg.config["book_dir"]
    end

    def book_location
      File.expand_path(book_name, book_directory)
    end

    def arguments args
      @args = args
      @args[:output] = :letter unless @args[:output]
      if @args[:duration]
        @timeout = Time.now + @args[:duration] * 60.0
      end
    end

    def session_finished?
      sentences_complete? || book_timeout?
    end

    def sentences_complete?
      if @args.has_key?(:sentences) &&  @args[:sentences].is_a?(Fixnum)
        if @sentence_count_source
          @sentence_count_source = nil
        else
          @args[:sentences] -= 1
          @sentence_count_source = true
        end
        true if(@args[:sentences] < 0)
      end
    end

    def book_timeout?
      @timeout && (Time.now > @timeout)
    end

  end

end
