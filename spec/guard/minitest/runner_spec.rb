# encoding: utf-8
require 'spec_helper'

describe Guard::Minitest::Runner do
  subject { Guard::Minitest::Runner }

  after(:each) do
    subject.class_eval do
      @seed    = nil
      @verbose = nil
      @bundler = nil
    end
  end

  describe 'set_seed' do

    it 'should use seed option first' do
      subject.seed.must_be_nil
      subject.set_seed(:seed => 123456789)
      subject.seed.must_equal 123456789
    end

    it 'should not set random seed by default' do
      subject.seed.must_be_nil
      subject.set_seed({})
      subject.seed.must_be_nil
    end

  end

  describe 'set_verbose' do

    it 'should use verbose option first' do
      subject.verbose?.must_equal false
      subject.set_verbose(:verbose => true)
      subject.verbose?.must_equal true
    end

    it 'should set verbose to false by default' do
      subject.verbose?.must_equal false
      subject.set_verbose
      subject.verbose?.must_equal false
    end

  end

  describe 'run' do

    before(:each) do
      @default_runner = File.expand_path('../../../../lib/guard/minitest/runners/default_runner.rb', __FILE__)
    end

    describe 'in empty folder' do

      before(:each) do
        Dir.stubs(:pwd).returns(fixtures_path.join('empty'))
      end

      it 'should run without bundler' do
        Guard::UI.expects(:info)
        subject.expects(:system).with(
          "ruby -Itest -Ispec -r test/test_minitest.rb -r #{@default_runner} -e 'MiniTest::Unit.autorun' --"
        )
        subject.run(['test/test_minitest.rb'])
      end

      it 'should set seed option' do
        subject.set_seed(:seed => 12345)
        Guard::UI.expects(:info)
        subject.expects(:system).with(
          "ruby -Itest -Ispec -r test/test_minitest.rb -r #{@default_runner} -e 'MiniTest::Unit.autorun' -- --seed 12345"
        )
        subject.run(['test/test_minitest.rb'])
      end

      it 'should set verbose option' do
        subject.set_verbose(:verbose => true)
        Guard::UI.expects(:info)
        subject.expects(:system).with(
          "ruby -Itest -Ispec -r test/test_minitest.rb -r #{@default_runner} -e 'MiniTest::Unit.autorun' -- --verbose"
        )
        subject.run(['test/test_minitest.rb'])
      end

    end

    describe 'in bundler folder' do

      before(:each) do
        Dir.stubs(:pwd).returns(fixtures_path.join('bundler'))
      end

      it 'should run with bundler' do
        Guard::UI.expects(:info)
        subject.expects(:system).with(
          "bundle exec ruby -Itest -Ispec -r bundler/setup -r test/test_minitest.rb -r #{@default_runner} -e 'MiniTest::Unit.autorun' --"
        )
        subject.run(['test/test_minitest.rb'])
      end

      it 'should set seed option' do
        subject.set_seed(:seed => 12345)
        Guard::UI.expects(:info)
        subject.expects(:system).with(
          "bundle exec ruby -Itest -Ispec -r bundler/setup -r test/test_minitest.rb -r #{@default_runner} -e 'MiniTest::Unit.autorun' -- --seed 12345"
        )
        subject.run(['test/test_minitest.rb'])
      end

      it 'should set verbose option' do
        subject.set_verbose(:verbose => true)
        Guard::UI.expects(:info)
        subject.expects(:system).with(
          "bundle exec ruby -Itest -Ispec -r bundler/setup -r test/test_minitest.rb -r #{@default_runner} -e 'MiniTest::Unit.autorun' -- --verbose"
        )
        subject.run(['test/test_minitest.rb'])
      end

    end

  end
end
