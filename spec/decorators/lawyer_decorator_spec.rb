require 'spec_helper' 

describe LawyerDecorator do
  
  subject do
    LawyerDecorator.new(lawyer)
  end

  let(:lawyer) do
    FactoryGirl.build_stubbed(:lawyer)
  end

  context "#licensed_states" do

    it "should give back a string of the states in which the Lawyer
      is licensed" do

      lawyer.stubs(
        :states => [
          State.new(:abbreviation => "AB"),
          State.new(:abbreviation => "CD"),
          State.new(:abbreviation => "EF")
        ]
      )

      subject.licensed_states.should eql("AB, CD, and EF")

    end

  end

  context "#long_personal_tagline" do

    it "should be just the characters if there are less than
      600" do

      lawyer.stubs(:personal_tagline => "abc " * 130)
      subject.long_personal_tagline.should eql(
        "&quot;#{'abc ' * 130}&quot;"
      )

    end


  end

  context "#photo" do

    it "should be a link to the Lawyer's Photo" do
      subject.photo.should =~ /<a.*<img/
    end

  end

  context "#photo_url" do

    it "should proxy the call to the lawyer's photo object" do

      lawyer.photo.expects(:url).with(:medium)

      subject.photo_url(:medium)

    end

  end

  context "#practice_area_names" do

    it "should be a sentence of the names" do
      lawyer.stubs(:parent_practice_areas => [
          PracticeArea.new(:name => "A"),
          PracticeArea.new(:name => "B"),
          PracticeArea.new(:name => "C")
        ]
      )
      subject.practice_area_names.should eql(
        "a, b, and c"
      )
    end

  end

  context "#short_personal_tagline" do

    it "should be just the characters if there are less than
      120" do

      lawyer.stubs(:personal_tagline => "abc " * 20)
      subject.short_personal_tagline.should eql(
        "&quot;#{'abc ' * 20}&quot;"
      )

    end


  end

end