require 'rest-client'
require 'json'
require 'rspec'

# start logging before each scenario post http://172.27.108.80:9091/start_logging?src_ip=172.22.221.55
# tear down after each scenario  delete http://172.27.108.80:9091/log?src_ip=172.22.221.55
#                               post http://172.27.108.80:9091/stop_logging?src_ip=172.22.221.55


module RLib
 class ProxyAgent
  include RSpec::Matchers

  attr_accessor :proxy_server_ip, :proxy_server_port, :device_ip

  #set the proxy server ip here or write your own function to load from config file
  def initialize(hash)
    puts "Initializing proxy agent"
    @proxy_server_ip = hash[:proxy_server_ip]
    @proxy_server_port = hash[:proxy_server_port]
    @device_ip = hash[:device_ip]
  end


  #gets status of logging for the agent
  #return: boolean
  def is_logging?
    begin
      return (RestClient.get "#{@proxy_server_ip}/logging?src_ip=#{@device_ip}").code == 200
    rescue
      return false
    end
  end

  def _proxy_url
    'http://'+@proxy_server_ip+':'+@proxy_server_port
  end


  #sets server to start logging for the agent
  #returns: None
  def start_logging
    begin
        puts "Trying to Start logging at #{_proxy_url} for device #{@device_ip}" if Calabash::Cucumber::Logging.full_console_logging?
        RestClient.post "#{_proxy_url}/start_logging?src_ip=#{@device_ip}", ''
        puts 'Success...!' if Calabash::Cucumber::Logging.full_console_logging?
        return true
    rescue
      return false
    end
  end


  #stops logging on the proxy server for the agent
  #returns: None
  def stop_logging
    begin
    	puts "Trying to Terminate logging at #{_proxy_url} for device #{@device_ip}" if Calabash::Cucumber::Logging.full_console_logging?
    	RestClient.post "#{_proxy_url}/stop_logging?src_ip=#{@device_ip}", ''
    	puts 'Success...!' if Calabash::Cucumber::Logging.full_console_logging?
        return true
    rescue
      return false
    end
  end


  #clears proxy server memory
  #returns: None
  def clear_server_mem(max_delete_retries=2)
    max_delete_retries.times do |n|
    	begin
      	    puts "Trying to Clear server memory at #{_proxy_url} for device #{@device_ip}..." if Calabash::Cucumber::Logging.full_console_logging?
            RestClient.delete ("#{_proxy_url}/log?src_ip=#{@device_ip}") { |response, request, result, &block|
            sleep 1
            case response.code
                when 200
                puts 'Success...!' if Calabash::Cucumber::Logging.full_console_logging?
                return response
            else
               puts "Failed to delete the logs on the proxy server. (attempt #{n+1})"
               if n==max_delete_retries-1
                   puts "Delete retry attempts exhausted.\nResponse: #{result.code} #{result.message}"
                   return false
               else
                   puts 'Retrying to delete after failure.'
               end
            end
            }
         rescue
            return false
         end
    end
  end


  #gets requests from the proxy server
  #returns: A list of URLs {url1, url2, ..., urlN}
  def get_all_request(max_get_retries = 2)
    max_get_retries.times do |n|
      begin
      RestClient.get ("#{_proxy_url}/log?src_ip=#{@device_ip}") { |response, request, result, &block|
        sleep 1
        case response.code
          when 200
            return response
          when 404
            if JSON.parse(response)['message'].start_with?('NO logs found for IP')
              return false
            end
          else
            puts "Failed to get the logs on the proxy server. (attempt #{n+1})"
            if n==max_get_retries-1
              puts "Get retry attempts exhausted.\nResponse: #{result.code} #{result.message}"
              return false
              #return response.return!(request, result, &block)
            else
              puts 'Retrying to get after failure.'
            end
        end
      }
      rescue
        return false
      end
    end
  end

 end
end