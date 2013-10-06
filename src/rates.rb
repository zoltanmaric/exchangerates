require 'yaml'
require 'log4r'
require 'log4r/yamlconfigurator'

APP_ROOT = File.dirname(__FILE__)
$:.unshift(File.join(APP_ROOT, '.'))
$:.unshift(File.join(APP_ROOT, 'modules'))

Log4r::YamlConfigurator.load_yaml_file('log4r.yml')
require 'ui'

props = YAML.load_file('keys.yml')
UI.start_app(props['app_id'], props['db_pass'])
