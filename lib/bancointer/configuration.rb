# frozen_string_literal: true

module Bancointer
  module Configuration
    attr_accessor :client_id, :client_secret, :cert_path, :key_path,
                  :ca_cert_path, :environment, :default_scopes

    def configure
      yield self
    end

    def client
      @client ||= Client.new(
        client_id: client_id,
        client_secret: client_secret,
        cert_path: cert_path,
        key_path: key_path,
        ca_cert_path: ca_cert_path,
        environment: environment || :sandbox,
        scopes: default_scopes || []
      )
    end

    def reset_client!
      @client = nil
    end
  end

  extend Configuration
end
