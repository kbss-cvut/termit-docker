FROM nginx:latest
ARG CONTEXT=/termit
WORKDIR /etc/nginx/
COPY nginx.conf .
ENV CONTEXT=$CONTEXT
RUN sed -i "s:<ROOT>:${CONTEXT}:g" ./nginx.conf