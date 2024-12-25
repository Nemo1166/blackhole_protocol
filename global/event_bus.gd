extends Node

var event_handlers = {}	# event_name: Array[func]

## Subscribes a function to an event.
func subscribe(event_name: String, callable: Callable):
	if not event_handlers.has(event_name):
		event_handlers[event_name] = []
	event_handlers[event_name].append(callable)

## Unsubscribes a function from an event.
func unsubscribe(event_name: String, callable: Callable):
	if event_handlers.has(event_name):
		event_handlers[event_name].erase(callable)
		if event_handlers[event_name].size() == 0:
			event_handlers.erase(event_name)

## Publishes an event to all subscribed functions.
func publish(event_name: String, args: Array = []):
	if event_handlers.has(event_name):
		for f in event_handlers[event_name]:
			f.call_deferred(args)
