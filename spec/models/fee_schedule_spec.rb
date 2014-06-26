require 'spec_helper'

describe FeeSchedule do
  fixtures :people

  describe "charge_today?" do

    before :each do
      @person = people :quentin
    end

    describe "monthly fees" do

      before :each do
        @person.plan_started_at = Date.new(2014, 6, 15)
      end

      it "should apply monthly fees on the same day each month" do
        today = Date.new(2014, 7, 15)
        schedule = FeeSchedule.new(@person)
        schedule.charge_today?('month', today).should be_true
      end

      it "should not apply monthly fees if the day of month is different" do
        today = Date.new(2014, 7, 14)
        schedule = FeeSchedule.new(@person)
        schedule.charge_today?('month', today).should be_false
      end

      describe "edge cases" do

        before :each do
          @person.plan_started_at = Date.new(2014, 7, 31)
        end

        it "should charge fees initiated after the 28th on the 28th" do
          today = Date.new(2014, 8, 28)
          schedule = FeeSchedule.new(@person)
          schedule.charge_today?('month', today).should be_true
        end

        it "should not charge fees initiated after the 28th on that day" do
          today = Date.new(2014, 8, 31)
          schedule = FeeSchedule.new(@person)
          schedule.charge_today?('month', today).should be_false
        end
      end


    end


    describe "yearly fees" do

      before :each do
        @person.plan_started_at = Date.new(2013, 1, 15)
      end

      it "should apply yearly fees on the same day each year" do
        today = Date.new(2014, 1, 15)
        schedule = FeeSchedule.new(@person)
        schedule.charge_today?('year', today).should be_true
      end

      it "should not apply yearly fees if the day of year is different" do
        today = Date.new(2014, 1, 14)
        schedule = FeeSchedule.new(@person)
        schedule.charge_today?('year', today).should be_false
      end

      describe "edge cases" do

        before :each do
          @person.plan_started_at = Date.new(2012, 12, 31)
        end

        it "should charge fees initiated on the 366th day of the year on the 365th" do
          today = Date.new(2014, 12, 31)
          schedule = FeeSchedule.new(@person)
          schedule.charge_today?('year', today).should be_true
        end

        it "should not charge fees initiated on the 366th day of the year on the 366th day" do
          today = Date.new(2016, 12, 31)
          schedule = FeeSchedule.new(@person)
          schedule.charge_today?('year', today).should be_false
        end
      end
    end


  end

end