function harb(msg) {
  var xhr = new XMLHttpRequest();
  xhr.open("POST",
    "http://localhost:6767/harbinger", 
    true); 
  xhr.send( JSON.stringify(
    { "program":"filler", 
      "id":666, "dest":"", 
      "msg":msg }) );
}
