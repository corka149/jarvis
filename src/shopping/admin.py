from django.contrib import admin

from .models import ShoppingList, Item, Meal

# Register your models here.
admin.site.register(ShoppingList)
admin.site.register(Item)
admin.site.register(Meal)
