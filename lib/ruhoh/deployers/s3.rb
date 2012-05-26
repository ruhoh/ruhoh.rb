require 'aws/s3'

class Ruhoh
  
  module Deployers
    
    # Deploy to Amazon S3
    # See http://amazon.rubyforge.org/ for usage.
    class AmazonS3 < AWS::S3::S3Object
  
      def initialize
        credentials = Ruhoh::Utils.parse_yaml_file(Ruhoh.paths.base, "_deploy.yml")['s3']
        self.connect(credentials)
        self.ensure_bucket(credentials["bucket"])
        #set_current_bucket_to(credentials["bucket"])
        @bucket = credentials["bucket"]
      end
  
      def connect(credentials)
        AWS::S3::Base.establish_connection!({
          :access_key_id      => credentials["access_key_id"],
          :secret_access_key  => credentials["secret_access_key"]
        })
      end

      def deploy(compiled_directory)
        FileUtils.cd(compiled_directory) {
          Dir.glob("**/**") do |filepath|
            next if FileTest.directory?(file)
            self.store(filepath)
          end
        }
      end
      
      def ensure_bucket(bucket)
        AWS::S3::Bucket.find(bucket)
      rescue
        Ruhoh::Friend.say { 
          yellow "'#{@bucket}' bucket not found, trying to create..."
        }
        AWS::S3::Bucket.create(bucket, :access => :public_read)

        if AWS::S3::Service.response.success?
          Ruhoh::Friend.say { green "Bucket created!" }
        else
          Ruhoh::Friend.say { 
            red "Bucket creation failed!"
            plain "Perhaps you will need to manually create the bucket."
          }
          exit
        end
      end
      
      # save/update a file to s3
      def store(filepath)
        File.open(filepath) do |file|
          AWS::S3::S3Object.store(filepath, file, @bucket, :access => :public_read)
        end

        if AWS::S3::Service.response.success?
          Ruhoh::Friend.say { green "#{filepath}: success!" }
        else
          Ruhoh::Friend.say { green "#{filepath}: failure!" }
        end
      end
    
    end #S3
    
  end #Deployers
  
end #Ruhoh