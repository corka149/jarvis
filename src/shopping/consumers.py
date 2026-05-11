import json

from asgiref.sync import async_to_sync
from channels.generic.websocket import WebsocketConsumer
from channels.layers import get_channel_layer
from django.forms.models import model_to_dict

from .models import Item, ShoppingList


class ChatConsumer(WebsocketConsumer):
    def connect(self):
        self.shopping_list_id = self.scope["url_route"]["kwargs"]["shopping_list_id"]
        self.shopping_list_group_name = f"chat_{self.shopping_list_id}"

        # Join list group
        async_to_sync(self.channel_layer.group_add)(
            self.shopping_list_group_name, self.channel_name
        )

        if "user" in self.scope and self.scope["user"].is_authenticated:
            self.accept()

    def disconnect(self, close_code):
        async_to_sync(self.channel_layer.group_discard)(
            self.shopping_list_group_name, self.channel_name
        )

    # Receive message from WebSocket
    def receive(self, text_data):
        # {"op": "edit", "value": {"id": 1, "name": "bread", "quantity": 1.1}}
        change = json.loads(text_data)
        op = change.get("op")
        val = change.get("value")

        if op == "reload":
            sl = ShoppingList.objects.get(id=self.shopping_list_id)
            items = sl.item_set.all()
            change["value"] = [model_to_dict(item) for item in items]
            channel_layer = get_channel_layer()
            async_to_sync(channel_layer.send)(
                self.channel_name,
                {"type": "list.change", "change": change},
            )
            return
        elif op == "delete":
            item = Item.objects.get(id=val["id"])
            item.delete()
        elif op == "update":
            item = Item.objects.get(id=val["id"])
            item.name = val["name"]
            item.quantity = val["quantity"]
            item.collected = val["collected"]
            item.save()
        elif op == "add":
            item = Item(
                name=val["name"],
                quantity=val["quantity"],
                shopping_list_id=self.shopping_list_id,
            )
            item.save()
            val["id"] = item.id

        async_to_sync(self.channel_layer.group_send)(
            self.shopping_list_group_name,
            {"type": "list.change", "change": change},
        )

    # Receive message from shopping list
    def list_change(self, msg):
        # Send message to WebSocket
        self.send(text_data=json.dumps(msg["change"]))
