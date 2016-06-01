module SalesRefresh
  module API
    module Validators
      class NotEmpty < Grape::Validations::Validator
        def validate_param!(attr_name, params)
          param_value = params[attr_name]
          return if key_is_missing_from_params(param_value)

          if param_value.empty?
            raise Grape::Exceptions::Validation, {params: [@scope.full_name(attr_name)], message: 'must not be empty'}
          end
        end

        private
        def key_is_missing_from_params(param_value)
          #This is based on the assumption that parameters cannot have nil values.
          #We assume that nils are serialized as empty strings
          param_value.nil?
        end
      end
    end
  end
end