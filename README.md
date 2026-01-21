# Cron Job Notification System – Spring Boot

This project implements a **cron-based notification and reminder system** using Spring Boot.

It allows scheduling automated tasks such as reminders and notifications using Spring’s `@Scheduled` annotation.

---

## Features

- Cron job scheduling using Spring Boot  
- Automated reminder / notification system  
- REST APIs to create and manage reminders  
- Database-backed storage for scheduled reminders  
- Clean layered architecture:
  - Controller  
  - Service  
  - Repository  
  - Scheduler  
- Easily extensible for:
  - Email notifications  
  - SMS alerts  
  - Push notifications  

---

## Tech Stack

### Backend
- Java  
- Spring Boot  
- Spring Scheduler (`@Scheduled`)  
- Spring Data JPA  
- Maven  
- H2 / MySQL (configurable)  

### Frontend
- Flutter  

---


## How Cron Works in This Project

- Cron jobs are defined using Spring’s `@Scheduled` annotation  
- Jobs execute automatically based on:
  - Fixed intervals  
  - Cron expressions  

### Example Use Cases
- Medicine reminders  
- Task notifications  
- Scheduled alerts  
- Background cleanup jobs  

---

## Running the Backend

Run using Maven Wrapper:

```bash
cd backend
./mvnw spring-boot:run


