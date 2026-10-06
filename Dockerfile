FROM ruby:3.2-slim

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    git \
    curl \
    protobuf-compiler \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# RUN mkdir -p /usr/local/share/ca-certificates/
# COPY ./certs /usr/local/share/ca-certificates/
# RUN chmod 644 /usr/local/share/ca-certificates/* && \
#     update-ca-certificates

WORKDIR /app

COPY Gemfile ./
RUN bundle install

RUN git clone https://github.com/RussianInvestments/investAPI /tmp/investAPI && \
    mkdir -p /app/contracts && \
    cp -r /tmp/investAPI/src/docs/contracts/* /app/contracts/ && \
    rm -rf /tmp/investAPI

RUN mkdir -p /app/generated && \
    grpc_tools_ruby_protoc \
    --proto_path=/app/contracts \
    --ruby_out=/app/generated \
    --grpc_out=/app/generated \
    /app/contracts/*.proto

COPY . .

CMD ["bundle", "exec", "ruby", "main.rb"]
