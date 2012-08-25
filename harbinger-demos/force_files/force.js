
var selectedNode = null;
var circleRadius = 32;
var defaultCharge = -1000;
var defaultLinkDistance = 64;
var width = 500,
    height = 500;
var width =  window.innerWidth - 6;
var height = window.innerHeight - 25;

function preventDefault(e) {
	e.preventDefault();
}

document.addEventListener("touchstart", preventDefault, false);
document.addEventListener("touchmove", preventDefault, false);
document.addEventListener("touchend", preventDefault, false);
document.addEventListener("click", preventDefault, false);



var partitions = 4;
var maxNodes = 20;
var maxEdges = maxNodes * partitions;

var names = ["fuzz","hiss","squawk","buzz","growl"];

function randInt(i) {
    return Math.floor( Math.random() * i );
}

var clientID = randInt( 2000000000 );


function chooseNameAndGroup() {
    var index = randInt( names.length );
    var group = index + 1;
    var name = names[ index ];
    return {"name":name, "group":group};
}


function randomEdge(maxNodes,nodes) {
    return { "source": nodes[randInt( maxNodes )],
             "target": nodes[randInt( maxNodes )],
             "value": Math.random()
           };
}
function randomEdgeOffset(maxNodes,nodes,offset) {
    return { "source": nodes[offset+randInt( maxNodes )],
             "target": nodes[offset+randInt( maxNodes )],
             "value": Math.random()
           };
}
function randomEdgeRange(firstNode,lastNode) {
    return { "source": nodes[ firstNode + randInt( lastNode - firstNode + 1 ) ],
             "target": nodes[ firstNode + randInt( lastNode - firstNode + 1 ) ],
             "value": Math.random()
           };
}

function randomEdgeFromTo(firstNode,secondNode) {
    return { "source": firstNode,
             "target": secondNode,
             "value": Math.random() - 0.5
           };
}


function rollingEdges() {
    var links = [];
    while( links.length < maxEdges ) {
        d3.range(0, (partitions - 1)*maxNodes/partitions, 1).map( function(i) {
            links.push( randomEdgeRange( i , i + maxNodes/partitions ) );
        });    
    }
    return links
}

function randomEdges(n) {
    var links = [];
    while( links.length < n ) {
        links.push( randomEdge( maxNodes, nodes ) );
    }
    return links;
}

function treeEdges() {
    var links = [];
    for (var i = 1; i < nodes.length; i++) {
        links.push( randomEdgeFromTo( nodes[i] , nodes[ Math.floor( i/2  ) ] ) );
    }
    return links;
}

var nodes = d3.range(0, maxNodes, 1 ).map( chooseNameAndGroup );
//var links = randomEdges();
var links = [].concat( randomEdges(1 + randInt(maxEdges/10)), treeEdges() );


//    var newlinks = d3.range(0, maxEdges / 3 , 1 ).map( function() { return randomEdgeOffset( maxNodes / 3, nodes, i * maxEdges / 3 ) }  );
//    var conlinks = d3.range(0, randInt(4)+1 , 1 ).map( function() { return randomEdge( maxNodes * (i+1) / 3, nodes ) }  );
//    links.append(newlinks);
//    links.appned(conlinks);
//}

var color = d3.scale.category20();

var force = d3.layout.force()
    .charge( defaultCharge )
    .linkDistance( defaultLinkDistance )
    .size([width, height]);

var svg = d3.select("#chart").append("svg")
    .attr("width", width)
    .attr("height", height);


//d3.json("music.json", function(json) {

  force
      .nodes(nodes)
      .links(links)
      .start();

  var link = svg.selectAll("line.link")
      .data(links)
    .enter().append("line")
      .attr("class", "link")
      .style("stroke", "yellow")
      .style("stroke-width", function(d) { return Math.sqrt(d.value); });

  var node = svg.selectAll("circle.node")
      .data(nodes)
    .enter().append("circle")
      .attr("class", "node")
      .attr("r", circleRadius)
      .style("stroke", "yellow")
      .style("fill", function(d) { return color(d.group); })
    .call(force.drag);
    svg.selectAll("circle.node")
      .data(nodes)
      .call(function () {
        var old = this.on("mousedown");
        var f = function(d) {
            if(d3.event.preventDefault)
                d3.event.preventDefault();
            selectedNode = this;
            if (typeof old == "function") {
                return old(d);
            }
        };
        this.on("mousedown", f );
        this.on("touchstart", f );
    });
/*
  var node = svg.selectAll("circle.node")
    .data(nodes)
    .enter()
    .call(function () {
        
    });
*/
  
  node.append("title")
      .text(function(d) { return d.name; });

  force.on("tick", function() {
    link.attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });

    node.attr("cx", function(d) { return d.x; })
        .attr("cy", function(d) { return d.y; });
  });
//});

function harb(msg) {
    harbsend("force", msg);
}

function showSelection() {
    //if (selectedNode != null) {        
    //    document.getElementById("debug").innerHTML = JSON.stringify( selectedNode );
    //} else {
    //    document.getElementById("debug").innerHTML = "NULL";
    //}
    if (selectedNode != null) {
        var sd = selectedNode["__data__"];
        var node = {
            "__data__":{
                "name":sd.name,
                "fixed":sd.fixed,
                "x":sd.x,
                "y":sd.y,
                "px":sd.px,
                "py":sd.py
            }
        };
        var str = JSON.stringify( { "client":clientID, "width":width, "height":height, "node":node } );
        //document.getElementById("debug").innerHTML = str
        harb( str  );
    }
}

setInterval(showSelection,100);
var host = window.location.hostname;
setTimeout(function() { window.location = "http://"+host+"/redirected"; }, 60*1000 + randInt(120*1000));
