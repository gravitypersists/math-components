
// Graph
//
// Graph is a two-dimensional Euclidean coordinate system placed in the paper coordinates given
// It is purely abstract, meaning it does no drawing at all.
//
// *parameters*
//      topLeft and bottomRight are the paper coordinates for where the graph will be
//      rangeX and rangeY will create the graph's coordinates
//
// *methods*
//      graph.mapPoint() takes a point in graph coordinates and returns it in the paper's coordinates
//

function Graph(paper, topLeft, bottomRight, rangeX, rangeY){
    var graph = {};
    var x1 = topLeft[0],
        x2 = bottomRight[0],
        y1 = topLeft[1],
        y2 = bottomRight[1];
    var lengthOfRangeX = Math.abs(rangeX[1]-rangeX[0]),
        lengthOfRangeY = Math.abs(rangeY[1]-rangeY[0]);
    var xN = (lengthOfRangeX) ? (x2-x1)/lengthOfRangeX : 0;
    var yN = (lengthOfRangeY) ? (y2-y1)/lengthOfRangeY : 0;

    // Map point takes any point in the graph coordinates and puts them in the paper's coordinates
    graph.mapPoint = function(p) {
        return [x1+p[0]*xN-xN*rangeX[0], y2-p[1]*yN+yN*rangeY[0]];
    };
    var mapPoint = graph.mapPoint;

    return graph;
}



// Axis
//
// *parameters*
//      p1, p2: points in the paper's coordinates, each point is an arry [x, y]
//      range: the chart coordinates (ex. [-10, 10])
//      options.drawLine is by default true, but can be set to false if you want an invisible axis
//
// *methods*
//      axis.addTick(xPosition, lengthOfTick) will draw a tickline at the point given,
//      axis.addLabel() will draw a label at the point given
//      axis.mapX() takes an x-coordinate on an axis and gives you the paper coordinate
//
// *properties*
//      axis.line is the raphael path of the drawn line

function Axis(paper, p1, p2, range, options) {
    var axis = {};
    options = options || {};
    var x1 = p1[0],
        x2 = p2[0],
        y1 = p1[1],
        y2 = p2[1];
    var lengthOfRange = Math.abs(range[1]-range[0]);
    var xN = (lengthOfRange) ? (x2-x1)/lengthOfRange : 0;
    var yN = (lengthOfRange) ? (y2-y1)/lengthOfRange : 0;

    // "~~" is a double NOT bitwise operator, but for our purposes, it does the same
    // thing that Math.floor() does, but quicker. The reason we use this is because
    // SVG is pure vectors, this is to get crisp single pixel lines so that the SVG
    // doesn't interpolate a single-pixel-wide line partway into two pixels.
    // see http://kilianvalkhof.com/2010/design/the-problem-with-svg-and-canvas/
    var drawLine = (options.drawLine === undefined) ? true : options.drawLine;
    if (drawLine) {
        axis.line = paper.path("M"+(~~x1+0.5)+","+(~~y1+0.5)+"L"+(~~x2+0.5)+","+(~~y2+0.5));
    }

    //
    // addTick draws a tickline under/left of a specified point on the axis.
    //
    // length by default is 5 pixels, it can also be negative to place the tick on the other side.
    // options.centered will place the tick at the center of the line.
    //
    axis.addTick = function(X, length, options) {
        options = options || {};
        var centered = options.centered || false;
        length = length || 5;
        var point = this.mapX(X);
        var x0 = point[0],
            y0 = point[1];
        if (centered) {
            x0 -= (yN) ? length : 0;
            y0 -= (xN) ? length*xN : 0;
        }
        var xf = (yN) ? point[0]-length : point[0],
            yf = (xN) ? point[1]+length : point[1];
        var tick = paper.path("M"+(~~(x0)+0.5)+","+(~~(y0)+0.5)+"L"+(~~(xf)+0.5)+","+(~~(yf)+0.5));

        return tick;
    };

    //
    // addLabel takes a string and draws text under/left of the axis.
    //
    // distance by default is 13 pixels, it can be negative to place the label on the other side.
    // options.maxWidth sets a max width in pixels for a label before it wraps to the next line.
    // options.maxCharacters sets a max number of characters, replacing the last three with "..."
    //
    axis.addLabel = function(X, text, distance, options) {
        options = options || {};
        text = text || X;
        if (distance !== 0) { distance = distance || 13; }
        var maxWidth = options.maxWidth || false;
        var maxChar = options.maxCharacters || false;
        var point = this.mapX(X);
        var x = (yN) ? point[0]-distance : point[0], y = (xN) ? point[1]+distance : point[1];

        if (maxChar) { text = (text.length > maxChar) ? text.substring(0,maxChar-3)+("...") : text; }

        var label;
        if (maxWidth) {
            label = paper.text(x, y);
            var words = text.split(" ");
            var tempText = "";
            for (var i=0; i<words.length; i++) {
                label.attr("text", tempText + " " + words[i]);
                if (label.getBBox().width > maxWidth) {
                    tempText += "\n" + words[i];
                } else {
                    tempText += " " + words[i];
                }
            }
            label.attr("text", tempText.substring(1));
        } else {
            label = paper.text(x, y, text);
        }

        return label;
    };

    //
    // mapX takes an x-coordinate, maps it to the paper coordinate. Useful if you want to draw
    // something using paper coordinates at a specific x of the axis line.
    //
    axis.mapX = function(x) {
        var xMapped = x1+x*xN-xN*range[0];
        var yMapped = y1+x*yN-yN*range[0];
        return [xMapped, yMapped];
    };

    return axis;
}



// Chart
//
// Chart takes a graph (passed in as single argument) or creates a graph (chart.graph) and gives a bunch
// of common drawing actions you might want to do
//
// *parameters*
//      topLeft and bottomRight are the paper coordinates for where the chart's graph will be drawn
//      rangeX and rangeY will create a chart with the graph coordinates provided
//
// *methods*
//      chart.addHorizontalAxis() takes a range, and optional Y-value (default is 0) where to draw a horizontal axis
//      chart.addVerticalAxis() is the same with x-value
//      chart.addHorizontalLine() takes a y-value and range and draws a flat line
//      chart.addVerticalLine() is the same with x-value
//      chart.addBar() draws a horizontal bar (like a bar chart) with x and y values
//      chart.addColumn() draws a vertical bar with y and x values
//      chart.addFunction() draws a mathematical function on a specific range and resolution
//
// *properties*
//      chart.graph is the chart's abstract graph object

function Chart(paper, topLeftOrGraph, bottomRight, rangeX, rangeY, options){
    var chart = {};
    if (topLeftOrGraph.mapPoint) {
        chart.graph = topLeftOrGraph;
    } else {
        chart.graph = paper.graph(topLeftOrGraph, bottomRight, rangeX, rangeY);
    }
    var mapPoint = chart.graph.mapPoint;

    var lengthOfRangeX = Math.abs(rangeX[1]-rangeX[0]),
        lengthOfRangeY = Math.abs(rangeY[1]-rangeY[0]);


    chart.attr = {};

    //
    // addHorizontalAxis makes an axis on the chart and acts the same as Axis except no p1/p2 are needed
    //
    // y is an optional y-coordinate to place the axis, the default is 0
    //
    chart.addHorizontalAxis = function(range, y, options) {
        y = (y === undefined) ? rangeY[0] : y;
        range = range || rangeX;
        return addAxis([range[0], y], [range[1], y], range, options);
    };

    chart.addVerticalAxis = function(range, x, options) {
        x = (x === undefined) ? rangeX[0] : x;
        range = range || rangeY;
        return addAxis([x, range[0]], [x, range[1]], range, options);
    };

    //
    // addHorizontalLine makes a line on the chart
    //
    // y is the y-coordinate to place the line at.
    // range is the x-coordinates for which to draw the line, the default is just the range of the chart.
    //
    chart.addHorizontalLine = function(y, range) {
        range = range || rangeX;
        var point0 = mapPoint([range[0],y]);
        var pointF = mapPoint([range[1],y]);

        return drawLine(point0, pointF);
    };

    chart.addVerticalLine = function(x, range) {
        range = range || rangeY;
        var point0 = mapPoint([x, range[0]]);
        var pointF = mapPoint([x, range[1]]);

        return drawLine(point0, pointF);
    };

    chart.addLine = function(x,y) {
        return drawLine(mapPoint(x), mapPoint(y));
    }

    // addBar draws a horizontal rectangle (like a bar graph).
    //
    // y is y-axis value of where the bar will be centered on
    // length is the length of the bar (the x-axis value)
    // options.width is the width of the bar in pixels, the default is 10.
    // options.start is an offset in x-coordinates right/over the axis, the default is 0.
    // options.animationSpeed is time in ms for the bar to animate from left to right
    //
    chart.addBar = function(y, length, options) {
        options = options || {};
        var width = options.width || 10;
        var startingX = options.start || 0;
        var animationSpeed = options.animationSpeed || 0;

        var point0 = mapPoint([startingX, y]);
        var pointF = mapPoint([startingX+length, y]);
        var xLeft = ~~(point0[0])+0.5,
            xRight = ~~(pointF[0])+0.5,
            yTop = ~~(point0[1]-width/2)+0.5,
            yBottom = ~~(point0[1]+width/2)+0.5;

        var animateFromPath = "M"+xLeft+","+yBottom+"L"+xLeft+","+yBottom+"L"+xLeft+","+yTop+"L"+xLeft+","+yTop+"Z";
        var path = "M"+xLeft+","+yBottom+"L"+xRight+","+yBottom+"L"+xRight+","+yTop+"L"+xLeft+","+yTop+"Z";
        var bar;
        if (animationSpeed) {
            // This might be computationally expensive depending on how many SVG elements you have on the page
            bar = paper.path(animateFromPath).attr(chart.attr);
            var anim = Raphael.animation({path:path}, animationSpeed, "<>");
            bar.animate(anim);
        } else {
            bar = paper.path(path).attr(chart.attr);
        }

        return bar;
    };

    // same as addBar but vertical columns instead
    chart.addColumn = function(x, height, options) {
        options = options || {};
        var width = options.width || 10;
        var startingY = options.start || 0;
        var animationSpeed = options.animationSpeed || 0;

        var point0 = mapPoint([x, startingY]);
        var pointF = mapPoint([x, startingY+height]);
        var xLeft = ~~(point0[0]-width/2)+0.5,
            xRight = ~~(point0[0]+width/2)+0.5,
            yBottom = ~~(point0[1])+0.5,
            yTop = ~~(pointF[1])+0.5;

        var animateFromPath = "M"+xLeft+","+yBottom+"L"+xRight+","+yBottom+"L"+xRight+","+yBottom+"L"+xLeft+","+yBottom+"Z";
        var path = "M"+xLeft+","+yBottom+"L"+xRight+","+yBottom+"L"+xRight+","+yTop+"L"+xLeft+","+yTop+"Z";
        var column;
        if (animationSpeed) {
            // This might be computationally expensive depending on how many SVG elements you have on the page
            column = paper.path(animateFromPath).attr(chart.attr);
            var anim = Raphael.animation({path:path}, animationSpeed, "<>");
            column.animate(anim);
        } else {
            column = paper.path(path).attr(chart.attr);
        }

        return column;
    };

    //
    // addFunc is a simple way to add a mathematical function to a chart, ex: addFunc(function(x){return x*x;});
    //
    // resolution is in x-coordinates, the function is calculated in x intervals based on this
    // range is the range in graph coordinates for which this will be drawn
    // options.noclipping gives the function line the ability to be drawn outside the chart's range
    //
    chart.addFunction = function(func, resolution, range, options) {
        options = options || {};
        var noclipping = options.noclipping || false;
        resolution = resolution || lengthOfRangeX/100;
        range = range || rangeX;
        var linePaths = [];
        var x = range[0];
        while (x < range[1]) {
            var y = func(x);
            var mappedPoint = mapPoint([x, y]);
            if (!noclipping) {
                if (y >= Math.min(rangeY[0], rangeY[1]) && y <= Math.max(rangeY[0], rangeY[1])) { linePaths.push(mappedPoint[0]+","+mappedPoint[1]+"L"); }
            } else {
                linePaths.push(mappedPoint[0]+","+mappedPoint[1]+"L");
            }
            x += resolution;
        }
        var line = paper.path("M"+linePaths.join("")).attr(chart.attr);

        return line;
    };

    //
    // addText takes a string and draws it on the chart.
    //
    chart.addText = function(x, y, text, options) {
        options = options || {};
        var point = this.mapPoint([x,y])
        var x = (yN) ? point[0]-distance : point[0], y = (xN) ? point[1]+distance : point[1];

        // TODO
    };

    // private helper functions
    var addAxis = function(p1, p2, range, options) {
        var startMapped = mapPoint(p1);
        var endMapped = mapPoint(p2);
        var axis = paper.axis(startMapped, endMapped, range, options);

        return axis;
    };

    var drawLine = function(p1, p2) {
        return paper.path("M"+(~~p1[0]+0.5)+","+(~~p1[1]+0.5)+"L"+(~~p2[0]+0.5)+","+(~~p2[1]+0.5)).attr(chart.attr);
    };

    return chart;
}

Raphael.fn.graph = function (topLeft, bottomRight, rangeX, rangeY, options) {
    return new Graph(this, topLeft, bottomRight, rangeX, rangeY, options);
};

Raphael.fn.axis = function (p1, p2, range, options) {
    return new Axis(this, p1, p2, range, options);
};

Raphael.fn.chart = function (topLeft, bottomRight, rangeX, rangeY, options) {
    return new Chart(this, topLeft, bottomRight, rangeX, rangeY, options);
};

Raphael.el.addClass = function(className) {
    this.node.setAttribute("class", className);
    return this;
};
