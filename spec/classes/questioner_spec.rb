require 'spec_helper'
require 'stringio'

require 'puppetdevel/questioner'

describe PuppetDevel::Questioner do
  before(:each) do
    @stdin = StringIO.new
    @stdin << "input"
    @stdin.rewind
    @stdout = StringIO.new
  end

  describe '.ask' do
    context 'without a default' do
      it do
        expect(PuppetDevel::Questioner.ask 'question?', stdin: @stdin, stdout: @stdout).to eq 'input'
      end

      it do
        PuppetDevel::Questioner.ask('question', stdin: @stdin, stdout: @stdout)
        expect(@stdout.string.chomp).to eq 'question ? '
      end
    end

    context 'with a default' do
      context 'with input' do
        it do
          answer = PuppetDevel::Questioner.ask('question', 'the default', stdin: @stdin, stdout: @stdout)
          expect(@stdout.string.chomp).to eq 'question [the default] ? '
          expect(answer).to eq 'input'
        end
      end

      context 'without input' do
        it do
          @stdin.truncate(0)
          @stdin << "\n"
          @stdin.rewind
          answer = PuppetDevel::Questioner.ask('question?', 'the default', stdin: @stdin, stdout: @stdout)
          expect(answer).to eq 'the default'
        end
      end
    end
  end

  describe '.ask_password' do
    it do
      password = PuppetDevel::Questioner.ask_password('Enter Password:', stdin: @stdin, stdout: @stdout)
      expect(password).to eq 'input'
    end
  end
end
