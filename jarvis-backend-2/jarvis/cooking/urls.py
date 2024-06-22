from django.urls import path

from . import views

# For namespacing the url
app_name = "cooking"

urlpatterns = [
    path("", views.index, name="index"),
]
