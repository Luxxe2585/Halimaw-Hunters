extends Node

#Card-related Events
signal card_drag_started(card_ui: CardUI)
signal card_drag_ended(card_ui: CardUI)
signal card_aim_started(card_ui: CardUI)
signal card_aim_ended(card_ui: CardUI)
signal card_played(card: Card)
signal card_tooltip_requested(card: Card)
signal tooltip_hide_requested()

# Player-related events
signal player_hand_drawn
signal player_hand_discarded
signal player_turn_started
signal player_turn_ended
signal player_died
signal player_health_loss

# Enemy-related events
signal enemy_action_completed(enemy: Enemy)
signal enemy_turn_ended
signal enemy_died(enemy: Enemy)

# Battle-related events
signal battle_started
signal after_stats_battle_started
signal battle_over_screen_requested(text: String, type: BattleOverPanel.Type)
signal battle_won
signal status_tooltip_requested(statuses: Array[Status])


# Map-related events
signal map_exited(room: Room)

# Shop-related events
signal shop_entered(shop: Shop)
signal shop_relic_bought(relic: Relic, gold_cost: int)
signal shop_card_bought(card: Card, gold_cost: int)
signal shop_card_removal_bought(card: Card, gold_cost: int)
signal shop_exited

# Campfire-related events
signal campfire_exited

# Battle Reward-related events
signal battle_reward_exited

# Treasure Room-related events
signal treasure_room_exited(found_relic: Relic)

# GAME_EVENT-related events
signal map_event_exited

# Relic-related events
signal relic_tooltip_requested(relic: Relic)

# Deck Selector Events
signal open_deck_selector_remove(amount: int)
signal open_deck_selector_upgrade(amount: int)
signal deck_selector_completed(selected_cards: Array[Card])
signal deck_selector_exited
signal shop_card_removed
