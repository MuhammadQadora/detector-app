FROM maven:3.5.2 as maven
RUN mkdir /app
WORKDIR /app
COPY . /app
RUN mvn clean install -DskipTests


FROM openjdk:8 as jdk
RUN mkdir /myapp
WORKDIR /myapp
COPY --from=maven /app/target/ /myapp
RUN mv /myapp/*SNAPSHOT.jar /myapp/app.jar
EXPOSE 8080
CMD ["java","-jar","/myapp/app.jar"]
