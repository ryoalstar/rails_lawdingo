require 'spec_helper'

describe PracticeArea do
  
  context "associations" do
    it "should provide an association to find its children" do
    
      proxy = PracticeArea.reflect_on_association(:children)

      proxy.macro.should be :has_many
      proxy.options[:foreign_key].should eql :parent_id
      proxy.options[:class_name].should eql "PracticeArea"
      
      lambda{PracticeArea.new.children}.should_not raise_error
    end
  end

  context "scopes" do

    it "should provide a scope for practice areas with approved lawyers" do
      scope = PracticeArea.with_approved_lawyers
      scope.joins_values.should eql([:lawyers])
      scope.group_values.should eql(["#{PracticeArea.table_name}.id"])
      scope.where_values.should eql(["#{Lawyer.table_name}.is_approved = 1"])
    end

    it "should provide a scope for practice areas with names like x" do
      scope = PracticeArea.name_like("My-Dasherized-name")
      scope.where_values.should eql(["name LIKE 'My Dasherized name'"])
    end

  end

end