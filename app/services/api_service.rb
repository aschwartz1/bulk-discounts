require 'repo'
require 'contributor'
require 'pull'
require 'commit'

class ApiService

  require "pry"; binding.pry
  def self.get_info(uri)
    response = Faraday.get("https://api.github.com/repos/avjohnston/little-esty-shop#{uri}")
    parsed = JSON.parse(response.body, symbolize_names: true)
  end

  def self.repo
    get_info('')[:name]
  end

  def self.repo_object
    if repo.nil?
      'API Limit Exceeded: Repository Info Not Available'
    else
      Repo.new(repo).name
    end
  end

  def self.contributors
    get_info('/contributors')
  end

  def self.contributor_objects
    if contributors.is_a?(Hash)
      'API Limit Exceeded: Contributor Info Not Available'
    else
      collaborators = [contributors[0], contributors[1], contributors[3], contributors[4]]
      people = collaborators.map do |data|
        Contributor.new(data)
      end
      people.map do |people|
        "#{people.user_name} - #{commit_objects(people.user_name)} Commits\n"
      end.to_sentence
    end
  end

  def self.pulls
    get_info('/pulls?state=all')
  end

  def self.pull_objects
    if pulls.is_a?(Hash)
      'API Limit Exceeded: Pull Request Info Not Available'
    else
      pulls.map do |data|
        Pull.new(data)
      end.size
    end
  end

  def self.commits(user_name)
    get_info("/commits?author=#{user_name}")
  end

  def self.commit_objects(user_name)
    commits(user_name).map do |data|
      Commit.new(data)
    end.size
  end
end
