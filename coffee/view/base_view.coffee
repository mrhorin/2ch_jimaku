# ビューの共通機能をまとめたクラス
class window.BaseView

	# sectionタグを空にする
	sectionToEmpty: ->
		section = window.viewerObj.html.window.document.getElementById("section")
		$(section).empty()