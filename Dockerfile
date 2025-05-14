FROM --platform=linux/arm64/v8 rust:1.84.1-bullseye AS build

COPY ./jemalloc-test /app
RUN chmod -R 777 /app
WORKDIR /app
RUN RUST_BACKTRACE=1 cargo build --release -j 1

FROM rust:1.84.1-bullseye
COPY --from=build /app/target/release/jemalloc-test /app/jemalloc-test
RUN chmod -R 777 /app
WORKDIR /app
ENTRYPOINT ["./jemalloc-test"]
