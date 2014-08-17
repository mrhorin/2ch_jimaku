class window.ThreadView extends BaseView

	# URL部分をリンク化
	autoLink: (value) ->
		# regexpUrl = "/((h?)(ttps?:\/\/[a-zA-Z0-9.\-_@:/~?%&;=+#',()*!]+))/g; // ']))/"
		# regexpMakeLink = (all, url, h, href) ->
		# 	"<a href=\"h#{href}\" target=\"_blank\">#{url}</a>"
		# return value.replace(regexpUrl, regexpMakeLink)
		value.replace(/((http:|https:|ttp:|ttps:)\/\/[\x21-\x26\x28-\x7e]+)/gi, "<a href='$1' target='_blank'>$1</a>")

	# レスを描画
	printRes: (res)->
		$.each res, (index, value) =>
			section = window.viewerObj.html.window.document.getElementById("section")
			$(section).append(
				"""
				<div class="res">
					<div class="res-head">
						<span class="res-no">
							#{res[index][0]}
						</span>
						<span class="res-name">
							#{res[index][1]}
						</span>
						<span class="res-date">
							#{res[index][3]}
						</span>
					</div>
					<div class="res-body">
						#{@autoLink(res[index][4])}
					</div>
				</div>
				"""
			)
		# 一番下へスクロール
		# window.air.Introspector.Console.log(window.viewerObj.html)
		bottomMost = window.viewerObj.html.window.document.getElementById("bottom-most")
		$(bottomMost)[0].scrollIntoView(false)