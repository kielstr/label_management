$(function() {
	var trackIndex = 1;

	$( "#addTrack" ).click(function() {
		var html = '<fieldset>';
			html += '<legend>Track ' + trackIndex++ + ':</legend>';
			html += '<div> \
				<label>Name</label> \
				<input type="text" name=track> \
				</div> \
				<br> \
				<div> \
				<label>Artist</label> \
				<input type="text" name=track> \
				</div> \
				<br> \
				<div> \
				<label>order</label> \
				<input type="text" name=track> \
				</div> \
				<br> \
			</fieldset>';
		$( "#tasks" ).append(html);

	})
});