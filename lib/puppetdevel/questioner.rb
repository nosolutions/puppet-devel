module PuppetDevel
  class Questioner
    attr_reader :question, :default

    def initialize(question, default, stdin: STDIN, stdout: STDOUT)
      @question = question
      @default = default || nil
      @stdin = stdin
      @stdout = stdout
    end

    def self.ask(question, default=nil, stdin: STDIN, stdout: STDOUT )
      questioner = Questioner.new question, default, stdin: stdin, stdout: stdout
      questioner.ask
    end

    def self.ask_password(question, stdin: STDIN, stdout: STDOUT)
      questioner = Questioner.new question, nil, stdin: stdin, stdout: stdout
      questioner.ask_password
    end

    def self.readline(question, list)
      Readline.completion_append_character = ''
      Readline.completion_proc = Proc.new { |s| list.grep(/^#{Regexp.escape(s)}/) }
      Readline.readline(question, true)
    end

    public

    def ask
      prompt = "#{question} "
      prompt << "[#{default}] " unless default.nil?
      prompt << '? '
      @stdout.print prompt
      get_input
    end

    def ask_password
      require 'io/console'

      @stdout.print "#{question}: "
      system 'stty -echo'
      input = get_input
      system 'stty echo'
      puts
      input
    end

    private

    def get_input
      input = @stdin.gets.chomp.strip
      input = default if input == ''
      return input
    end
  end
end
