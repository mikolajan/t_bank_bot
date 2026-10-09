require 'bigdecimal'

module Tinkoff
  module Public
    module Invest
      module Api
        module Contract
          module V1
            class Quotation
              def to_d
                BigDecimal(units.to_s) + (BigDecimal(nano.to_s) / BigDecimal('1000000000.0'))
              end

              def to_f
                to_d.to_f
              end
            end
          end
        end
      end
    end
  end
end
