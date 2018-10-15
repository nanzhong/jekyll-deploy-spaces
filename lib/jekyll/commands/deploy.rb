require 'yaml'
require 'jekyll'

module Jekyll
  module Commands
    class Deploy < Command
      class << self
        def init_with_program(prog)
          prog.command(:deploy) do |c|
            c.syntax 'build [options] TARGET'
            c.description 'Deploy to DigitalOcean Spaces'

            c.option 'deploy_config', '--deploy_config', 'Deploy configuration file'
            c.option 'destination', '-d', '--destination DESTINATION', 'The directory where the site is built'
            c.option 'quiet', '-q', '--quiet', 'Silence output.'
            c.option 'verbose', '-V', '--verbose', 'Print verbose output.'

            c.action do |args, options|
              self.apply_default_options(options)
              self.process(args, options)
            end
          end
        end

        def apply_default_options(options)
          options['deploy_config'] ||= '.deploy.yml'
        end

        def process(args, options)
          raise 'Must specify the TARGET to deploy to!' if args.length < 1
          deploy_target = args.first

          config = configuration_from_options(options)

          Jekyll.logger.debug 'Parsing deploy config...'
          deploy_config = "#{config['source']}/#{options['deploy_config']}"
          raise "Could not read deploy config, #{deploy_config} does not exist!" unless File.exists?(deploy_config)
          deploy_config = YAML.load_file(deploy_config)
          raise "#{deploy_target} is not configured for deployment" if deploy_config[deploy_target].nil?
          deploy_config = deploy_config[deploy_target]

          spaces_config = Jekyll::Deploy::Spaces::Config.new(
            space: deploy_config['space'],
            key: deploy_config['key'],
            secret: deploy_config['secret'],
            endpoint: deploy_config['endpoint'],
            region: deploy_config['region']
          )

          syncer = Jekyll::Deploy::Spaces::Syncer.new(config['destination'], spaces_config)

          Jekyll.logger.info "Starting deploy to #{deploy_target}..."

          syncer.sync do |action|
            case action[:action]
            when :unchanged
              Jekyll.logger.info "[SAME] #{action[:file]}: skipped"
            when :upload
              Jekyll.logger.info "[NEW]  #{action[:file]}: uploaded"
            when :delete
              Jekyll.logger.info "[GONE] #{action[:file]}: deleted"
            end
          end

          Jekyll.logger.info "Finished deploy to #{deploy_target}!"
        end
      end
    end
  end
end
