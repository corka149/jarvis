from django.test import TestCase
from django.urls import reverse

from .models import Meal


class CookingIndexViewTests(TestCase):

    def test_index_contain_one_complete(self):
        # Given main pizza
        pizza = Meal(name="Pizza", category=Meal.COMPLETE)
        pizza.save()

        # When getting the index
        index_resp = self.client.get(reverse("cooking:index"))

        # Then it returns the page with 200 with pizza
        self.assertEqual(index_resp.status_code, 200)
        self.assertContains(index_resp, pizza.name)

    def test_index_contain_one_main_and_one_supplement(self):
        # Given main menu
        burrito = Meal(name="Burrito", category=Meal.MAIN)
        burrito.save()
        salat = Meal(name="Salat", category=Meal.SUPPLEMENT)
        salat.save()

        # When getting the index
        index_resp = self.client.get(reverse("cooking:index"))

        # Then it returns the page with 200 and burrito plus salat
        self.assertEqual(index_resp.status_code, 200)
        self.assertQuerysetEqual(index_resp.context["meals"], [salat, burrito])
        self.assertContains(index_resp, burrito.name)
        self.assertContains(index_resp, salat.name)
