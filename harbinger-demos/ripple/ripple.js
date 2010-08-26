/**
 * Water ripple effect.
 * Original code (Java) by Neil Wallis 
 * @link http://www.neilwallis.com/java/water.html
 * 
 * @author Sergey Chikuyonok (serge.che@gmail.com)
 * @link http://chikuyonok.ru
 */
var ripple = (function(img_src, container){
	var img = new Image,
		img_data,
		delay = 30,
                harbSend,
		width,
		height, 
		half_width, 
		half_height,
		riprad = 3,
		oldind,
		newind,
		mapind,
		
		size,
		ripplemap = [],
		last_map = [],
		ripple,
		ripple_data,
		texture,
		texture_data,
		is_running = true,
		is_disturbed = false,
		timer_id,
		
		canvas = document.createElement('canvas'),
		/** @type {CanvasRenderingContext2D} */
		ctx;
		
	function init() {
		width = img.width;
		height = img.height;
		
		half_width = width >> 1;
		half_height = height >> 1;
		
		size = width * (height + 2) * 2;
		
		canvas.width = width;
		canvas.height = height;
		
		oldind = width;
		newind = width * (height + 3);
		
		/** @type {CanvasRenderingContext2D} */
		ctx = canvas.getContext('2d');
		container.appendChild(canvas);
		
		ctx.drawImage(img, 0, 0, width, height);
		
		for (var i = 0; i < size; i++) {
			last_map[i] = ripplemap[i] = 0;
		}
		
		texture = ctx.getImageData(0, 0, width, height);
		texture_data = texture.data;
		ripple = ctx.getImageData(0, 0, width, height);
		ripple_data = ripple.data;
		
		
		canvas.addEventListener('mousemove', function(/* Event */ evt) {
			disturb(evt.offsetX || evt.layerX, evt.offsetY || evt.layerY);
		}, false);
		
		start();
	}
	
	function stop() {
		if (timer_id)
			clearInterval(timer_id);
	}
	
	function start() {
		stop();
		timer_id = setInterval(run, delay);
                setInterval(harbSend, 50);
	}
	
	function run() {
		if (is_disturbed) {
			newframe(width, height);
			ctx.putImageData(ripple, 0, 0);
		}
	}
	
	function disturb(dx, dy) {
		dx <<= 0;
		dy <<= 0;
		is_disturbed = true;
		
		for (var j = dy - riprad; j < dy + riprad; j++) {
			for (var k = dx - riprad; k < dx + riprad; k++) {
				ripplemap[oldind + (j * width) + k] += 512;
			}
		}
		
//		newframe(width, height);
//		ctx.putImageData(ripple, 0, 0);
	}
	
	function newframe() {
		var i, a, b, data, cur_pixel, new_pixel, old_data;
		
		i = oldind;
		oldind = newind;
		newind = i;
		
		i = 0;
		mapind = oldind;
		
		
		var _width = width,
			_height = height,
			_ripplemap = ripplemap,
			_mapind = mapind,
			_newind = newind,
			_last_map = last_map,
			_rd = ripple.data,
			_td = texture.data,
			_half_width = half_width,
			_half_height = half_height,
			_is_disturbed = false;
		
		for (var y = 0; y < _height; y++) {
			for (var x = 0; x < _width; x++) {
				data = (
					_ripplemap[_mapind - _width] + 
					_ripplemap[_mapind + _width] + 
					_ripplemap[_mapind - 1] + 
					_ripplemap[_mapind + 1]) >> 1;
					
				data -= _ripplemap[_newind + i];
				data -= data >> 5;
				
				_ripplemap[_newind + i] = data;

				//where data=0 then still, where data>0 then wave
				data = 1024 - data;
				
				old_data = _last_map[i];
				_last_map[i] = data;
				
				if (old_data != data) {
					//offsets
					_is_disturbed = true;
					a = (((x - _half_width) * data / 1024) << 0) + _half_width;
					b = (((y - _half_height) * data / 1024) << 0) + _half_height;
	
					//bounds check
					if (a >= _width) a = _width - 1;
					if (a < 0) a = 0;
					if (b >= _height) b = _height - 1;
					if (b < 0) b = 0;
	
					new_pixel = (a + (b * _width)) * 4;
					cur_pixel = i * 4;
					
					_rd[cur_pixel] = _td[new_pixel];
					_rd[cur_pixel + 1] = _td[new_pixel + 1];
					_rd[cur_pixel + 2] = _td[new_pixel + 2];
//					_rd[cur_pixel + 3] = _td[new_pixel + 3];
				}
				
				++_mapind;
				++i;
			}
		}
		
		mapind = _mapind;
		is_disturbed = _is_disturbed;
	}
	
	img.onload = init;
	img.src = img_src;
        var sto = {};
        function rippleToString(x) {
            var accum = 0;
            var cnt = 0;
            var n = 128; // rely on 512 image
            var dn = height / n;
            if(!sto[x]) sto[x] = [];
            var o = sto[x];
            o[0] = x;
            for (var y = 0; y < n; y++) {
                //accum += ripplemap[ dn * y * width + x ];
                accum = ( ripplemap[ dn * y * width + x ] );                
                if (o[y+1]!=accum) {
                    o[y+1] = accum;
                    cnt++;
                }
                //if (y!=0 && y%dn==0) {
                //    o.push((accum / (0.0+cnt)).toPrecision(3))
                //}
            }
            return [o.join(" "),cnt];
        }
        function harb(msg) {
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function () {
                if (xhr.readyState==4) {
                    try {
                        if (xhr.status==200) {
                            var xmldoc = xhr.responseXML;
                        }
                    } 
                    catch(e) {
                        alert('Error: ' + e.name);
                    }
                }
            };
            var strout = JSON.stringify({ "program":"ripple", "id":666, "dest":"", "msg":msg });
            xhr.open("POST","http://localhost:6767/harbinger/", true); //
            xhr.setRequestHeader("Content-type", "text/plain");
            xhr.send(strout); 
        }
        harbSend = function() {            
            var res = rippleToString(half_width/2);
            if(res[1]) harb(res[0]);
            var res = rippleToString(half_width);
            if(res[1]) harb(res[0]);
            var res = rippleToString(half_width + half_width/2);
            if(res[1]) harb(res[0]);
        };
	
	return {
            start: start,
            stop: stop,
            disturb: disturb
	}        
    });
