config = YAML::load(File.open(ENV["TM_BUNDLE_SUPPORT"] + "/config/config.yml").read)

# Store some defaults, we're assuming english is the default locale, you can change that below
DEFAULT_LOCALE_FILE = File.join(ENV['TM_PROJECT_DIRECTORY'], config['default_locale'])

MYGENGO_API_KEY = config['mygengo']['api_key']
MYGENGO_PRIVATE_KEY = config['mygengo']['private_key']
