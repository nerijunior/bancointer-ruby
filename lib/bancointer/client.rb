# frozen_string_literal: true

require "faraday"
require "faraday/multipart"
require "openssl"
require "json"

module Bancointer
  class Client
    class AuthenticationError < Error; end
    class ConfigurationError < Error; end

    SANDBOX_BASE_URL = "https://cdpj-sandbox.partners.uatinter.co"
    PRODUCTION_BASE_URL = "https://cdpj.partners.bancointer.com.br"

    TOKEN_ENDPOINT = "/oauth/v2/token"

    attr_reader :client_id, :client_secret, :cert_path, :key_path, :environment,
                :access_token, :token_expires_at, :scopes

    def initialize(options = {})
      @client_id = options[:client_id] || raise(ConfigurationError, "client_id is required")
      @client_secret = options[:client_secret] || raise(ConfigurationError, "client_secret is required")
      @cert_path = options[:cert_path] || raise(ConfigurationError, "cert_path is required")
      @key_path = options[:key_path] || raise(ConfigurationError, "key_path is required")
      @ca_cert_path = options[:ca_cert_path]
      @environment = options[:environment] || :sandbox
      @scopes = options[:scopes] || []

      validate_certificates!
      setup_connection
    end

    def authenticate!(scopes = nil)
      request_scopes = scopes || @scopes
      raise ConfigurationError, "No scopes provided" if request_scopes.empty?

      response = @connection.post(TOKEN_ENDPOINT) do |req|
        req.headers["Content-Type"] = "application/x-www-form-urlencoded"
        req.body = URI.encode_www_form({
                                         client_id: @client_id,
                                         client_secret: @client_secret,
                                         grant_type: "client_credentials",
                                         scope: Array(request_scopes).join(" ")
                                       })
      end

      handle_token_response(response)
    end

    def authenticated?
      @access_token && !token_expired?
    end

    def token_expired?
      return true unless @token_expires_at

      Time.now >= @token_expires_at
    end

    def request(method, path, params = {}, headers = {})
      authenticate! unless authenticated?

      @connection.public_send(method, path) do |req|
        req.headers.merge!(headers)
        req.headers["Authorization"] = "Bearer #{@access_token}"

        case method
        when :get, :delete
          req.params = params
        when :post, :put, :patch
          req.headers["Content-Type"] = "application/json"
          req.body = params.to_json
        end
      end
    end

    private

    def base_url
      case @environment
      when :sandbox
        SANDBOX_BASE_URL
      when :production
        PRODUCTION_BASE_URL
      else
        raise ConfigurationError, "Invalid environment: #{@environment}"
      end
    end

    def validate_certificates!
      raise ConfigurationError, "Certificate file not found: #{@cert_path}" unless File.exist?(@cert_path)

      raise ConfigurationError, "Key file not found: #{@key_path}" unless File.exist?(@key_path)

      return unless @ca_cert_path && !File.exist?(@ca_cert_path)

      raise ConfigurationError, "CA certificate file not found: #{@ca_cert_path}"
    end

    def setup_connection
      @connection = Faraday.new(url: base_url) do |conn|
        # Configure SSL with mTLS
        conn.ssl.client_cert = OpenSSL::X509::Certificate.new(File.read(@cert_path))
        conn.ssl.client_key = OpenSSL::PKey::RSA.new(File.read(@key_path))

        conn.ssl.ca_file = @ca_cert_path if @ca_cert_path

        # Verify SSL certificates
        conn.ssl.verify = true
        conn.ssl.verify_mode = OpenSSL::SSL::VERIFY_PEER

        conn.request :multipart
        conn.response :json
        conn.adapter Faraday.default_adapter
      end
    end

    def handle_token_response(response)
      case response.status
      when 200
        data = response.body
        @access_token = data["access_token"]
        @token_expires_at = Time.now + data["expires_in"]
        @scopes = data["scope"]&.split(" ") || @scopes

        @access_token
      when 400
        raise AuthenticationError, "Invalid request: #{response.body}"
      when 403
        raise AuthenticationError, "Forbidden: #{response.body}"
      when 404
        raise AuthenticationError, "Token endpoint not found"
      when 503
        raise AuthenticationError, "Service unavailable"
      else
        raise AuthenticationError, "Authentication failed with status #{response.status}: #{response.body}"
      end
    end
  end
end
