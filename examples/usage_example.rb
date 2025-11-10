# frozen_string_literal: true

# Exemplo de uso da gem bancointer-ruby

require "bancointer/bancointer"

# Configuração global
Bancointer.configure do |config|
  config.client_id = "seu_client_id"
  config.client_secret = "seu_client_secret"
  config.cert_path = "/path/to/certificates/Sandbox_InterAPI_Certificado.crt"
  config.key_path = "/path/to/certificates/Sandbox_InterAPI_Chave.key"
  config.ca_cert_path = "/path/to/certificates/ca.crt" # opcional
  config.environment = :sandbox # ou :production
  config.default_scopes = ["extrato.read", "boleto-cobranca.read"]
end

# Usando a configuração global
client = Bancointer.client

# Autenticando (será feito automaticamente nas requisições se necessário)
token = client.authenticate!
puts "Token: #{token}"

# Fazendo uma requisição (exemplo fictício)
# response = client.request(:get, '/v2/extrato')

# Usando cliente instanciado diretamente
client_direto = Bancointer::Client.new(
  client_id: "seu_client_id",
  client_secret: "seu_client_secret",
  cert_path: "./certificates/Sandbox_InterAPI_Certificado.crt",
  key_path: "./certificates/Sandbox_InterAPI_Chave.key",
  ca_cert_path: "./certificates/ca.crt",
  environment: :sandbox,
  scopes: ["extrato.read"]
)

# Verificar se está autenticado
puts "Autenticado: #{client_direto.authenticated?}"

# Autenticar com escopos específicos
token = client_direto.authenticate!(["pix.read", "boleto-cobranca.read"])
puts "Token obtido: #{token}"
puts "Autenticado: #{client_direto.authenticated?}"
