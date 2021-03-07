class ApplicationController < ActionController::Base
# before_action :repo_object,
#               :contributor_objects,
#               :pull_objects

  def repo_object
    @repo ||= ApiService.repo_object
  end

  def contributor_objects
    @contributors ||= ApiService.contributor_objects
  end

  def pull_objects
    @pulls ||= ApiService.pull_objects
  end
end
