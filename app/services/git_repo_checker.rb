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
    
    # Just check if repo exists by trying to get repository info
    github_service.get_repository_info(owner, repo)
    
    # Get languages to check if repo exists and has files (excluding txt & zip)
    # languages = github_service.get_repository_languages(owner, repo)
    
    # If languages hash is empty, repo might only have txt/zip files or be empty
    # We'll consider it invalid if it has no code files
    # return false if languages.empty?
    
    # Repo exists
    true
  rescue ArgumentError => e
    # API key missing, fall back to git ls-remote
    Rails.logger.warn "GitHub proxy API key missing, falling back to git ls-remote for #{owner}/#{repo}"
    github_url = "https://github.com/#{owner}/#{repo}"
    check_with_git_remote(github_url)
  rescue GithubProxyService::GithubProxyError => e
    Rails.logger.error "GitHub proxy error for #{owner}/#{repo}: #{e.message}"
    false
  end

  def check_with_git_remote(url)
    # Use Open3 for safer process execution with proper resource limits
    require 'open3'
    require 'timeout'
    
    # Validate URL format to prevent command injection
    return false unless valid_git_url?(url)
    
    begin
      Timeout::timeout(3) do
        # Use Open3.capture3 for safer execution
        stdout, stderr, status = Open3.capture3(
          'git', 'ls-remote', '--tags', url,
          stdin_data: '',
          binmode: true
        )
        
        # Check if command succeeded
        status.success?
      end
    rescue Timeout::Error
      Rails.logger.warn "Git ls-remote timeout for #{url}"
      false
    rescue => e
      Rails.logger.error "Git ls-remote error for #{url}: #{e.message}"
      false
    end
  end
  
  def valid_git_url?(url)
    # Basic validation to ensure it's a reasonable git URL
    # Prevents command injection attempts
    return false if url.blank?
    return false if url.include?('`') || url.include?(';') || url.include?('|')
    return false if url.include?('$(') || url.include?('&&')
    
    # Must be http/https or git protocol
    url.match?(/\A(https?|git):\/\/[\w\-\.]+/)
  end
end
