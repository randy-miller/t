# encoding: utf-8
require 'helper'

describe T::Delete do

  before do
    @t = T::CLI.new
    Timecop.freeze(Time.local(2011, 11, 24, 16, 20, 0))
    @old_stderr = $stderr
    $stderr = StringIO.new
    @old_stdout = $stdout
    $stdout = StringIO.new
  end

  after do
    $stderr = @old_stderr
    $stdout = @old_stdout
  end

  describe "#dm" do
    before do
      @t.options = @t.options.merge(:profile => File.expand_path('../fixtures/.trc', __FILE__), :force => true)
      stub_get("/1/direct_messages/sent.json").
        with(:query => {:count => "1"}).
        to_return(:body => fixture("direct_messages.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_delete("/1/direct_messages/destroy/1773478249.json").
        to_return(:body => fixture("direct_message.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.delete("dm")
      a_get("/1/direct_messages/sent.json").
        with(:query => {:count => "1"}).
        should have_been_made
      a_delete("/1/direct_messages/destroy/1773478249.json").
        should have_been_made
    end
    it "should have the correct output" do
      @t.delete("dm")
      $stdout.string.chomp.should == "@sferik deleted the direct message sent to @pengwynn: Creating a fixture for the Twitter gem"
    end
  end

  describe "#block" do
    before do
      @t.options = @t.options.merge(:profile => File.expand_path('../fixtures/.trc', __FILE__))
      stub_delete("/1/blocks/destroy.json").
        with(:query => {:screen_name => "sferik"}).
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.delete("block", "sferik")
      a_delete("/1/blocks/destroy.json").
        with(:query => {:screen_name => "sferik"}).
        should have_been_made
    end
    it "should have the correct output" do
      @t.delete("block", "sferik")
      $stdout.string.should =~ /^@testcli unblocked @sferik$/
    end
  end

  describe "#favorite" do
    before do
      @t.options = @t.options.merge(:profile => File.expand_path('../fixtures/.trc', __FILE__), :force => true)
      stub_get("/1/favorites.json").
        with(:query => {:count => "1"}).
        to_return(:body => fixture("favorites.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_delete("/1/favorites/destroy/28439861609.json").
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.delete("favorite")
      a_get("/1/favorites.json").
        with(:query => {:count => "1"}).
        should have_been_made
      a_delete("/1/favorites/destroy/28439861609.json").
        should have_been_made
    end
    it "should have the correct output" do
      @t.delete("favorite")
      $stdout.string.should =~ /^@testcli unfavorited @z's latest status: Spilled grilled onions on myself\.  I smell delicious!$/
    end
  end

  describe "#status" do
    before do
      @t.options = @t.options.merge(:profile => File.expand_path('../fixtures/.trc', __FILE__), :force => true)
      stub_get("/1/account/verify_credentials.json").
        to_return(:body => fixture("sferik.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      stub_delete("/1/statuses/destroy/26755176471724032.json").
        to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end
    it "should request the correct resource" do
      @t.delete("status")
      a_get("/1/account/verify_credentials.json").
        should have_been_made
      a_delete("/1/statuses/destroy/26755176471724032.json").
        should have_been_made
    end
    it "should have the correct output" do
      @t.delete("status")
      $stdout.string.chomp.should == "@testcli deleted the status: @noradio working on implementing #NewTwitter API methods in the twitter gem. Twurl is making it easy. Thank you!"
    end
  end

end
