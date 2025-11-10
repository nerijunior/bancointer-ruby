# frozen_string_literal: true

require "test_helper"

class Bancointer::Test < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Bancointer::VERSION
  end

  def test_client_initialization_with_valid_params
    # Usar os certificados de sandbox reais que estão no repositório
    cert_path = File.expand_path("../../certificates/Sandbox_InterAPI_Certificado.crt", __dir__)
    key_path = File.expand_path("../../certificates/Sandbox_InterAPI_Chave.key", __dir__)

    # Verificar se os certificados existem antes de testar
    if File.exist?(cert_path) && File.exist?(key_path)
      client = Bancointer::Client.new(
        client_id: "test_id",
        client_secret: "test_secret",
        cert_path: cert_path,
        key_path: key_path,
        environment: :sandbox
      )

      assert_equal "test_id", client.client_id
      assert_equal "test_secret", client.client_secret
      assert_equal :sandbox, client.environment
      refute client.authenticated?
    else
      skip "Certificados não encontrados para teste"
    end
  end

  def test_client_initialization_without_required_params
    assert_raises(Bancointer::Client::ConfigurationError) do
      Bancointer::Client.new
    end
  end

  def test_configuration_module
    Bancointer.configure do |config|
      config.client_id = "configured_id"
      config.environment = :production
    end

    assert_equal "configured_id", Bancointer.client_id
    assert_equal :production, Bancointer.environment
  end
end
