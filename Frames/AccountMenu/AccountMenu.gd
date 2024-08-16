extends Control

@onready var StatusLabel = $StatusLabel
#@onready var popup = $Popup

var initpos = null
var total = 0

func _ready() -> void:
	Global.AccountMenuNode = self
	initpos = $Title.position
	$Label.text = "Version " + Global.VERSION + "\nOriginal Game by RaoK, Adam, & 8Bit"


func _process(_delta) -> void:
	total += _delta
	$Title.position = initpos + Vector2(0, sin(total / 2) * 10)
	
	if len($Credentials/Login/UsernameEdit.text) > 0 and len($Credentials/Login/PasswordEdit.text) > 0:
		$Credentials/Login/LoginButton.disabled = false
	else:
		$Credentials/Login/LoginButton.disabled = true
	
	if len($Credentials/Create/UsernameEdit.text) > 0 and len($Credentials/Create/PasswordEdit.text) > 0:
		$Credentials/Create/CreateButton.disabled = false
	else:
		$Credentials/Create/CreateButton.disabled = true


func _on_login_button_pressed():
	Login()

func Login():
	Server.LoginRequest($Credentials/Login/UsernameEdit.text, $Credentials/Login/PasswordEdit.text)

func _on_create_button_pressed():
	Register()

func Register():
	Server.RegisterRequest($Credentials/Create/UsernameEdit.text, $Credentials/Create/PasswordEdit.text)


func LoginAfterRegister():
	Server.LoginRequest($Credentials/Create/UsernameEdit.text, $Credentials/Create/PasswordEdit.text)
	
func _on_close_button_pressed():
	Save.saveSettings()
	get_tree().quit()


