require 'find'
require 'thread'
require 'aws-sdk-s3'
require 'mimemagic'

module Jekyll
  module Deploy
    module Spaces
      UnreadableFileError = Class.new(RuntimeError)

      class Syncer
        def initialize(local_path, spaces_config)
          @local_path = local_path
          @remote_space = spaces_config.space
          @client = Aws::S3::Client.new(
            region: spaces_config.region,
            endpoint: spaces_config.endpoint,
            credentials: Aws::Credentials.new(spaces_config.key, spaces_config.secret)

          )
        end

        def sync(num_threads: 5)
          local_files = find_local_files
          remote_files = find_remote_files

          actions = Queue.new

          local_files.each do |local_file, local_data|
            remote_data = remote_files[local_file]

            actions << if remote_data.nil? ||
                          !remote_data[:mtime].eql?(local_data[:mtime]) ||
                          remote_data[:size] != local_data[:size]
                         { file: local_file, action: :upload }
                       else
                         { file: local_file, action: :unchanged }
                       end

            remote_files.delete(local_file)
          end

          remote_files.each do |remote_file, _|
            actions << { file: remote_file, action: :delete }
          end

          threads = []
          mutex = Mutex.new
          num_threads.times do
            threads << Thread.new do
              until actions.empty?
                action = actions.pop

                case action[:action]
                when :upload
                  local_file_path = "#{@local_path}/#{action[:file]}"
                  @client.put_object(
                    acl: 'public-read',
                    body: File.open(local_file_path),
                    bucket: @remote_space,
                    key: action[:file],
                    content_type: MimeMagic.by_path(local_file_path).type
                  )
                  mtime = @client.get_object(
                    bucket: @remote_space,
                    key: action[:file]
                  ).last_modified.utc
                  FileUtils.touch "#{@local_path}/#{action[:file]}", mtime: mtime
                when :delete
                  @client.delete_object(
                    bucket: @remote_space,
                    key: action[:file]
                  )
                end

                mutex.synchronize do
                  yield action
                end
              end
            end
          end
          threads.each { |t| t.join }
        end

        def find_local_files
          local_files = {}

          Find.find(@local_path).each do |path|
            st = File.stat path
            raise UnreadableFileError.new(path) unless st.readable?

            next unless st.file?

            file = path.gsub(/^#{@local_path}\/?/, '').squeeze('/')

            local_files[file] = {
              size: st.size,
              mtime: st.mtime.utc
            }
          end

          local_files
        end

        def find_remote_files
          remote_files = {}

          @client.list_objects(bucket: @remote_space).each do |resp|
            resp.contents.each do |file|
              remote_files[file.key] = {
                size: file.size,
                mtime: file.last_modified.utc
              }
            end
          end

          remote_files
        end
      end
    end
  end
end
