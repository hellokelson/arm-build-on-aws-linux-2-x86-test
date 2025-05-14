I want build an arm docker image on a x86 instance

The build instance x86 images using AMI ID: ami-0090481fc3887c878
the region is : us-west-2

## the docker file like:
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

## the build method using buildx like:

docker buildx build --platform linux/arm/64 -t jemalloc-test:arm64 --load 


Can you generate a method to prepare a test environment and start to build arm image success?