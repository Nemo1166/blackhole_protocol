class_name AwaitBlocker

signal continued

func go_on_deferred():
	continued.emit.call_deferred()