module Jekyll
  class GitInfoGenerator < Generator
    safe true
    priority :high

    def generate(site)
      begin
        # Get the Git SHA
        git_sha = `git rev-parse HEAD`.strip
        git_short_sha = git_sha[0..6]
        
        # Get the repository URL
        git_remote = `git remote get-url origin`.strip
        
        # Remove .git extension if present
        git_remote = git_remote.sub(/\.git$/, '')
        
        # Store in site data
        site.data['git'] ||= {}
        site.data['git']['sha'] = git_sha
        site.data['git']['short_sha'] = git_short_sha
        site.data['git']['remote_url'] = git_remote
        
        # Also store as site variables for easier access
        site.config['git_sha'] = git_sha
        site.config['git_short_sha'] = git_short_sha
        site.config['git_remote_url'] = git_remote
        
      rescue => e
        Jekyll.logger.warn "Git Info:", "Could not get git information: #{e.message}"
        # Fallback values
        site.data['git'] ||= {}
        site.data['git']['sha'] = 'unknown'
        site.data['git']['short_sha'] = 'unknown'
        site.data['git']['remote_url'] = 'https://github.com/bndtools/bndtools.p2.repo'
      end
    end
  end
end