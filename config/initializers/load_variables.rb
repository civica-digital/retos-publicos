env = YAML.load_file("#{Rails.root}/config/environment_variables.yml")[Rails.env]
GITHUB_KEY = ENV['GITHUB_KEY'] || env['github']['key']
GITHUB_SECRET = ENV['GITHUB_SECRET'] || env['github']['secret']

LINKEDIN_KEY = ENV['LINKEDIN_KEY'] || env['linkedin']['key']
LINKEDIN_SECRET = ENV['LINKEDIN_SECRET'] || env['linkedin']['secret']

TWITTER_KEY = ENV['TWITTER_KEY'] || env['twitter']['key']
TWITTER_SECRET = ENV['TWITTER_SECRET'] || env['twitter']['secret']

CKAN_API_KEY = ENV['CKAN_API_KEY'] || env['ckan']['key']
