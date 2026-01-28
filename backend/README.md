# Microgreens Management - Spring Boot Backend

A production-grade Spring Boot backend for microgreens management with IoT integration, AI predictions, and RESTful API.

## 🏗️ Architecture

```
src/main/java/com/aliparwiz/microgreens/
├── MicrogreensApplication.java    # Main application class
├── config/
│   ├── SecurityConfig.java        # Security and JWT configuration
│   └── CorsConfig.java            # CORS configuration
├── auth/
│   ├── User.java                  # User entity
│   ├── Role.java                  # Role enum
│   ├── AuthController.java        # Auth REST endpoints
│   ├── AuthService.java           # Auth business logic
│   └── AuthRepository.java        # User data access
├── device/
│   ├── Device.java                # Device entity
│   ├── DeviceController.java     # Device REST endpoints
│   ├── DeviceService.java         # Device business logic
│   └── DeviceRepository.java      # Device data access
├── sensor/
│   ├── SensorReading.java        # Sensor reading entity
│   ├── SensorController.java     # Sensor REST endpoints
│   ├── SensorService.java         # Sensor business logic
│   └── SensorRepository.java      # Sensor data access
└── ai/
    ├── Prediction.java            # Prediction entity
    ├── PredictionController.java  # AI prediction endpoints
    ├── PredictionService.java     # Prediction business logic
    └── PredictionRepository.java  # Prediction data access
```

## 🚀 Features

- ✅ **Spring Boot 3.2+** with Java 17
- ✅ **JWT Authentication** (skeleton ready for implementation)
- ✅ **CORS Configuration** for mobile app and web clients
- ✅ **PostgreSQL Database** integration
- ✅ **RESTful API** for all modules
- ✅ **Clean Architecture** with separation of concerns
- ✅ **Docker Support** with multi-stage build

## 📦 Prerequisites

- Java 17 or higher
- Maven 3.6+
- PostgreSQL 12+ (or Docker)
- Docker (optional, for containerized deployment)

## 🛠️ Setup

### 1. Database Setup

Create PostgreSQL database:

```sql
CREATE DATABASE microgreens_db;
```

Or using Docker:

```bash
docker run --name microgreens-postgres \
  -e POSTGRES_DB=microgreens_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  -d postgres:15
```

### 2. Configuration

Update `src/main/resources/application.properties`:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/microgreens_db
spring.datasource.username=your_username
spring.datasource.password=your_password
```

### 3. Build and Run

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

Or using Docker:

```bash
docker build -t microgreens-backend .
docker run -p 8080:8080 microgreens-backend
```

## 📡 API Endpoints

### Authentication

```bash
# Register
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"Password123","name":"John Doe"}'

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"Password123"}'

# Logout
curl -X POST http://localhost:8080/api/auth/logout \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Devices

```bash
# Get all devices
curl http://localhost:8080/api/devices

# Get device by ID
curl http://localhost:8080/api/devices/1

# Create device
curl -X POST http://localhost:8080/api/devices \
  -H "Content-Type: application/json" \
  -d '{"name":"Sensor 1","deviceId":"SENSOR001","deviceType":"sensor","location":"Greenhouse A"}'

# Update device
curl -X PUT http://localhost:8080/api/devices/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Updated Sensor 1"}'

# Delete device
curl -X DELETE http://localhost:8080/api/devices/1
```

### Sensor Readings

```bash
# Save reading
curl -X POST http://localhost:8080/api/sensors/readings \
  -H "Content-Type: application/json" \
  -d '{"deviceId":"SENSOR001","sensorType":"temperature","value":25.5,"unit":"Celsius"}'

# Get readings by device
curl http://localhost:8080/api/sensors/readings/device/SENSOR001

# Get latest readings
curl http://localhost:8080/api/sensors/readings/device/SENSOR001/latest
```

### AI Predictions

```bash
# Save prediction
curl -X POST http://localhost:8080/api/ai/predictions \
  -H "Content-Type: application/json" \
  -d '{"deviceId":"SENSOR001","predictionType":"harvest_time","predictionData":"{\"days\":7}","confidenceScore":0.95}'

# Get predictions by device
curl http://localhost:8080/api/ai/predictions/device/SENSOR001

# Get latest prediction
curl http://localhost:8080/api/ai/predictions/device/SENSOR001/type/harvest_time/latest
```

## 🔐 Security

### JWT Implementation (TODO)

The JWT authentication skeleton is in place. To implement:

1. Add JWT secret to `application.properties`
2. Implement JWT token generation in `AuthService`
3. Create JWT authentication filter
4. Add filter to `SecurityConfig`

### CORS

CORS is configured to allow:
- `http://localhost:3000` (web frontend)
- `http://localhost:8080` (same origin)
- `http://10.0.2.2:8080` (Android emulator)

Update `CorsConfig.java` to add more origins.

## 📝 TODO Items

- [ ] Implement JWT token generation and validation
- [ ] Add JWT authentication filter
- [ ] Implement user-device relationship
- [ ] Add MQTT integration for IoT devices
- [ ] Add WebSocket support for real-time updates
- [ ] Implement AI service webhook endpoint
- [ ] Add request validation
- [ ] Add comprehensive error handling
- [ ] Add API documentation (Swagger/OpenAPI)
- [ ] Add unit and integration tests
- [ ] Add logging and monitoring
- [ ] Add rate limiting
- [ ] Add database migrations (Flyway/Liquibase)

## 🧪 Testing

```bash
# Run tests
mvn test

# Run with coverage
mvn test jacoco:report
```

## 🐳 Docker

### Build Image

```bash
docker build -t microgreens-backend .
```

### Run Container

```bash
docker run -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://host.docker.internal:5432/microgreens_db \
  -e SPRING_DATASOURCE_USERNAME=postgres \
  -e SPRING_DATASOURCE_PASSWORD=postgres \
  microgreens-backend
```

### Docker Compose (with PostgreSQL)

Create `docker-compose.yml`:

```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: microgreens_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
  
  backend:
    build: .
    ports:
      - "8080:8080"
    depends_on:
      - postgres
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/microgreens_db
      SPRING_DATASOURCE_USERNAME: postgres
      SPRING_DATASOURCE_PASSWORD: postgres
```

Run with:

```bash
docker-compose up
```

## 📄 License

This project is part of a diploma application.

---

**Note**: Remember to configure database credentials and JWT secrets before deploying to production.

