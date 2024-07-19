# ===== ===== FE BUILD ===== =====

FROM node:20.12 as fe-build

ADD ./jarvis-fe /opt/jarvis-fe

WORKDIR /opt/jarvis-fe

RUN npm install

RUN npm run ng build --optimization

# ===== ===== BE BUILD ===== =====

FROM rust:1.78 as be-build

ADD ./jarvis-backend /opt/jarvis-be

WORKDIR /opt/jarvis-be

RUN cargo build --release

# ===== ===== jarvis ===== =====

FROM gcr.io/distroless/cc

COPY --from=fe-build /opt/jarvis-fe/dist/jarvis-fe /jarvis-fe
COPY --from=be-build /opt/jarvis-be/target/release/jarvis-backend /

CMD ["./jarvis-backend", "server"]
