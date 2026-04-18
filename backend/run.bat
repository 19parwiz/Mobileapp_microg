@echo off
setlocal
echo [BACKEND] Starting Spring Boot backend...
echo If DB auth fails: set DATABASE_PASSWORD=^<your Postgres password^> ^(see application.properties comments^).
mvn spring-boot:run
