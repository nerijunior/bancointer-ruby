# frozen_string_literal: true

require_relative "bancointer/version"

module Bancointer
  class Error < StandardError; end
end

require_relative "bancointer/configuration"
require_relative "bancointer/client"
