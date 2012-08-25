var rate = 10.0;
var host = window.location.hostname;
var lastharb = 0;

function randInt(i) {
    return Math.floor( Math.random() * i );
}

var clientID = randInt( 2000000000 );


function harb(msg) {
    var time = (new Date).getTime();
    var diff = time - lastharb
    if (diff > 1/rate) {
        lastharb = time;
	var xhr = new XMLHttpRequest();
	xhr.open("POST","http://"+host+"/harbinger", true); // don't need a response
	xhr.send( JSON.stringify({ "program":"voronoi", "id":666, "dest":"", "msg":msg }) );
    }
}

function preventDefault(e) {
	e.preventDefault();
}
document.addEventListener("touchstart", preventDefault, false);
document.addEventListener("touchmove", preventDefault, false);
document.addEventListener("touchend", preventDefault, false);
document.addEventListener("click", preventDefault, false);



var width =  window.innerWidth;
var height = window.innerHeight;
var marea = width * height;

var svg = d3.select("#chart")
  .append("svg")
    .attr("width", width)
    .attr("height", height)
    .attr("class", "PiYG")
    .on("touchmove", touchUpdate)
    .on("touchstart", touchUpdate)
    //.on("click", preventDefault)
    .on("mousedown", update)
    .on("mousemove", update);

function disableDragging() {
  if(d3.event.preventDefault)
    d3.event.preventDefault();
}

var vertices = d3.range(100).map(function(d) {
  return [Math.random() * width, Math.random() * height];
});

svg.selectAll("path")
    .data(d3.geom.voronoi(vertices))
  .enter().append("path")
    .attr("class", function(d, i) { return i ? "q" + (i % 9) + "-9" : null; })
    .attr("d", function(d) { return "M" + d.join("L") + "Z"; });

svg.selectAll("circle")
    .data(vertices.slice(1))
  .enter().append("circle")
    .attr("transform", function(d) { return "translate(" + d + ")"; })
    .attr("r", 2);
var debug = null;
function polygonArea(coordinates) {
  coordinates[coordinates.length]=coordinates[0];
  var len = coordinates.length, xsum = 0, ysum = 0;
  for (var i = 0; i < len; i++) {
    xsum += coordinates[i % len][0] * coordinates[(i+1)%len][1];
    ysum += coordinates[(i+1) % len][0] * coordinates[i%len][1];
 } 
  return (ysum-xsum)/2
}
function update() {
  disableDragging();
  vertices[0] = d3.mouse(this);
  /*
  if (debug==null) {
	debug = document.getElementById("myDebug");
  } 
  */
  dealWithVertices();
};
function touchUpdate() {
    disableDragging();
    var touches = d3.touches(this);
    if (touches.length > 0) {
        vertices[0] = touches[0];
        dealWithVertices();
    }

  /*
  if (debug==null) {
	debug = document.getElementById("myDebug");
  } 
  */

};

function dealWithVertices() {
  var geom = d3.geom.voronoi(vertices);
  var x = svg.selectAll("path")
      .data( geom
      .map(function(d) { return "M" + d.join("L") + "Z"; }))
      .filter(function(d) { return this.getAttribute("d") != d; })
      .attr("d", function(d) { return d; });
  var poly1 = geom[0];
  var parea = polygonArea(poly1); 
  var narea = parea / marea;
  var perimiter = d3.sum(x[0].map(function(d) { return d.getTotalLength(); }));
    var out = { 'area':parea, 'narea':narea, 'perimiter':perimiter, 'x':vertices[0][0], 'y':vertices[0][1], 'client':clientID };
  var sout = JSON.stringify(out);
  harb(sout);
  //debug.innerHTML = sout;
}
setTimeout(function() { window.location = "http://"+host+"/redirected"; }, 60*1000 + randInt(120*1000));
