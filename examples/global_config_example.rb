# frozen_string_literal: true

# Exemplo usando configuração global

require_relative "../lib/bancointer"

# Configuração global - faça isso uma vez na inicialização da sua aplicação
Bancointer.configure do |config|
  config.client_id = "SEU_CLIENT_ID_AQUI"
  config.client_secret = "SEU_CLIENT_SECRET_AQUI"
  config.cert_path = File.expand_path("../certificates/Sandbox_InterAPI_Certificado.crt", __dir__)
  config.key_path = File.expand_path("../certificates/Sandbox_InterAPI_Chave.key", __dir__)
  config.ca_cert_path = File.expand_path("../certificates/ca.crt", __dir__)
  config.environment = :sandbox
  config.default_scopes = ["extrato.read", "boleto-cobranca.read", "pix.read"]
end

puts "=== Exemplo com Configuração Global ==="
puts

# Usar o cliente global
client = Bancointer.client

puts "✅ Cliente configurado globalmente"
puts "   Environment: #{client.environment}"
puts "   Default Scopes: #{client.scopes}"
puts

# Em diferentes partes da aplicação, você pode usar o cliente configurado
begin
  # Este é um exemplo de como você usaria em produção:
  puts "💡 Exemplo de uso em produção:"
  puts
  puts "# Obter token (feito automaticamente nas requisições)"
  puts "# token = client.authenticate!"
  puts
  puts "# Fazer requisições às APIs"
  puts "# extrato = client.request(:get, '/v2/extrato')"
  puts "# saldo = client.request(:get, '/v2/saldo')"
  puts
  puts "# Criar um boleto"
  puts "# boleto_data = { valor: 100.00, vencimento: '2024-12-31' }"
  puts "# boleto = client.request(:post, '/v2/boletos', boleto_data)"
  puts
  puts "# Consultar Pix"
  puts "# pix = client.request(:get, '/v2/pix')"
rescue StandardError => e
  puts "❌ Erro: #{e.message}"
end

puts
puts "=== Fim do exemplo ==="
