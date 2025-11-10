# Bancointer

Uma gem Ruby para integração com as APIs do Banco Inter.

## Características

- ✅ Autenticação mTLS com certificados
- ✅ OAuth 2.0 client credentials flow
- ✅ Gerenciamento automático de tokens
- ✅ Suporte para ambiente sandbox e produção
- ✅ Configuração global e por instância
- ✅ Rate limiting aware

## Instalação

Adicione esta linha ao seu Gemfile:

```ruby
gem 'bancointer-ruby'
```

E execute:

    $ bundle install

Ou instale diretamente:

    $ gem install bancointer-ruby

## Configuração

### Certificados

Primeiro, você precisa dos certificados do Banco Inter:
- Certificado da aplicação (`.crt`)
- Chave privada (`.key`) 
- Certificado CA (opcional, mas recomendado)

### Configuração Global

```ruby
require 'bancointer'

Bancointer.configure do |config|
  config.client_id = 'seu_client_id'
  config.client_secret = 'seu_client_secret'
  config.cert_path = '/path/to/certificates/Sandbox_InterAPI_Certificado.crt'
  config.key_path = '/path/to/certificates/Sandbox_InterAPI_Chave.key'
  config.ca_cert_path = '/path/to/certificates/ca.crt' # webhook opcional
  config.environment = :sandbox # ou :production
  config.default_scopes = ['extrato.read', 'boleto-cobranca.read']
end

# Use a configuração global
client = Bancointer.client
```

### Configuração por Instância

```ruby
client = Bancointer::Client.new(
  client_id: 'seu_client_id',
  client_secret: 'seu_client_secret',
  cert_path: '/path/to/certificates/Sandbox_InterAPI_Certificado.crt',
  key_path: '/path/to/certificates/Sandbox_InterAPI_Chave.key',
  ca_cert_path: '/path/to/certificates/ca.crt',
  environment: :sandbox,
  scopes: ['extrato.read', 'pix.read']
)
```

## Uso

### Autenticação

```ruby
# Autenticar com escopos padrão
token = client.authenticate!

# Autenticar com escopos específicos
token = client.authenticate!(['pix.read', 'boleto-cobranca.read'])

# Verificar se está autenticado
puts client.authenticated? # => true/false

# Verificar se o token expirou
puts client.token_expired? # => true/false
```

### Fazendo Requisições

```ruby
# A autenticação é feita automaticamente se necessário
response = client.request(:get, '/v2/extrato')
response = client.request(:post, '/v2/boletos', { dados: 'do_boleto' })

# Com headers personalizados
response = client.request(:get, '/v2/saldo', {}, { 'X-Custom-Header' => 'valor' })
```

### Escopos Disponíveis

Alguns escopos comuns:
- `extrato.read` - Consultar extrato
- `boleto-cobranca.read` - Consultar boletos
- `boleto-cobranca.write` - Criar boletos  
- `pix.read` - Consultar Pix
- `pix.write` - Criar Pix

Consulte a [documentação oficial](https://developers.inter.co/) para a lista completa.

### Ambientes

- `:sandbox` - https://cdpj-sandbox.partners.uatinter.co (padrão)
- `:production` - https://cdpj.partners.bancointer.com.br

## Rate Limiting

A API do Banco Inter tem limite de 5 chamadas por minuto tanto em sandbox quanto em produção. A gem não implementa rate limiting automático, então você deve controlar isso em sua aplicação.

## Exemplo Completo

```ruby
require 'bancointer'

# Configurar
Bancointer.configure do |config|
  config.client_id = 'seu_client_id'
  config.client_secret = 'seu_client_secret'
  config.cert_path = './certificates/Sandbox_InterAPI_Certificado.crt'
  config.key_path = './certificates/Sandbox_InterAPI_Chave.key'
  config.ca_cert_path = './certificates/ca.crt'
  config.environment = :sandbox
  config.default_scopes = ['extrato.read']
end

# Usar
client = Bancointer.client

begin
  # Autenticar
  token = client.authenticate!
  puts "Token obtido: #{token}"
  
  # Fazer requisições
  response = client.request(:get, '/v2/extrato')
  puts "Status: #{response.status}"
  puts "Body: #{response.body}"
  
rescue Bancointer::Client::AuthenticationError => e
  puts "Erro de autenticação: #{e.message}"
rescue Bancointer::Client::ConfigurationError => e
  puts "Erro de configuração: #{e.message}"
end
```

## Desenvolvimento

Após clonar o repositório, execute `bin/setup` para instalar as dependências. Execute `rake test` para rodar os testes.

Para instalar a gem localmente, execute `bundle exec rake install`.

Os certificados de sandbox podem ser incluídos na pasta `certificates/`.

## Contribuição

Bug reports e pull requests são bem-vindos no GitHub.

## Licença

A gem está disponível como open source under os termos da [MIT License](https://opensource.org/licenses/MIT).
