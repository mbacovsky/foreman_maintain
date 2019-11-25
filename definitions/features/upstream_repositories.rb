require "net/http"

class Features::UpstreamRepositories < ForemanMaintain::Feature
  metadata do
    label :upstream_repositories

    confine do
      !feature(:instance).downstream?
    end
  end

  VERSION_MAPPING = {
    '3.14' => '1.24',
    '3.13' => '1.23'
  }

  def setup_repositories(version)
    if feature(:katello)
      feature(:package_manager).update(katello_repos(version))
      version = VERSION_MAPPING[version]
    end
    feature(:package_manager).upgrade_foreman_repos(version)
    feature(:package_manager).clean_cache
  end

  def katello_repos(version)
    "https://fedorapeople.org/groups/katello/releases/yum/#{version}/katello/el7/x86_64/katello-repos-latest.rpm"
  end

  def available?(version)
    if feature(:katello)
      link_valid?(katello_repos(version))
      version = VERSION_MAPPING[version]
    end
    feature(:package_manager).foreman_repos_valid?(version)
  end

  private

  def link_valid?(link)
    url = URI.parse(link)
    req = Net::HTTP.new(url.host, url.port)
    req.use_ssl = true
    res = req.request_head(url.path)
    res.code == '200'
  end
end
