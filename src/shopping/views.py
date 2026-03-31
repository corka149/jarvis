from random import randint

from django.shortcuts import render, get_object_or_404
from django.urls import reverse
from django.http import HttpResponseRedirect
from django.contrib.auth.decorators import login_required
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.mixins import LoginRequiredMixin
from django.forms.models import model_to_dict

from django.views.generic import ListView

from .models import ShoppingList, Meal, MealCategory
from web_jarvis import settings


def index(request):

    meals = random_meals()

    return render(request, "shopping/index.html", {"meals": meals})


def random_meals() -> list[str]:
    meals: list[Meal] = list()
    previous_category: MealCategory | None = None

    while previous_category != MealCategory.FULL and len(meals) < 2:
        if previous_category is None:
            meal_amount = Meal.objects.count()

            if meal_amount < 1:
                return []

            pick = randint(0, meal_amount - 1)
            meal = Meal.objects.all()[pick : pick + 1][0]
            meals.append(meal)
            previous_category = meal.category
        else:
            category = (
                MealCategory.GARNISH
                if previous_category == MealCategory.MAIN
                else MealCategory.MAIN
            )
            category_count = Meal.objects.filter(category=category).count()

            if category_count < 1:
                return []

            pick = randint(0, category_count - 1)
            meal = Meal.objects.filter(category=category)[pick : pick + 1][0]
            meals.append(meal)

    return [m.name for m in meals]


def login_user(request):
    if request.method == "GET":
        return render(request, "shopping/login.html", {})

    username = request.POST.get("username")
    password = request.POST.get("password")
    user = authenticate(username=username, password=password)

    if user is not None:
        login(request, user)
        return HttpResponseRedirect(reverse("shopping:index"))

    return HttpResponseRedirect(reverse("shopping:login"))


@login_required
def logout_user(request):
    logout(request)
    return HttpResponseRedirect(reverse("shopping:index"))


@login_required
def create_list(request):
    if request.method == "GET":
        sl = ShoppingList()
        return render(
            request,
            "shopping/shopping_list_form.html",
            {"shopping_list": sl, "shopping_list_items": []},
        )

    sl = ShoppingList(
        name=request.POST.get("name"),
        purchase_date=request.POST.get("purchase_date"),
        done=False,
        deleted=False,
    )
    sl.save()

    return HttpResponseRedirect(reverse("shopping:manage_items", args=[sl.id]))


@login_required
def edit_list(request, pk):
    sl = get_object_or_404(ShoppingList, pk=pk)

    shopping_list_items = sl.item_set.all()
    data = [model_to_dict(item) for item in shopping_list_items]

    if request.method == "GET":
        return render(
            request,
            "shopping/shopping_list_form.html",
            {"shopping_list": sl, "shopping_list_items": data},
        )

    sl.name = request.POST.get("name")
    sl.purchase_date = request.POST.get("purchase_date")
    sl.deleted = request.POST.get("deleted") == "on"
    sl.done = request.POST.get("done") == "on"
    sl.save()

    if sl.done:
        return HttpResponseRedirect(reverse("shopping:shopping_lists"))

    return HttpResponseRedirect(reverse("shopping:manage_items", args=[sl.id]))


@login_required
def delete_list(request, pk):
    sl = get_object_or_404(ShoppingList, pk=pk)
    sl.deleted = True
    sl.save()

    return HttpResponseRedirect(reverse("shopping:shopping_lists"))


@login_required
def delete_finally_list(request, pk):
    sl = get_object_or_404(ShoppingList, pk=pk)
    sl.delete()

    return HttpResponseRedirect(reverse("shopping:shopping_lists"))


@login_required
def manage_items(request, pk):
    sl = get_object_or_404(ShoppingList, pk=pk)

    shopping_list_items = sl.item_set.all()
    data = [model_to_dict(item) for item in shopping_list_items]

    debug_enabled = settings.DEBUG

    return render(
        request,
        "shopping/items.html",
        {
            "shopping_list": sl,
            "shopping_list_items": data,
            "debug_enabled": debug_enabled,
        },
    )


class ShoppingListView(LoginRequiredMixin, ListView):
    template_name = "shopping/shopping_list.html"
    context_object_name = "shopping_lists"

    def get_queryset(self):
        if self.request.GET.get("showAll") == "true":
            return ShoppingList.objects.all().order_by("-purchase_date")

        return ShoppingList.objects.filter(deleted=False, done=False).order_by(
            "-purchase_date"
        )


def create_meal(request):
    if request.method == "GET":
        categories = [c.value for c in MealCategory]
        return render(
            request,
            "shopping/meal_form.html",
            {"meal": Meal(), "categories": categories},
        )

    name = request.POST["name"]
    category = request.POST["category"]

    meal = Meal(name=name, category=category)
    meal.save()

    return HttpResponseRedirect(reverse("shopping:meals"))


def edit_meal(request, pk):
    meal = get_object_or_404(Meal, pk=pk)

    if request.method == "GET":
        categories = [c.value for c in MealCategory]
        return render(
            request, "shopping/meal_form.html", {"meal": meal, "categories": categories}
        )

    meal.name = request.POST["name"]
    meal.category = request.POST["category"]

    meal.save()

    return HttpResponseRedirect(reverse("shopping:meals"))


def delete_meal(request, pk):
    meal = get_object_or_404(Meal, pk=pk)
    meal.delete()

    return HttpResponseRedirect(reverse("shopping:meals"))


class MealsView(LoginRequiredMixin, ListView):
    template_name = "shopping/meals.html"
    context_object_name = "meals"

    def get_queryset(self):
        return Meal.objects.all()
