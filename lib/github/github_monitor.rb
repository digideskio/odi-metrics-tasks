require 'github_api'

class GithubMonitor
  @queue = :metrics
  
  def self.perform
    # Connect
    github = Github.new login: ENV['GITHUB_USER'], password: ENV['GITHUB_PASSWORD'], user: ENV['GITHUB_ORGANISATION']
    # Get github organisation
    org = github.orgs.find(ENV['GITHUB_ORGANISATION'])
    # Public repos into leftronic
    Resqueue.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_REPOS'], org.public_repos
    # Count up stats across all repositories
    issues = 0
    watchers = 0
    forks = 0
    open_pull_requests = 0
    pull_requests = 0
    github.repos.list(user: ENV['GITHUB_ORGANISATION']) do |repo|
      issues += repo.open_issues_count
      watchers += repo.watchers_count
      forks += repo.forks_count
      issues = github.issues.list(user: ENV['GITHUB_ORGANISATION'], repo: repo.name)
      open_pull_requests += issues.select{|x| x["state"] == "open" && x["pull_request"] && x["pull_request"]["html_url"]}.count
      # Tot up open and closed pull requests for the total count
      pull_requests += issues.select{|x| x["pull_request"] && x["pull_request"]["html_url"]}.count
    end
    # Push into leftronic
    Resqueue.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_ISSUES'], issues
    Resqueue.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_WATCHERS'], watchers
    Resqueue.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_FORKS'], forks
    Resqueue.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_OPENPRS'], open_pull_requests
    Resqueue.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_PULLS'], pull_requests
  rescue Github::Error::ServiceError, Github::Error::Forbidden
    nil
  end
  
end