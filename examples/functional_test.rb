# frozen_string_literal: true

# Teste funcional da gem bancointer-ruby
# Este exemplo demonstra como usar a gem com os certificados do sandbox

require_relative "../lib/bancointer"

# Certificados do sandbox (já incluídos no repositório)
cert_path = File.expand_path("../certificates/Sandbox_InterAPI_Certificado.crt", __dir__)
key_path = File.expand_path("../certificates/Sandbox_InterAPI_Chave.key", __dir__)
ca_cert_path = File.expand_path("../certificates/ca.crt", __dir__)

puts "=== Teste da Gem Bancointer Ruby ==="
puts

# Verificar se os certificados existem
unless File.exist?(cert_path) && File.exist?(key_path)
  puts "❌ Certificados não encontrados:"
  puts "   Cert: #{cert_path}"
  puts "   Key: #{key_path}"
  exit 1
end

puts "✅ Certificados encontrados"
puts "   Cert: #{cert_path}"
puts "   Key: #{key_path}"
puts "   CA: #{ca_cert_path}" if File.exist?(ca_cert_path)
puts

# IMPORTANTE: Você precisa substituir estes valores pelos seus dados reais
# Obtenha-os no dashboard do Banco Inter em Aplicações > Detalhes
CLIENT_ID = "SEU_CLIENT_ID_AQUI"
CLIENT_SECRET = "SEU_CLIENT_SECRET_AQUI"

if CLIENT_ID == "SEU_CLIENT_ID_AQUI" || CLIENT_SECRET == "SEU_CLIENT_SECRET_AQUI"
  puts "⚠️  Para testar completamente, você precisa:"
  puts "   1. Acessar o dashboard do Banco Inter"
  puts "   2. Ir em Aplicações > Criar nova aplicação (ou usar existente)"
  puts "   3. Obter o Client ID e Client Secret"
  puts "   4. Substituir as constantes CLIENT_ID e CLIENT_SECRET neste arquivo"
  puts "   5. Configurar os escopos necessários na aplicação"
  puts
  puts "🧪 Executando teste sem autenticação real..."
  puts
end

begin
  # Configuração usando instância direta
  client = Bancointer::Client.new(
    client_id: CLIENT_ID,
    client_secret: CLIENT_SECRET,
    cert_path: cert_path,
    key_path: key_path,
    ca_cert_path: File.exist?(ca_cert_path) ? ca_cert_path : nil,
    environment: :sandbox,
    scopes: ["extrato.read", "boleto-cobranca.read"]
  )

  puts "✅ Cliente inicializado com sucesso"
  puts "   Environment: #{client.environment}"
  puts "   Client ID: #{client.client_id[0..10]}..."
  puts "   Scopes: #{client.scopes}"
  puts "   Autenticado: #{client.authenticated?}"
  puts

  # Se temos credenciais reais, tentar autenticar
  if CLIENT_ID != "SEU_CLIENT_ID_AQUI"
    puts "🔐 Tentando autenticar..."

    token = client.authenticate!

    puts "✅ Autenticação bem-sucedida!"
    puts "   Token: #{token[0..20]}..."
    puts "   Expira em: #{client.token_expires_at}"
    puts "   Autenticado: #{client.authenticated?}"
    puts

    # Exemplo de requisição (isso falhará porque não temos endpoints reais implementados)
    puts "📡 Exemplo de como fazer uma requisição:"
    puts "   response = client.request(:get, '/v2/extrato')"
    puts "   puts response.status"
    puts "   puts response.body"
  else
    puts "⏭️  Pulando autenticação real (credenciais não configuradas)"
  end
rescue Bancointer::Client::ConfigurationError => e
  puts "❌ Erro de configuração: #{e.message}"
rescue Bancointer::Client::AuthenticationError => e
  puts "❌ Erro de autenticação: #{e.message}"
  puts "   Verifique se:"
  puts "   - O Client ID e Client Secret estão corretos"
  puts "   - A aplicação está configurada corretamente no dashboard"
  puts "   - Os escopos estão habilitados na aplicação"
rescue StandardError => e
  puts "❌ Erro inesperado: #{e.class} - #{e.message}"
  puts e.backtrace.first(5)
end

puts
puts "=== Teste concluído ==="
