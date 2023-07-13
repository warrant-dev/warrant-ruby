# frozen_string_literal: true

module Warrant
    # @!visibility private
    class Util
        class << self
            def camelcase(str)
                str = str.split('_').collect(&:capitalize).join
                str.sub(str[0], str[0].downcase)
            end

            def snake_case(str)
                str.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                    .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                    .downcase
            end

            def normalize_params(params)
                params.compact!

                case params
                when Hash
                    params.each_with_object({}) do |(k, v), new_opts|
                        if k.to_s == "context"
                            new_opts[k] = v
                            next
                        end

                        new_key = Util.camelcase(k.to_s)

                        case v
                        when Hash
                            new_opts[new_key] = normalize_params(v)
                        when Array
                            new_opts[new_key] = v.map { |i| normalize_params(i) }
                        when Subject
                            new_opts[new_key] = "#{v.object_type}:#{v.object_id}"
                        else
                            new_opts[new_key] = v
                        end
                    end
                when Array
                    params.map { |i| normalize_params(i) }
                else
                    params
                end
            end
        end
    end
end
