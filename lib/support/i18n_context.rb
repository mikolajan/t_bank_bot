require 'i18n'

I18n.load_path << Dir["#{Dir.pwd}/locales/*.yml"]
I18n.default_locale = ENV.fetch('DEFAULT_LOCALE', :ru)

module Support
  module I18nContext
    DIR_PWD = Dir.pwd.freeze

    def t(key, **kwargs) = I18n.t(prepare_key(key), **kwargs)

    private

    def prepare_key(key)
      key_str = key.is_a?(Symbol) ? ".#{key}" : key.to_s
      key_str.start_with?('.') && (f_c = file_context) ? "#{f_c}#{key_str}" : key_str
    end

    def file_context
      path = caller_locations(3, 1).first&.path
      path.sub("#{DIR_PWD}/", '').sub(/^lib\//, '').chomp('.rb').tr('/', '.') if path
    end
  end
end
