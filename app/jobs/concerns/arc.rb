require 'arc-client'

module Arc
  extend ActiveSupport::Concern

  class AgentsNotFoundException < StandardError
    def to_s
      'No nodes found.'
    end
  end

  def arc
    @arc ||= ArcClient::Client.new(current_user.service_url(:arc))
  end


  def select_agents(selector)
    selected_agents = list_agents(selector)
    raise AgentsNotFoundException if selected_agents.empty?
    #@run.log "Selected nodes:\n" + 
    #         selected_agents.map {|a| "#{a.agent_id} #{a.facts["hostname"]}"}.join("\n") + 
    #         "\n"

    offline_agents = selected_agents.find_all { |a|!a.facts["online"] }
    if offline_agents.present?
      #@run.log "The following nodes are not online:\n" + 
      #         offline_agents.map {|a| "#{a.agent_id} #{a.facts["hostname"]}"}.join("\n") +
      #         "\n"
      raise "#{offline_agents.length} #{"node".pluralize(offline_agents.length)} unavailable:" +
             offline_agents.map {|a| "#{a.agent_id} #{a.facts["hostname"]}"}.join("\n") +
             "\n"
    end
    selected_agents
  end

  def schedule_jobs(nodes, agent, action, timeout, payload={})
    nodes.map do |node|
      #TODO: handle individual errors
      arc.execute_job!(current_user.token, {
        to: node.agent_id,
        timeout: timeout,
        agent: agent,
        action: action,
        payload: payload.instance_of?(String) ? payload : payload.to_json
      })
    end
  end

  def list_agents(filter, facts = %w{online hostname agents})
    page = 1 
    agents = []
    loop do
      resp = arc.list_agents!(current_user.token, filter, facts, page, 100)
      agents.concat(resp.data)
      break if page >= resp.pagination.total_pages
      page += 1
    end
    return agents
  end
end
