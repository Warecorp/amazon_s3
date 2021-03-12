require 'aws-sdk-s3'

module AmazonS3
  class Connection
    @@client = nil
    @@config = Configuration.get

    class << self

      def establish_connection
        options = {
          :access_key_id => @@config.access_key_id,
          :secret_access_key => @@config.secret_access_key,
          :region => @@config.region
        }
        options[:s3_endpoint] = @@config.endpoint unless @@config.endpoint.nil?
        # options[:s3_port] = @@config.port unless @@config.port.nil?
        # options[:use_ssl] = @@config.ssl unless @@config.ssl.nil?

        @client = Aws::S3::Client.new(options)
      end

      def client
        @@client || establish_connection
      end

      def bucket
        resource = Aws::S3::Resource.new(client: self.client)
        resource.bucket(@@config.bucket)
      end

      def object(filename, target_folder = @@config.attachments_folder)
        bucket.object(target_folder + filename)
      end

      def put(disk_filename, original_filename, data, content_type='application/octet-stream', target_folder = @@config.attachments_folder)
        object = self.object(disk_filename, target_folder)
        options = {}
        options[:content_type] = content_type if content_type
        options[:content_disposition] = "inline; filename=#{ERB::Util.url_encode(original_filename)}"
        options[:body] = data
        # options[:acl] = 'private'
        options[:acl] = :public_read unless @@config.private?
        # object.put(options)
        object.write(data, options)
      end

      def delete(filename, target_folder = @@config.attachments_folder)
        object = self.object(filename, target_folder)
        object.delete
      end

      def object_url(filename, target_folder = @@config.attachments_folder)
        object = self.object(filename, target_folder)
        if self.private?
          options = {:secure => @@config.secure?}
          options[:expires] = @@config.expires unless @@config.expires.nil?
          object.url_for(:read, options).to_s
        else
          object.public_url(:secure => @@config.secure?).to_s
        end
        # object.presigned_url(:get, expires_in: 600)
      end

      def get(filename, target_folder = @@config.attachments_folder)
        object = self.object(filename, target_folder)
        object.get.body.read
      end
    end
  end
end
