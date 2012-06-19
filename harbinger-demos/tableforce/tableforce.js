var selectedNode = null;

var width =  window.innerWidth;
var height = window.innerHeight;

var rows = 4;
var cols = 4;

var partitions = 4;
var maxNodes = 20;
var maxEdges = maxNodes * partitions;

var names =  ["fuzz",  "hiss","squawk","buzz" ,"growl"];
var colors = ["orange","red" ,"blue"  ,"green","purple"];


var nameToColor = {};

for (var i = 0 ; i < names.length; i++) {
    nameToColor[ names[i] ] = colors[i];
}


function randInt(i) {
    return Math.floor( Math.random() * i );
}

var clientID = randInt( 2000000000 );


function newData(x,y) {
    var index = randInt( names.length );
    var name = names[ index ];
    return {"name":name, 
            "color":colors[ index ], 
            "x":x, 
            "y":y, 
            "px":x+1, 
            "py":y+1 
           };
}

var color = d3.scale.category20();

var dataset = [],
tmpDataset = [],
i, j;

for (i = 0; i < rows; i++) {
    for (j = 0, tmpDataset = []; j < cols; j++) {
        tmpDataset.push( newData( j, i) );
        //tmpDataset.push(names[randInt(names.length)]);
    }
    dataset.push(tmpDataset);
}
	
d3.select("#viz")
    .append("table")
    .attr("id","table")
//    .attr("width",width*rows/10)
    .attr("height",height*cols/10)
    .style("border-collapse", "collapse")
    .style("border", "2px black solid")
    
    .selectAll("tr")
    .data(dataset)
    .enter().append("tr")
    
    .selectAll("td")
    .data(function(d){return d;})
    .enter().append("td")
    .style("border", "1px black solid")
    .style("padding", "10px")
    .attr("width",width/10)
    .attr("height",height/10)
    .on("mouseover", function(){d3.select(this).style("background-color", "aliceblue")}) 
    .on("mouseout", function(){d3.select(this).style("background-color", "white")}) 
    .on("mouseout", function(){d3.select(this).style("background-color", d3.select(this).data()[0].color)}) 
    .on("mousedown", animateFirstStep)
    .text(function(d){return d.name;})
    .style("font-size", "12px");


var viz = d3.select("#viz");

function test() {
    alert("test");
}


function animateFirstStep(){
    selectedNode = this;
    d3.select(this)
      .transition()            
        .delay(0)            
        .duration(1000)
        .attr("width",width/rows)
        .attr("height",height/cols)
        .style("background-color", "grey")
        .each("end", animateSecondStep);
};

function animateSecondStep(){
    d3.select(this)
      .transition()
        .duration(500)
        .attr("width",height/10)
        .attr("height",width/10)
        .style("background-color", d3.select(this).data()[0].color )
        .each("end", function() { if (this === selectedNode) { selectedNode = null; } });

    //var mydiv = document.getElementById("viz");
    //alert(mydiv.offsetWidth);
};

function harb(msg) {
    harbsend("force", msg);
}
function getOffset( el ) {
    var _x = 0;
    var _y = 0;
    while( el && !isNaN( el.offsetLeft ) && !isNaN( el.offsetTop ) ) {
        _x += el.offsetLeft - el.scrollLeft;
        _y += el.offsetTop - el.scrollTop;
        el = el.offsetParent;
    }
    return { top: _y, left: _x };
}

function mkNode( node ) {
    var off = getOffset(node);
    return {
        "__data__":{
            "name":node["__data__"].name,
            "x": off.left,
            "y": off.top,
            "px": Math.floor(off.left) + Math.floor(node.width),
            "py": Math.floor(off.top)  + Math.floor(node.height)
        }
    }
}

function showSelection() {
    if (selectedNode != null) {
        var str = JSON.stringify( { "off":getOffset(selectedNode), "client":clientID, "w":width, "h":height, "node":mkNode(selectedNode) } );
        document.getElementById("debug").innerHTML = str;
        harb( str  );
    } else {
        document.getElementById("debug").innerHTML = ""
    }
}

setInterval(showSelection,100);
