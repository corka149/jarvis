import random
from typing import List

from django.db import models


class Meal(models.Model):
    COMPLETE = "COMPLETE"
    MAIN = "MAIN"
    SUPPLEMENT = "SUPPLEMENT"

    CATEGORY_CHOICES = {
        COMPLETE: "Komplettes Gericht",
        MAIN: "Hauptspeise",
        SUPPLEMENT: "Beilage",
    }

    name = models.CharField(max_length=50)
    category = models.CharField(
        max_length=10, choices=CATEGORY_CHOICES, default=COMPLETE
    )

    def __str__(self):
        return self.name

    @classmethod
    def random_meal(cls) -> List["Meal"]:
        meals = cls.objects.all()

        if not meals:
            return []

        random_meal = random.choice(meals) if len(meals) > 1 else meals[0]

        if random_meal.category == cls.MAIN:
            supplements = cls.objects.filter(category=cls.SUPPLEMENT)
            random_supplement = random.choice(supplements)
            return [random_meal, random_supplement]

        if random_meal.category == cls.SUPPLEMENT:
            mains = cls.objects.filter(category=cls.MAIN)
            random_main = random.choice(mains)
            return [random_meal, random_main]

        return [random_meal]
