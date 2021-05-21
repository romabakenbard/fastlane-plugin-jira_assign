describe Fastlane::Actions::JiraAssignAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The jira_assign plugin is working!")

      Fastlane::Actions::JiraAssignAction.run(nil)
    end
  end
end
