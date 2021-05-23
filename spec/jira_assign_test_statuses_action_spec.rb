describe Fastlane::Actions::JiraAssignTestStatusesAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The jira_assign_test_statuses plugin is working!")

      Fastlane::Actions::JiraAssignTestStatusesAction.run(nil)
    end
  end
end