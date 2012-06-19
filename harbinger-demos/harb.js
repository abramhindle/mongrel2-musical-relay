var host = window.location.hostname;
function harbsend(program,msg) {
	var xhr = new XMLHttpRequest();
	xhr.open("POST","http://"+host+":6767/harbinger", true); // don't need a response
	xhr.send( JSON.stringify({ "program":program, "id":666, "dest":"", "msg":msg }) );
}
