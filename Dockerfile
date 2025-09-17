# ===== ===== BE BUILD ===== =====

FROM rust:1.78 AS be-build

ADD ./jarvis-backend /opt/jarvis-be

WORKDIR /opt/jarvis-be

RUN cargo build --release

# ===== ===== jarvis ===== =====

FROM gcr.io/distroless/cc

COPY jarvis-fe/dist/jarvis-fe /jarvis-fe
COPY --from=be-build /opt/jarvis-be/target/release/jarvis-backend /

CMD ["./jarvis-backend", "server"]
