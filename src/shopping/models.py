from enum import StrEnum

from django.db import models


class ShoppingList(models.Model):
    name = models.CharField(max_length=100, null=False)
    purchase_date = models.DateField("Purchase date", null=False)
    done = models.BooleanField("Done", null=False)
    deleted = models.BooleanField("Deleted", null=False)

    def __str__(self):
        return self.name


class Item(models.Model):
    shopping_list = models.ForeignKey(
        ShoppingList, on_delete=models.CASCADE, null=False
    )
    name = models.CharField(max_length=100, null=False)
    quantity = models.FloatField(default=0, null=False)

    def __str__(self):
        return self.name


class MealCategory(StrEnum):
    MAIN = "main"
    GARNISH = "garnish"
    FULL = "full"


class Meal(models.Model):
    name = models.CharField(max_length=100, null=False)
    category = models.CharField(
        choices={
            MealCategory.MAIN: "Main",
            MealCategory.GARNISH: "Garnish",
            MealCategory.FULL: "Full",
        },
        null=False,
    )

    def __str__(self):
        return f"{self.name} - {self.category}"
