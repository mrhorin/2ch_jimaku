# ビューの共通機能をまとめたクラス
class window.BaseView

	# sectionタグを空にする
	sectionToEmpty: ->
		$("section").empty()