FROM nginx:alpine3.18
ARG CONTEXT=/termit
WORKDIR /etc/nginx/
COPY nginx.conf .
ENV CONTEXT=$CONTEXT
RUN sed -i "s:<ROOT>:${CONTEXT}:g" ./nginx.conf
