class_name CommissionStat
extends Resource

@export var id: String # id of the commissioner
@export var title: String 
@export_multiline var desc: String

@export var day: int
@export var assets: Array[FileResource]

@export var desired_judgement: DesiredJudgement

@export var required_commissions: Array[CommissionStat]
