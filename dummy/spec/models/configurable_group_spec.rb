require 'spec_helper'

describe ConfigurableGroup do

  describe ".keys" do
    it "should collect the keys" do
      Configurable.group1.keys.should == ['group2',
                                   'notify_email',                                                                      
                                   ]
    end
  end

  describe ".values" do
    it "should collect the values" do
      Configurable.group1.values.should == ['notify_email']
    end
  end

  describe ".groups" do
    it "should collect the groupd" do
      Configurable.group1.groups.should == ['group2']
    end
  end  
  
  describe ".form_key" do
    context "parent is Configurable" do
      it "should return same key" do
        Configurable.group1.form_key('key').should == 'group1/key'
        Configurable.group1.value_key('key').should == Configurable.group1.form_key('key')
      end
    end
    
    context "parent is other group" do
      it "should return same key" do
        Configurable.group1.group2.form_key('key').should == 'group1/group2/key'
        Configurable.group1.group2.value_key('key').should == Configurable.group1.group2.form_key('key')
      end
    end
  end
  
  describe ".[]=" do
    context "with no saved value" do
      it "creates a new entry" do
        Configurable.group1[:notify_email] = "john@example.com"
        Configurable.find_by_name('group1/notify_email').value.should == 'john@example.com'
        Configurable.count.should == 1
      end
    end

    context "with a saved value" do
      before do
        Configurable.create!(:name => 'group1/notify_email', :value => 'paul@rslw.com')
      end

      it "updates the existing value" do
        Configurable.group1[:notify_email] = "john@example.com"
        Configurable.find_by_name('group1/notify_email').value.should == 'john@example.com'
        Configurable.count.should == 1
      end
    end
  end

  describe ".[]" do
    context "with no saved value" do
      it "shoud pick up the default value" do
        Configurable.group1[:notify_email].should == 'mreider@engineyard.com'
      end
    end

    context "with a saved value" do
      before do
        Configurable.create!(:name => 'group1/notify_email', :value => 'paul@rslw.com')
      end

      it "should find the new value" do
        Configurable.group1[:notify_email].should == 'paul@rslw.com'
      end
    end     
  end

  describe ".method_missing" do
    it "should raise an error if a key doesn't exist" do
      lambda { Configurable.group1.nonsense }.should raise_error(NoMethodError)
    end

    it "should return the correct value" do
      Configurable.group1.notify_email.should == 'mreider@engineyard.com'
    end

    it "should assign the correct value" do
      Configurable.group1.notify_email = 'john@example.com'
      Configurable.group1.notify_email.should == 'john@example.com'
    end
    
    it "should return group object" do
      Configurable.group1.group2.should be_a(ConfigurableGroup)
    end
  end

end
