require File.expand_path("#{File.dirname(__FILE__)}/spec_helper")

describe RecordedCalls do
  before(:each) do
    @subject = Object.new
    extend RR::Adapters::RRMethods
    stub(@subject).foobar
    @recorded_calls = RecordedCalls.new([[@subject,:foobar,[1,2],nil]])
  end
    
  
  it "should verify method calls after the fact" do
    stub(@subject).pig_rabbit
    @subject.pig_rabbit("bacon", "bunny meat")
    #subject.should have_received.pig_rabitt("bacon", "bunny meat")
    verify_spy received(@subject).pig_rabbit("bacon", "bunny meat")
  end
  
  it "should match when there is an exact match" do
    @subject.foobar(1,2)
    verify_spy received(@subject).foobar(1,2)
    
  end

  it "should match when there is an exact match with a times matcher" do
    @subject.foobar(1,2)
    verify_spy received(@subject).foobar(1,2).once
    @subject.foobar(1,2)
  end

  it "should match when there is an at least matcher" do
    @subject.foobar(1,2)
    @subject.foobar(1,2)
    @subject.foobar(1,2)
    verify_spy received(@subject).foobar(1,2).at_least(2)
  end

  it "should raise an error when the number of times doesn't match" do
    @subject.foobar(1,2)
    lambda do
      verify_spy received(@subject).foobar(1,2).twice    
    end.should raise_error(RR::Errors::SpyVerificationError)    
  end

  it "should match when there is an wildcard match" do
    @subject.foobar(1,2)
    verify_spy received(@subject).foobar(1,is_a(Fixnum))
  end
  
  it "should not match when there is neither an exact nor wildcard match" do
    @subject.foobar(1,2)
    verify_spy received(@subject).foobar(1,is_a(Fixnum))
    lambda do
      verify_spy received(@subject).foobar(1,is_a(String))
    end.should raise_error(RR::Errors::SpyVerificationError)
  end
  
  it "should raise an error when the subject doesn't match" do
    @subject.foobar(1,2)
    @wrong_subject = Object.new
    lambda do
      verify_spy received(@wrong_subject).foobar(1,2).once    
    end.should raise_error(RR::Errors::SpyVerificationError)    
  end
end