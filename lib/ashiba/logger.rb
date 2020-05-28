require 'logger'

$logger = Logger.new(STDOUT)
$logger.level = Logger::WARN
$logger.info('Starting Ashiba')
