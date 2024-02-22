extends Node

var log_file = File.new()


func _ready():
	# Open log file
	if log_file.open("user://log.txt", File.WRITE):
		log_critical("Logger", "Failed to open log file!")
		
	else:
		log_info("Logger", "Log intialized.")
		
	# Log system info
	var resolution = OS.get_video_mode_size()
	log_info("Logger", "")
	log_info("Logger", "***System Info***")
	log_info("Logger", "Engine: Godot {0}".format([OS.get_engine_version()["string"]]))
	log_info("Logger", "Platform: {0}".format([OS.get_name()]))
	log_info("Logger", "Device: {0}".format([OS.get_model_name()]))
	log_info("Logger", "Threads: {0}".format(["Yes" if OS.can_use_threads() else "No"]))
	log_info("Logger", "Locale: {0}".format([OS.get_locale()]))
	log_info("Logger", "Resolution: {0}x{1}".format([int(resolution.x), int(resolution.y)]))
	log_info("Logger", "Screens: {0}".format([OS.get_screen_count()]))
	log_info("Logger", "DPI: {0}".format([OS.get_screen_dpi()]))
	log_info("Logger", "")
		
		
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
