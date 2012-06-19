var selectedNode = null;

var width =  window.innerWidth;
var height = window.innerHeight;

var rows = 4;
var cols = 4;

var partitions = 4;
var maxNodes = 20;
var maxEdges = maxNodes * partitions;

var names = ["fuzz","hiss","squawk","buzz","growl"];
var colors = ["orange","red","blue","green","purple"];


var nameToColor = {};

for (var i = 0 ; i < names.length; i++) {
    nameToColor[ names[i] ] = colors[i];
}


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

var color = d3.scale.category20();

var dataset = [],
tmpDataset = [],
i, j;

for (i = 0; i < rows; i++) {
    for (j = 0, tmpDataset = []; j < cols; j++) {
        tmpDataset.push(names[randInt(names.length)]);
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
    .on("mouseout", function(){d3.select(this).style("background-color", nameToColor[ d3.select(this).data() ])}) 
    .on("mousedown", animateFirstStep)
    .text(function(d){return d;})
    .style("font-size", "12px");


var viz = d3.select("#viz");

function test() {
    alert("test");
}


function animateFirstStep(){
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
        .duration(3000)
        .attr("width",height/10)
        .attr("height",width/10)
        .style("background-color",nameToColor[ d3.select(this).data() ]);
    //var mydiv = document.getElementById("viz");
    //alert(mydiv.offsetWidth);
};

function harb(msg) {
    harbsend("force", msg);
}

function showSelection() {
    if (selectedNode != null) {

        var str = JSON.stringify( { "client":clientID, "width":width, "height":height, "node":selectedNode } );
        document.getElementById("debug").innerHTML = str
        harb( str  );
    }
}

//setInterval(showSelection,100);
