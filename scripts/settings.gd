extends Window

@onready var latitude: SpinBox = %Latitude
@onready var longitude: SpinBox = %Longitude
@onready var timezone: LineEdit = %Timezone
@onready var temperature: OptionButton = %Temperature
@onready var wind_speed: OptionButton = $VBoxContainer/Speed/WindSpeed
@onready var precipitation: OptionButton = $VBoxContainer/Precipitation/Precipitation


@onready var things = [latitude, longitude, timezone, temperature, wind_speed, precipitation]

func save_dict() -> Dictionary:
	return {
		"latitude" : latitude.value,
		"longitude" : longitude.value,
		"timezone" : timezone.text,
		"temperature" : temperature.selected,
		"wind_speed" : wind_speed.selected,
		"precipitation" : precipitation.selected,
	}


func _on_close_requested() -> void:
	cancel_changes()


func _on_show_button_pressed() -> void:
	load_data()
	show()


func _on_save_pressed() -> void:
	var settings_file = FileAccess.open("user://settings.txt", FileAccess.WRITE)

	for i in save_dict().keys():
		var value = str(save_dict()[i])
		if save_dict()[i] is String:
			value = '"' + str(save_dict()[i]) + '"'
		settings_file.store_line('{"' + str(i) + '": ' + value + '}')

	update_parent()
	get_parent().request()
	hide()


func update_parent():
	get_parent().latitude = latitude.value
	get_parent().longitude = longitude.value
	get_parent().timezone = timezone.text

	get_parent().temperature_unit = temperature.selected
	get_parent().speed_unit = wind_speed.selected
	get_parent().rain_unit = precipitation.selected


func _on_cancel_pressed() -> void:
	cancel_changes()

func cancel_changes():
	latitude.value = get_parent().latitude
	longitude.value = get_parent().longitude
	timezone.text = get_parent().timezone

	temperature.selected = get_parent().temperature_unit
	wind_speed.selected = get_parent().speed_unit
	precipitation.selected = get_parent().rain_unit

	hide()

func _ready() -> void:
	load_data()
	update_parent()

func load_data():
	if !FileAccess.file_exists("user://settings.txt"):
		return
	var data_file = FileAccess.open("user://settings.txt", FileAccess.READ)
	var i = 0
	while data_file.get_position() < data_file.get_length():
		var data = JSON.parse_string(data_file.get_line())
		var prop = ""
		match things[i].get_class():
			"SpinBox":
				prop = "value"
			"LineEdit":
				prop = "text"
			"OptionButton":
				prop = "selected"

		things[i].set(prop, data.values()[0])
		i += 1
