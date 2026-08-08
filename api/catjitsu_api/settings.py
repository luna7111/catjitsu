import os
import socket
from pathlib import Path
from dotenv import load_dotenv

load_dotenv('.env.prod')

# 42 Oauth

CLIENT_ID = os.getenv("DJANGO_OAUTH_CLIENT_ID")
CLIENT_SECRET = os.getenv("DJANGO_OAUTH_CLIENT_SECRET")
REDIRECT_URI = os.getenv("DJANGO_REDIRECT_URI")

REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": (
        "rest_framework.authentication.TokenAuthentication",
    ),
    "DEFAULT_PERMISSION_CLASSES": [
        "rest_framework.permissions.IsAuthenticated",
    ],
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.ScopedRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'login': '5/minute',
        'register': '3/hour',
    },
}

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = os.getenv("DJANGO_SECRET_KEY")
if not SECRET_KEY and not DEBUG:
    raise ValueError("DJANGO_SECRET_KEY environment variable is not set!")

DEBUG = os.getenv("DEBUG", "False").lower() in ("true", "1", "yes")

ALLOWED_HOSTS = os.getenv("DJANGO_ALLOWED_HOSTS", "127.0.0.1,localhost").split(",")
CSRF_TRUSTED_ORIGINS = os.getenv("DJANGO_CSRF_TRUSTED_ORIGINS", "https://127.0.0.1").split(",")

# Tell Django that Nginx handles SSL termination
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True


# Application definition

INSTALLED_APPS = [
    'corsheaders',
    'rest_framework',
    'rest_framework_api_key',
    'rest_framework.authtoken',
    'catjitsu_api',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'catjitsu_api.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'catjitsu_api.wsgi.application'


DATABASES = {
    # 'default': {
    #     'ENGINE': 'django.db.backends.mysql',
    #     'NAME': 'catjitsu_db',
    #     'USER':'api_rw',
    #     'PASSWORD':'1234',
    # }
    # Temporary SQLite alternative for systems without MariaDB
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}


# Password validation

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Internationalization

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)

STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / "staticfiles"

# Default primary key field type

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# CORS settings (TEMPORARY)
# Allow the Godot HTML5 export during local development at http://localhost to access this API.
# Remove these settings when the frontend is served from the same origin as the API.
cors_origins = os.getenv("DJANGO_CORS_ALLOWED_ORIGINS", "")
# CORS_ALLOWED_ORIGINS = [

#     origin.strip() for origin in cors_origins.split(",") if origin.strip()
#     # "https://10.12.19.1",
#     # "https://10.12.19.1:8060",
#     # "https://10.12.19.1:8080",
#     # "https://10.12.19.1:8001",
#     # "https://172.18.0.5"
#     # "https://localhost:8443"
# ]

CORS_ALLOW_ALL_ORIGINS = True