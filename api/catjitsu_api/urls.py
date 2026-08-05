"""
URL configuration for catjitsu_api project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from .views import CurrentPlayerDetail, LoginUser, PlayerList, PlayerDetail, MatchList, MatchDetail, OAuth42Login, OAuth42Callback, IdentifyClient, auth_completed, RegisterUser, PlayerAvatar, PlayerPreferences

urlpatterns = [
    path('me/', CurrentPlayerDetail().as_view(), name='me'),
    path('register/', RegisterUser().as_view(), name='register'),
    path('login/', LoginUser.as_view(), name='login'),
    path('identify-client/', IdentifyClient().as_view()),
    path('auth/42/login/', OAuth42Login.as_view()),
    path('auth/42/callback/', OAuth42Callback.as_view()),
    path('auth/completed/', auth_completed, name='auth_completed'),
    path('admin/', admin.site.urls),
    path('players/', PlayerList.as_view(), name='PlayerList'),
    path('player/<int:pk>', PlayerDetail.as_view(), name='PlayerDetail'),
    path('player/<int:pk>/avatar', PlayerAvatar.as_view(), name='PlayerAvatar'),
    path('player/<int:pk>/preferences', PlayerPreferences.as_view(), name='PlayerPreferences'),
    path('matches/', MatchList.as_view(), name='MatchList'),
    path('match/<int:pk>', MatchDetail.as_view(), name='MatchDetail'),
]
