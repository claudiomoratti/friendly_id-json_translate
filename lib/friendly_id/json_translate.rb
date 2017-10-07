module FriendlyId
  module JsonTranslate
    class << self
      def setup(model_class)
        model_class.friendly_id_config.use :slugged
      end

      def included(model_class)
        advise_against_untranslated_model(model_class)
      end

      def advise_against_untranslated_model(model)
        field = model.friendly_id_config.query_field
        unless model.respond_to?('translated_attribute_names') ||
            model.translated_attribute_names.exclude?(field.to_sym)
          raise "[FriendlyId] You need to translate the '#{field}' field with " \
            "json_translates (add 'translates :#{field}' in your model '#{model.name}')"
        end
      end

      private :advise_against_untranslated_model
    end

    def set_friendly_id(text, locale = nil)
      execute_with_locale(locale || ::I18n.locale) do
        set_slug normalize_friendly_id(text)
      end
    end

    # You may want to override this method in order to trig the slug regeneration with your own logic
    def should_generate_new_friendly_id?
      translations = get_field_translations_hash
      return true unless translations

      if self.respond_to?("#{friendly_id_config.base}_translations")
        self.send "#{friendly_id_config.base}_translations_changed?"
      else
        self.send "#{friendly_id_config.base}_changed?"
      end
    end

    # Return an array of available locales. Override it if needed.
    def locales
      I18n.available_locales
    end

    def set_slug(normalized_slug = nil)
      locales.each do |locale|
        execute_with_locale(locale) { super_set_slug(normalized_slug) }
      end
    end

    def super_set_slug(normalized_slug = nil)
      if should_generate_new_friendly_id?
        candidates = FriendlyId::Candidates.new(self, normalized_slug || send(friendly_id_config.base))
        slug = slug_generator.generate(candidates) || resolve_friendly_id_conflict(candidates)
        self.send("#{friendly_id_config.query_field}=", slug)
      end
    end

    def get_field_translations_hash
      self.send("#{friendly_id_config.query_field}_translations")
    end

    def execute_with_locale(locale = ::I18n.locale, &block)
      actual_locale = ::I18n.locale
      ::I18n.locale = locale

      block.call

      ::I18n.locale = actual_locale
    end

    FriendlyId::FinderMethods.class_eval do
      def exists_by_friendly_id?(id)
        send("with_#{friendly_id_config.query_field}_translation", id).exists?
      end

      def first_by_friendly_id(id)
        send("with_#{friendly_id_config.query_field}_translation", id).first
      end
    end
  end
end
