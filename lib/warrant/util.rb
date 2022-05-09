# frozen_string_literal: true

module Warrant
    class Util
        class << self
            def camelcase(str)
                str = str.split('_').collect(&:capitalize).join
                str.sub(str[0], str[0].downcase)
            end

            def normalize_options(opts)
                new_opts = opts.each_with_object({}) do |(k, v), new_opts|
                    new_key = Util.camelcase(k.to_s)

                    new_opts[new_key] = v
                end
            end
        end
    end
end
