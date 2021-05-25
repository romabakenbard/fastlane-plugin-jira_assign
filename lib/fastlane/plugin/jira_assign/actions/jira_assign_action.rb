require 'fastlane/action'
require_relative '../helper/jira_assign_helper'

module Fastlane
  module Actions
    class JiraAssignAction < Action
      def self.run(params)
        Actions.verify_gem!('jira-ruby')
        require 'jira-ruby'

        site         = params[:url]
        auth_type    = :basic
        context_path = params[:context_path]
        username     = params[:username]
        password     = params[:password]
        ticket_id    = params[:ticket_id]
        status       = params[:status]
        assignee     = params[:assignee]
        comment_text = params[:comment_text]
        
        options = {
                    site: site,
                    context_path: context_path,
                    auth_type: auth_type,
                    username: username,
                    password: password
                  }

        begin
          client = JIRA::Client.new(options)
          issue = client.Issue.find(ticket_id)

          current_status_name = issue.status.name
          current_status_id = 0

          available_transitions = client.Transition.all(:issue => issue)
          for ea in available_transitions do
            if ea.name == current_status_name
              current_status_id = ea.id
            end
          end

          if current_status_id != status
            transition = issue.transitions.build
            transition.save("transition" => {"id" => status})

            satus_json_response = transition.attrs
            raise 'Failed to move status for Jira ticket' if satus_json_response.nil?
            UI.success('Successfully moved status Jira ticket')

            issue.save({'fields' => {'assignee' => {'id' => assignee}}})
            assignee_json_response = issue.attrs
            raise 'Failed to move assignee for Jira ticket' if assignee_json_response.nil?
            UI.success('Successfully moved assignee Jira ticket')
          else
            UI.success('Jira ticket already in desired status')
          end

          if comment_text.to_s.length > 0
            comment = issue.comments.build
            comment.save({ 'body' => comment_text })

            comment_json_response = comment.attrs
            raise 'Failed to add a comment on Jira ticket' if comment_json_response.nil?
            UI.success('Successfully added a comment on Jira ticket')
          end
          
          return 1
        rescue => exception
          message = "Received exception: #{exception}"
          if params[:fail_on_error]
            UI.user_error!(message)
          else
            UI.error(message)
          end
        end


      end

      def self.description
        "Simple plugin to change jira issue asign and move to status"
      end

      def self.authors
        ["Roma Bakenbard"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Simple plugin to change jira issue asign and move to status"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :url,
                                      env_name: "FL_JIRA_SITE",
                                      description: "URL for Jira instance",
                                       verify_block: proc do |value|
                                         UI.user_error!("No url for Jira given, pass using `url: 'url'`") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :context_path,
                                      env_name: "FL_JIRA_CONTEXT_PATH",
                                      description: "Appends to the url (ex: \"/jira\")",
                                      optional: true,
                                      default_value: ""),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "FL_JIRA_USERNAME",
                                       description: "Username for Jira instance",
                                       verify_block: proc do |value|
                                         UI.user_error!("No username") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "FL_JIRA_PASSWORD",
                                       description: "Password or API token for Jira",
                                       sensitive: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No password") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :ticket_id,
                                       env_name: "FL_JIRA_TICKET_ID",
                                       description: "Ticket ID for Jira, i.e. IOS-123",
                                       verify_block: proc do |value|
                                         UI.user_error!("No Ticket specified") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :status,
                                       env_name: "FL_JIRA_STATUS_ID",
                                       description: "Id of desired status",
                                       verify_block: proc do |value|
                                         UI.user_error!("No status specified") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :assignee,
                                       env_name: "FL_JIRA_ASSIGNEE_NAME",
                                       description: "Name of user to assignee",
                                       verify_block: proc do |value|
                                         UI.user_error!("No assignee user specified") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :comment_text,
                                       env_name: "FL_JIRA_COMMENT_TEXT",
                                       description: "Text to add to the ticket as a comment",
                                       optional: true,
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :fail_on_error,
                                       env_name: "FL_JIRA_FAIL_ON_ERROR",
                                       description: "Should an error adding the Jira comment cause a failure?",
                                       type: Boolean,
                                       optional: true,
                                       default_value: true) # Default value is true for 'Backward compatibility'
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
