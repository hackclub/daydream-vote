class GitRepoChecker
  def self.accessible?(url)
    new.accessible?(url)
  end

  def accessible?(url)
    return false if url.blank?
    
    # Try GitHub proxy for github.com repos first (faster)
    github_info = extract_github_info(url)
    if github_info
      return check_github_repo(github_info[:owner], github_info[:repo])
    end
    
    # Fallback to git ls-remote for non-GitHub repos
    check_with_git_remote(url)
  rescue => e
    Rails.logger.error "GitRepoChecker error for #{url}: #{e.message}"
    false
  end

  private

  def extract_github_info(url)
    # Match github.com/USER/REPO format
    match = url.match(%r{github\.com[/:]([^/]+)/([^/]+?)(?:\.git)?/?$})
    return nil unless match
    
    { owner: match[1], repo: match[2] }
  end

  def check_github_repo(owner, repo)
    github_service = GithubProxyService.new
    
    # Get repository info to check if it exists
    repo_info = github_service.get_repository_info(owner, repo)
    
    # Get languages to check if repo has files (excluding txt & zip)
    languages = github_service.get_repository_languages(owner, repo)
    
    # If languages hash is empty, repo might only have txt/zip files or be empty
    # We'll consider it invalid if it has no code files
    return false if languages.empty?
    
    # Repo exists and has code files
    true
  rescue GithubProxyService::GithubProxyError => e
    Rails.logger.error "GitHub proxy error for #{owner}/#{repo}: #{e.message}"
    false
  end

  def check_with_git_remote(url)
    # Run git ls-remote with reduced timeout (3 seconds)
    result = system("timeout 3 git ls-remote #{url.shellescape} HEAD > /dev/null 2>&1")
    
    # system returns true if command succeeded (exit status 0)
    result
  end
end
