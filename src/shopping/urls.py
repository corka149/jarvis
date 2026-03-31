from django.urls import path

from . import views

app_name = "shopping"
urlpatterns = [
    path("", views.index, name="index"),
    path("login", views.login_user, name="login"),
    path("logout", views.logout_user, name="logout"),
    # Lists
    path("lists/", views.ShoppingListView.as_view(), name="shopping_lists"),
    path("lists/new", views.create_list, name="create_list"),
    path("lists/<int:pk>", views.edit_list, name="edit_list"),
    path("lists/<int:pk>/delete", views.delete_list, name="delete_list"),
    path("lists/<int:pk>/items", views.manage_items, name="manage_items"),
    # Meals
    path("meals/", views.MealsView.as_view(), name="meals"),
    path("meals/new", views.create_meal, name="create_meal"),
    path("meals/<int:pk>", views.edit_meal, name="edit_meal"),
    path("meals/<int:pk>/delete", views.delete_meal, name="delete_meal"),
]
