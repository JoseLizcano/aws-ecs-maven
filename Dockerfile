FROM maven:3.5-jdk-8-alpine as build
WORKDIR /app
COPY . /app
RUN mvn install && mvn test

FROM openjdk:8-jre-alpine
ARG artifactid
ARG version
ENV artifact ${artifactid}-${version}.jar 
WORKDIR /app
COPY --from=build /app/target/${artifact} /app
EXPOSE 8080
CMD ["java -jar ${artifact}"] 