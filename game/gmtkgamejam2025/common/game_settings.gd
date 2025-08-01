class_name GameSettings
extends Node

## ---
## GAME SETTINGS
## A collection of static methods for general setting loading/saving using config files
## ---
## Last edited: July 31st, 2025
## ---

## Different settings categories, a dictionary of dictionaries
## Will use the "default" category if no category is supplied
static var settings_categories: Dictionary[String, Dictionary] = {}

const DEFAULT_CATEGORY_NAME := "default"
const SETTINGS_PATH := "user://settings.cfg"

## Set setting
## Default to "default" category...
static func set_setting(key: String, value: Variant, section: String = DEFAULT_CATEGORY_NAME) -> void:
	var settings: Dictionary[String, Variant] = settings_categories.get(section, {})
	settings.set(key, value)
	settings_categories.set(key, value)

## Get setting
## Returns default if section or key doesn't exist
static func get_setting(key: String, value: Variant, default: Variant = null, section: String = DEFAULT_CATEGORY_NAME) -> Variant:
	if settings_categories.has(section):
		if settings_categories[section].has(key):
			return settings_categories.get(key, default)
	return default

## Save EVERYTHING in settings_categories to config file
static func save_to_config() -> void:
	var config = ConfigFile.new()
	
	## Save each category...
	for category: String in settings_categories.keys():
		var settings: Dictionary[String, Variant] = settings_categories[category]
		for key: String in settings:
			config.set_value(category, key, settings[key])
	
	config.save(SETTINGS_PATH)

## Load EVERYTHING from the given path to a config file into settings_categories
static func load_from_config(path: String = SETTINGS_PATH) -> void:
	var config: ConfigFile = ConfigFile.new()
	
	## Load data from a file.
	var err = config.load(path)
	
	## If the file didn't load, ignore it.
	if err != OK:
		print("Warning! An error occured while trying to load settings at \"" + SETTINGS_PATH + "\", so no settings have been loaded.")
		return

	## For each section...
	for section: String in config.get_sections():
		if not settings_categories.has(section):
			## Add if we don't have...
			settings_categories.set(section, {})
		
		## Get reference to that section
		var settings: Dictionary[String, Variant] = settings_categories[section]
		
		## Load key-values into there...
		for key: String in config.get_section_keys(section):
			var value = config.get_value(section, key)
			if value != null:
				settings.set(key, value)
		
		settings_categories.set(section, settings)
