# Django API and it's deployement explained

## I. Understanding How a Basic Django API Works

This document provides a clear, structural overview of how a Django API operates using **Django REST Framework (DRF)**. It breaks down the core architecture, the request-response lifecycle, and the key building blocks required to build a modern RESTful web service.

---

### 1. Overview & Architecture

At its core, a Django API acts as a bridge between a frontend client (a web application, mobile app, or game engine) and a database. 

Unlike traditional Django applications that render HTML templates, an API receives HTTP requests (containing JSON payloads or URL parameters) and returns structured data—typically **JSON**.

```
[ Client / Browser / Mobile App ]
               │
               ▼  1. HTTP Request (GET / POST / PUT / DELETE)
       ┌───────────────┐
       │   urls.py     │  (URL Routing)
       └───────┬───────┘
               │
               ▼  2. Dispatches Request
       ┌───────────────┐
       │   views.py    │  (Request Handling & Logic)
       └───────┬───────┘
               │
         3. Validates / Serializes Data
               ▼
     ┌───────────────────┐
     │  serializers.py   │ ◄────► ┌──────────────────┐
     └───────────────────┘        │    models.py     │ (Database ORM)
                                  └─────────┬────────┘
                                            │
                                            ▼
                                  ┌──────────────────┐
                                  │  Database (SQL)  │
                                  └──────────────────┘
               │
               ▼  4. HTTP Response (JSON + Status Code)
[ Client / Browser / Mobile App ]
```

---

### 2. Core Building Blocks

A basic Django REST API consists of four main components working together:

#### A. Models (`models.py`) — The Data Layer
Models define the structure of your database tables using Python classes. Django's Object-Relational Mapper (ORM) translates these classes into SQL tables automatically.

* **Role:** Stores and retrieves application data (e.g., Users, Products, Game Scores).
* **Key Feature:** Provides methods to query, filter, and modify database records safely without writing raw SQL.

#### B. Serializers (`serializers.py`) — The Translation Layer
Serializers bridge the gap between Django's complex Python model objects and standard JSON format.

* **Serialization:** Converts database model instances into Python dictionaries that can easily be rendered as JSON.
* **Deserialization & Validation:** Parses incoming JSON request payloads, validates input rules, and converts data back into Python objects ready for database insertion.

#### C. Views (`views.py`) — The Logic Layer
Views receive HTTP requests, execute business logic, query the database via models, invoke serializers, and return an `HTTPResponse` (or DRF `Response`).

* **Function-Based Views (FBVs):** Simple Python functions decorated with `@api_view`.
* **Class-Based Views (CBVs):** Object-oriented classes inheriting from `APIView` or DRF generics (`ListCreateAPIView`, `RetrieveUpdateDestroyAPIView`), offering reusability and cleaner code structure.

#### D. URL Routing (`urls.py`) — The Endpoint Map
The URL dispatcher matches incoming HTTP request paths to their corresponding views.

* **Role:** Maps endpoints like `/api/players/` or `/api/players/1/` to the specific view class or function handling that endpoint.

---

### 3. The Request Lifecycle (Step-by-Step)

Here is what happens behind the scenes when a client sends a request to a Django API:

1. **HTTP Request Arrives:** A client sends a `GET` or `POST` request to an endpoint (e.g., `POST /api/players/`).
2. **URL Matching (`urls.py`):** Django inspects the requested URL path and routes the HTTP request to the designated view handler.
3. **Authentication & Permissions Check:** Django REST Framework checks whether the request contains valid credentials (e.g., JWT tokens or Token Headers) and whether the user is authorized (`IsAuthenticated`).
4. **View Processing (`views.py`):**
   * For **`GET` requests**: The view queries the database via `Model.objects.all()`, passes data to the serializer, and returns JSON.
   * For **`POST` requests**: The view passes incoming `request.data` into the serializer.
5. **Data Validation (`serializers.py`):** The serializer checks field constraints (e.g., `max_length`, required fields, unique constraints).
   * If **Valid**: Data is saved to the database (`serializer.save()`).
   * If **Invalid**: A `400 Bad Request` containing specific field errors is returned.
6. **HTTP Response Generated:** The view sends back a JSON response along with an appropriate HTTP status code (`200 OK`, `201 Created`, `400 Bad Request`, `401 Unauthorized`, or `404 Not Found`).

---

### 4. Securing the API

Most production APIs need to restrict endpoints so only authenticated users can access them:

* **Authentication Schemes:** 
  * **Token Authentication:** DRF's built-in key-value token mechanism.
* **Permissions (`permission_classes`):**
  * `IsAuthenticated`: Allows access only to logged-in users.
  * `AllowAny`: Public endpoints (e.g., Login or Registration).
  * Custom Permissions: Object-level checks to ensure users can only modify their own profiles.

---

### 5. Summary Checklist for Building a Django API

- [ ] **Define Models:** Set up database schema in `models.py` and run `python manage.py migrate`.
- [ ] **Create Serializers:** Define `ModelSerializer` classes in `serializers.py` to handle JSON mapping.
- [ ] **Write Views:** Implement Class-Based or Function-Based views in `views.py`.
- [ ] **Configure URLs:** Register endpoint paths in `urls.py`.
- [ ] **Apply Authentication & Permissions:** Protect sensitive endpoints using JWT or Token authentication.
- [ ] **Test Endpoints:** Use tools like Postman, Bruno, or `curl` to verify responses and status codes.

---
---
---

## II. Deploying a Django API: Nginx, Gunicorn & Database Setup

This guide details how to deploy a Django REST API in a production environment using **Nginx** as a reverse proxy, **Gunicorn** (Green Unicorn) as the WSGI application server, and **SQLite** or **MariaDB** for the database layer.

---

### 1. Production Architecture Overview

Running `python manage.py runserver` in production is insecure and unscalable. Production setups separate responsibilities into three distinct tiers:

```
[ Internet / External Clients ]
              │
              ▼  HTTP/HTTPS (Ports 80 / 443)
┌───────────────────────────────────────────┐
│                 Nginx                     │  (Reverse Proxy / SSL / Rate Limiting)
└─────────────────────┬─────────────────────┘
                      │
                      ▼  Unix Domain Socket / Internal HTTP (e.g., 127.0.0.1:8000)
┌───────────────────────────────────────────┐
│         Gunicorn (Green Unicorn)          │  (WSGI Application Server)
└─────────────────────┬─────────────────────┘
                      │
                      ▼  Executes Python Code / WSGI Entrypoint
┌───────────────────────────────────────────┐
│            Django REST API                │
└─────────────────────┬─────────────────────┘
                      │
                      ▼  SQL Queries
┌───────────────────────────────────────────┐
│          SQLite  OR  MariaDB              │  (Database Layer)
└───────────────────────────────────────────┘
```

---

### 2. Component Roles Explained

#### Nginx (Reverse Proxy)
* Sits on the public boundary of your server facing the internet.
* Handles SSL/TLS encryption termination (HTTPS).
* Serves static and media files directly from disk without touching Python processes.
* Forwards application requests to Gunicorn while passing client metadata (`Host`, `X-Real-IP`, `X-Forwarded-For`, `X-Forwarded-Proto`).

#### Gunicorn (WSGI Application Server)
* A high-performance Python Web Server Gateway Interface (WSGI) HTTP server.
* Runs multiple worker processes concurrently (pre-fork model) to execute Django code.
* Receives HTTP requests forwarded by Nginx and returns Python responses.

#### Database Layer Options
* **SQLite:** A serverless, file-based database stored as a single `.sqlite3` file on disk. Excellent for low-to-medium traffic applications, read-heavy workloads, or minimal infrastructure setups.
* **MariaDB:** A robust client-server relational database management system (RDBMS). Ideal for high-concurrency production deployments requiring horizontal scaling, row-level locking, and high write throughput.