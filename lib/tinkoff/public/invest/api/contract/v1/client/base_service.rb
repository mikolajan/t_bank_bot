module Tinkoff
  module Public
    module Invest
      module Api
        module Contract
          module V1
            module Client
              class BaseService
                attr_reader :channel, :stub

                def initialize(channel)
                  @channel = channel
                  @stub = build_stub_class.new(@channel.endpoint, @channel.credentials)
                end

                protected

                def build_stub_class
                  class_name = self.class.name.split('::').last
                  V1.const_get(class_name).const_get('Stub')
                rescue NameError => e
                  raise NameError, t('.missing_stub_class', full_class_name: "#{V1}::#{class_name}::Stub", message: e.message)
                end

                def build_request(request_name, **kwargs)
                  V1.const_get(request_name).new(**kwargs)
                rescue NameError => e
                  raise NameError, t('.missing_request_class', full_request_name: "#{V1}::#{request_name}", message: e.message)
                end

                def execute_rpc(method_name, request)
                  @stub.send(method_name, request, metadata: @channel.metadata)
                rescue GRPC::BadStatus => e
                  raise t('.grpc_bad_status', class_name: self.class.name, code: e.code, details: e.details)
                end
              end
            end
          end
        end
      end
    end
  end
end
