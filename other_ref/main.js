/*
cyclic cellular automaton
*/
$(document).ready(function () {
    var canvas = $('#canvas')[0];
    var ctx = canvas.getContext('2d');
    var colors = [
        {r: 255, g: 0, b: 85, a: 255},   // dark red
        {r: 255, g: 0, b: 0, a: 255},    // red
        {r: 255, g: 85,b: 0, a: 255},    // orange
        {r: 255, g: 170, b: 0, a: 255},  // light orange
        {r: 255, g: 255,b: 0, a: 255},   // yellow
        {r: 170, g: 255, b: 0, a: 255},  // light green
        {r: 85, g: 255, b: 0, a: 255},   // green
        {r: 0, g: 255, b: 0, a: 255},    // darkish green
        {r: 0, g: 255, b: 255, a: 255},  // cyan
        {r: 0, g: 0, b: 102, a: 255},    // lighter blue
        {r: 0, g: 102, b: 255, a: 255},  // light blue
        {r: 0, g: 0, b: 255, a: 255},    // blue
        {r: 170, g: 0, b: 255, a: 255},  // dark purple
        {r: 85, g: 0, b: 255, a: 255},   // purple
        {r: 255, g: 0, b: 255, a: 255},  // magenta
        {r: 255, g: 0, b: 170, a: 255}   // dark magenta
    ];
    var n = colors.length - 1;
    var cols = $('#canvas').width();
    var rows = $('#canvas').height();
    var image;
    var newCells = [];
    var cells = [];
    var interval = 50;
    var intervalId;
    var generation = 0;
    var pixelChanges = 0;

    $('#startButton').click(function (e) {
        var params = getParams();
        clearInterval(intervalId);
        intervalId = setInterval(function () {
            demonLoop(params);
        },
        interval);
    });

    $('#stopButton').click(function (e) {
        clearInterval(intervalId);
    });

    $('#randomizeButton').click(function (e) {
        clearInterval(intervalId);
        generation = 0;
        pixelChanges = 0;
        initCells(ctx);
        drawCells(ctx);
        displayGeneration(generation);
    });

    initCells(ctx);
    drawCells(ctx);

    function getParams() {
        var threshold = $('#threshold').val();
        if ($('#neighborhood').val() === 'vonneumann') {
            return {'predicate': vonNeumannPredicate, 'threshold': 1};
        }

        return {'predicate': moorePredicate, 'threshold': 1};
    }

    function getRandomColorIndex() {
        var min = 0;
        var max = n;
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    function cloneArray(a) {
        // TODO: only works for 2 dimensional arrays. Make recursive to handle higher dimensions
        var b = [];
        for (var i = 0; i < a.length; i++) {
            b[i] = a[i].slice(0);
        }

        return b;
    }

    function initCells(ctx) {
        if (!image) {
            image = ctx.createImageData(cols, rows);
        }
        var d = image.data;
        var i = 0;

        for (var x = 0; x < cols; x++) {
            cells[x] = [];
            for (var y = 0; y < rows; y++) {
                cells[x][y] = getRandomColorIndex();
                color = colors[cells[x][y]];
                d[i] = color.r;
                d[i + 1] = color.g;
                d[i + 2] = color.b;
                d[i + 3] = color.a;
                i += 4;
            }
        }
        ctx.putImageData(image, 0, 0);
        newCells = cloneArray(cells);
    }

    function drawCells(ctx) {
        var d = image.data;
        var i = 0;

        for (var x = 0; x < cols; x++) {
            for (var y = 0; y < rows; y++) {
                if (newCells[x][y] !== cells[x][y]) {
                    color = colors[newCells[x][y]];
                    d[i] = color.r;
                    d[i + 1] = color.g;
                    d[i + 2] = color.b;
                    d[i + 3] = color.a;
                    cells[x][y] = newCells[x][y];
                }
                i += 4;
            }
        }
        ctx.putImageData(image, 0, 0);
    }

    function calculateCells(predicate, threshold) {
        var cellColor;
        var x1, x2, y1, y2;

        for (var x = 0; x < cols; x++) {
            for (var y = 0; y < rows; y++) {
                cellColor = cells[x][y] !== n ? cells[x][y] + 1 : 0;

                x1 = x === 0 ? cols - 1 : x - 1;
                y1 = y === 0 ? rows - 1 : y - 1;
                x2 = x === cols - 1 ? 0 : x + 1;
                y2 = y === rows - 1 ? 0 : y + 1;

                if (predicate(x, x1, x2, y, y1, y2, cellColor, threshold)) {
                    newCells[x][y] = cellColor;
                    pixelChanges++;
                }
            }
        }
    }

    function vonNeumannPredicate(x, x1, x2, y, y1, y2, c, threshold) {
        // von Neumann neighborhood
        if (!threshold || threshold === 1) {
            return cells[x1][y] === c ||
                cells[x][y1] === c ||
                cells[x2][y] === c ||
                cells[x][y2] === c;
        } else {
            var weight = (cells[x1][y] === c) +
                (cells[x][y1] === c) +
                (cells[x2][y] === c) +
                (cells[x][y2] === c);
            
            return weight >= threshold;
        }
    }

    function moorePredicate(x, x1, x2, y, y1, y2, c, threshold) {
        // Moore neighborhood
        if (!threshold || threshold === 1) {
            return cells[x1][y1] === c ||
                cells[x][y1] === c ||
                cells[x2][y1] === c ||
                cells[x2][y] === c ||
                cells[x2][y2] === c ||
                cells[x][y2] === c ||
                cells[x1][y2] === c ||
                cells[x1][y] === c;
        } else {
            var weight = (cells[x1][y1] === c) +
                (cells[x][y1] === c) +
                (cells[x2][y1] === c) +
                (cells[x2][y] === c) +
                (cells[x2][y2] === c) +
                (cells[x][y2] === c) +
                (cells[x1][y2] === c) +
                (cells[x1][y] === c);
            
            return weight >= threshold;
        }
    }

    function displayGeneration(generation) {
        //$('#generation').text(generation + ' ' + pixelChanges);
        $('#generation').text(generation);
    }

    function demonLoop(params) {
        calculateCells(params.predicate, params.threshold);
        drawCells(ctx);
        displayGeneration(++generation);
    }

});

/* old pixel-by-pixel drawing...MUCH slower */
var OLD_colors = [
    '#000000', // black
'#00ffff', // aqua
'#0000ff', // blue
'#ff00ff', // fuschia
'#008000', // green
'#00ff00', // lime
'#800000', // maroon
'#000080', // navy
'#808000', // olive
'#800080', // purple
'#ff0000', // red
'#c0c0c0', // silver
'#008080', // teal
'#808080', // gray
'#ffff00', // yellow
'#ffffff' // white
];

function OLD_initCells() {
    //new_cells = new Array(rows);
    for (var x = 0; x < cols; x++) {
        //new_cells[x] = new Array(cols);
        new_cells[x] = [];
        for (var y = 0; y < rows; y++) {
            new_cells[x][y] = getRandomColorIndex();
            ctx.fillStyle = colors[new_cells[x][y]];
            ctx.fillRect(x * cs, y * cs, cs, cs);
        }
    }
    cells = cloneArray(new_cells);
}

function OLD_drawCells() {
    for (var x = 0; x < cols; x++) {
        for (var y = 0; y < rows; y++) {
            if (new_cells[x][y] != cells[x][y]) {
                ctx.fillStyle = colors[new_cells[x][y]];
                ctx.fillRect(x * cs, y * cs, cs, cs);
                //cells[x][y] = new_cells[x][y];
            }
        }
    }
    cells = cloneArray(new_cells);
}
/* old color palette */
    var colors = [
        {r: 0, g: 0, b: 0, a: 255}, // black
        {r: 0, g: 255,b: 255, a: 255}, // aqua
        {r: 0, g: 0, b: 255, a: 255}, // blue
        {r: 255, g: 0,b: 255, a: 255}, // fuschia
        {r: 0, g: 128, b: 0, a: 255}, // green
        {r: 0, g: 255, b: 0, a: 255}, // lime
        {r: 128, g: 0, b: 0, a: 255}, // maroon
        {r: 0, g: 0, b: 128, a: 255}, // navy
        {r: 128, g: 128, b: 0, a: 255}, // olive
        {r: 128, g: 0, b: 128, a: 255}, // purple
        {r: 255, g: 0, b: 0, a: 255}, // red
        {r: 192, g: 192, b: 192, a: 255}, // silver
        {r: 0, g: 128, b: 128, a: 255}, // teal
        {r: 128, g: 128, b: 128, a: 255}, // gray
        {r: 255, g: 255, b: 0, a: 255}, // yellow
        {r: 255, g: 255, b: 255, a: 255} // white
    ];