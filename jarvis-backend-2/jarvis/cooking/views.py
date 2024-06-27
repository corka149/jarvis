from django.http import HttpResponse
from django.template import loader
from django.shortcuts import render

from .models import Meal


def index(request):
    meals = Meal.random_meal()

    context = {"meals": meals}

    return render(request, "cooking/index.html", context)
