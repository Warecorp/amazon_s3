module AmazonS3
  class ConfigurationError < StandardError; end

  class Configuration

    class << self
      def get
        if @singleton.nil?
          @singleton = Configuration.new
          @singleton.load(@singleton.default_config_path)
        end
        @singleton
      end
    end



    def initialize
      @config = {
        :access_key_id      => nil,
        :secret_access_key  => nil,
        :bucket             => nil,
        :region             => nil,
        :endpoint          => nil,
        # :port              => nil,
        # :ssl               => nil,
        :private           => false,
        :expires           => nil,
        :secure            => false,
        # :proxy             => false,
        :attachments_folder => nil,
        :thumbnails_folder  => nil,
      }
    end

    def default_config_path
      File.join(Rails.root, 'config', 'amazon_s3.yml')
    end

    def load(path)
      file = ERB.new( File.read(path) ).result
      config = YAML::load( file )[Rails.env]

      if config.nil?
        raise ConfigurationError.new("No amazon_s3 configuration found for environment '#{Rails.env}'")
      end

      set(config)
    end

    def set(config)
      config.each do |key, value|
        if !@config.has_key? key.to_sym
          raise ConfigurationError.new("Unknown configuration option '#{key}'")
        end
        @config[key.to_sym] = value
      end
    end

    def access_key_id
      @config[:access_key_id]
    end

    def secret_access_key
      @config[:secret_access_key]
    end

    def bucket
      @config[:bucket]
    end

    def region
      @config[:region]
    end

    def endpoint
      @config[:endpoint]
    end

    # def port
      # @config[:port]
    # end

    # def ssl
      # @config[:ssl]
    # end

    def expires
      @config[:expires]
    end

    def private?
      @config[:private]
    end

    def secure?
      @config[:secure]
    end

    # def proxy?
      # @config[:proxy]
    # end

    def attachments_folder
      str = @config[:attachments_folder]
      if str.present?
        str.match(/\S+\//) ? str : "#{str}/"
      else
        ''
      end
    end

    def thumbnails_folder
      str = @config[:thumbnails_folder]
      if str.present?
        str.match(/\S+\//) ? str : "#{str}/"
      else
        'tmp/'
      end
    end
  end
end