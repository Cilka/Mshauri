extends Node
#This allows methods to be called in respective classes from any dialog
signal dialog_request(function: String, args : Array)
signal request_fulfilled(function: String)
