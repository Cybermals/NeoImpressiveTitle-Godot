extends Node

var log_file = File.new()


func _ready():
	# Open log file
	if log_file.open("user://log.txt", File.WRITE):
		log_critical("Logger", "Failed to open log file!")
		
	else:
		log_info("Logger", "Log intialized.")
		
		
func _log_msg(system, type, msg):
	# Format the full message and print it
	var full_msg = "[{0}] [{1}] {2}".format([system, type, msg])
	print(full_msg)
	
	# If the log file is open, write the message to the log file too
	if log_file.is_open():
		log_file.store_line(full_msg)
		
		
func log_info(system, msg):
	_log_msg(system, "INFO", msg)
	
	
func log_warning(system, msg):
	_log_msg(system, "WARNING", msg)
	
	
func log_error(system, msg):
	_log_msg(system, "ERROR", msg)
	
	
func log_critical(system, msg):
	_log_msg(system, "CRITICAL", msg)
