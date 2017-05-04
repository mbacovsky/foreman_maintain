require 'cgi'
module Procedures::ForemanTasks
  class UiInvestigate < ForemanMaintain::Procedure
    metadata do
      for_feature :foreman_tasks
      description 'investigate the tasks via UI'
      param :search_query
    end

    attr_reader :search_query

    def run
      ask(<<-MESSAGE.strip_heredoc)
        Go to https://#{hostname}/foreman_tasks/tasks?search=#{CGI.escape(@search_query.to_s)}
        press ENTER after the paused tasks are resolved.
      MESSAGE
    end
  end
end
