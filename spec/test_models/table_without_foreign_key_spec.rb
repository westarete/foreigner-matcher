require 'spec_helper'

describe TableWithoutForeignKey do
  describe 'messages' do
    let(:matcher) { have_foreign_key_for(:users) }

    it "should contain a description" do
      matcher.description.should == "have a foreign key for users"
    end

    it "should set failure_message_for_should message" do
      matcher.matches?(subject)
      matcher.failure_message_for_should.should == "expected  to include #{Foreigner::ConnectionAdapters::ForeignKeyDefinition.new('table_without_foreign_keys', 'users', :primary_key => 'id', :column => 'user_id', :name => 'table_without_foreign_keys_user_id_fk')}"
    end

    it "should set failure_message_for_should_not message" do
      matcher.matches?(subject)
      matcher.failure_message_for_should_not.should == "expected  to exclude #{Foreigner::ConnectionAdapters::ForeignKeyDefinition.new('table_without_foreign_keys', 'users', :primary_key => 'id', :column => 'user_id', :name => 'table_without_foreign_keys_user_id_fk')}"
    end
  end

  describe 'matcher' do
    it { should_not have_foreign_key_for(:user) }
    it { should_not have_foreign_key_for(:users) }
  end
end