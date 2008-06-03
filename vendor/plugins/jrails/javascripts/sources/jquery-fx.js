;(function($) {

	$.effects = $.effects || {}; //Add the 'ec' scope

	$.extend($.effects, {
		save: function(el, set) {
			for(var i=0;i<set.length;i++) {
				if(set[i] !== null) $.data(el[0], "ec.storage."+set[i], el[0].style[set[i]]);
			}
		},
		restore: function(el, set) {
			for(var i=0;i<set.length;i++) {
				if(set[i] !== null) el.css(set[i], $.data(el[0], "ec.storage."+set[i]));
			}
		},
		setMode: function(el, mode) {
			if (mode == 'toggle') mode = el.is(':hidden') ? 'show' : 'hide'; // Set for toggle
			return mode;
		},
		getBaseline: function(origin, original) { // Translates a [top,left] array into a baseline value
			// this should be a little more flexible in the future to handle a string & hash
			var y, x;
			switch (origin[0]) {
				case 'top': y = 0; break;
				case 'middle': y = 0.5; break;
				case 'bottom': y = 1; break;
				default: y = origin[0] / original.height;
			};
			switch (origin[1]) {
				case 'left': x = 0; break;
				case 'center': x = 0.5; break;
				case 'right': x = 1; break;
				default: x = origin[1] / original.width;
			};
			return {x: x, y: y};
		},
		createWrapper: function(el) {
			if (el.parent().attr('id') == 'fxWrapper')
				return el;
			var props = {width: el.outerWidth({margin:true}), height: el.outerHeight({margin:true}), 'float': el.css('float')};
			el.wrap('<div id="fxWrapper" style="font-size:100%;background:transparent;border:none;margin:0;padding:0"></div>');
			var wrapper = el.parent();
			if (el.css('position') == 'static'){
				wrapper.css({position: 'relative'});
				el.css({position: 'relative'});
			} else {
				var top = parseInt(el.css('top'), 10); if(isNaN(top)) top = 'auto';
				var left = parseInt(el.css('left'), 10); if(isNaN(top)) left = 'auto';
				wrapper.css({ position: el.css('position'), top: top, left: left, zIndex: el.css('z-index') }).show();
				el.css({position: 'relative', top:0, left:0});
			}
			wrapper.css(props);
			return wrapper;
		},
		removeWrapper: function(el) {
			if (el.parent().attr('id') == 'fxWrapper')
				return el.parent().replaceWith(el);
			return el;
		},
		setTransition: function(el, list, factor, val) {
			val = val || {};
			$.each(list,function(i, x){
				unit = el.cssUnit(x);
				if (unit[0] > 0) val[x] = unit[0] * factor + unit[1];
			});
			return val;
		},
		animateClass: function(value, duration, easing, callback) {

			var cb = (typeof easing == "function" ? easing : (callback ? callback : null));
			var ea = (typeof easing == "object" ? easing : null);

			return this.each(function() {

				var offset = {}; var that = $(this); var oldStyleAttr = that.attr("style") || '';
				if(typeof oldStyleAttr == 'object') oldStyleAttr = oldStyleAttr["cssText"]; /* Stupidly in IE, style is a object.. */
				if(value.toggle) { that.hasClass(value.toggle) ? value.remove = value.toggle : value.add = value.toggle; }

				//Let's get a style offset
				var oldStyle = $.extend({}, (document.defaultView ? document.defaultView.getComputedStyle(this,null) : this.currentStyle));
				if(value.add) that.addClass(value.add); if(value.remove) that.removeClass(value.remove);
				var newStyle = $.extend({}, (document.defaultView ? document.defaultView.getComputedStyle(this,null) : this.currentStyle));
				if(value.add) that.removeClass(value.add); if(value.remove) that.addClass(value.remove);

				// The main function to form the object for animation
				for(var n in newStyle) {
					if( typeof newStyle[n] != "function" && newStyle[n] /* No functions and null properties */
					&& n.indexOf("Moz") == -1 && n.indexOf("length") == -1 /* No mozilla spezific render properties. */
					&& newStyle[n] != oldStyle[n] /* Only values that have changed are used for the animation */
					&& (n.match(/color/i) || (!n.match(/color/i) && !isNaN(parseInt(newStyle[n],10)))) /* Only things that can be parsed to integers or colors */
					&& (oldStyle.position != "static" || (oldStyle.position == "static" && !n.match(/left|top|bottom|right/))) /* No need for positions when dealing with static positions */
					) offset[n] = newStyle[n];
				}

				that.animate(offset, duration, ea, function() { // Animate the newly constructed offset object
					// Change style attribute back to original. For stupid IE, we need to clear the damn object.
					if(typeof $(this).attr("style") == 'object') { $(this).attr("style")["cssText"] = ""; $(this).attr("style")["cssText"] = oldStyleAttr; } else $(this).attr("style", oldStyleAttr);
					if(value.add) $(this).addClass(value.add); if(value.remove) $(this).removeClass(value.remove);
					if(cb) cb.apply(this, arguments);
				});

			});
		}
	});

	//Extend the methods of jQuery
	$.fn.extend({
		//Save old methods
		_show: $.fn.show,
		_hide: $.fn.hide,
		__toggle: $.fn.toggle,
		_addClass: $.fn.addClass,
		_removeClass: $.fn.removeClass,
		_toggleClass: $.fn.toggleClass,
		// New ec methods
		effect: function(fx,o,speed,callback) {
			return $.effects[fx] ? $.effects[fx].call(this, {method: fx, options: o || {}, duration: speed, callback: callback }) : null;
		},
		show: function() {
			if(!arguments[0] || (arguments[0].constructor == Number || /(slow|normal|fast)/.test(arguments[0])))
				return this._show.apply(this, arguments);
			else {
				var o = arguments[1] || {}; o['mode'] = 'show';
				return this.effect.apply(this, [arguments[0], o, arguments[2] || o.duration, arguments[3] || o.callback]);
			}
		},
		hide: function() {
			if(!arguments[0] || (arguments[0].constructor == Number || /(slow|normal|fast)/.test(arguments[0])))
				return this._hide.apply(this, arguments);
			else {
				var o = arguments[1] || {}; o['mode'] = 'hide';
				return this.effect.apply(this, [arguments[0], o, arguments[2] || o.duration, arguments[3] || o.callback]);
			}
		},
		toggle: function(){
			if(!arguments[0] || (arguments[0].constructor == Number || /(slow|normal|fast)/.test(arguments[0])) || (arguments[0].constructor == Function))
				return this.__toggle.apply(this, arguments);
			else {
				var o = arguments[1] || {}; o['mode'] = 'toggle';
				return this.effect.apply(this, [arguments[0], o, arguments[2] || o.duration, arguments[3] || o.callback]);
			}
		},
		addClass: function(classNames,speed,easing,callback) {
			return speed ? $.effects.animateClass.apply(this, [{ add: classNames },speed,easing,callback]) : this._addClass(classNames);
		},
		removeClass: function(classNames,speed,easing,callback) {
			return speed ? $.effects.animateClass.apply(this, [{ remove: classNames },speed,easing,callback]) : this._removeClass(classNames);
		},
		toggleClass: function(classNames,speed,easing,callback) {
			return speed ? $.effects.animateClass.apply(this, [{ toggle: classNames },speed,easing,callback]) : this._toggleClass(classNames);
		},
		morph: function(remove,add,speed,easing,callback) {
			return $.effects.animateClass.apply(this, [{ add: add, remove: remove },speed,easing,callback]);
		},
		switchClass: function() {
			return this.morph.apply(this, arguments);
		},
		// helper functions
		cssUnit: function(key) {
			var style = this.css(key), val = [];
			$.each( ['em','px','%','pt'], function(i, unit){
				if(style.indexOf(unit) > 0)
					val = [parseFloat(style), unit];
			});
			return val;
		}
	});

	/*
	 * jQuery Color Animations
	 * Copyright 2007 John Resig
	 * Released under the MIT and GPL licenses.
	 */

		// We override the animation for all of these color styles
		jQuery.each(['backgroundColor', 'borderBottomColor', 'borderLeftColor', 'borderRightColor', 'borderTopColor', 'color', 'outlineColor'], function(i,attr){
				jQuery.fx.step[attr] = function(fx){
						if ( fx.state == 0 ) {
								fx.start = getColor( fx.elem, attr );
								fx.end = getRGB( fx.end );
						}

						fx.elem.style[attr] = "rgb(" + [
								Math.max(Math.min( parseInt((fx.pos * (fx.end[0] - fx.start[0])) + fx.start[0]), 255), 0),
								Math.max(Math.min( parseInt((fx.pos * (fx.end[1] - fx.start[1])) + fx.start[1]), 255), 0),
								Math.max(Math.min( parseInt((fx.pos * (fx.end[2] - fx.start[2])) + fx.start[2]), 255), 0)
						].join(",") + ")";
				}
		});

		// Color Conversion functions from highlightFade
		// By Blair Mitchelmore
		// http://jquery.offput.ca/highlightFade/

		// Parse strings looking for color tuples [255,255,255]
		function getRGB(color) {
				var result;

				// Check if we're already dealing with an array of colors
				if ( color && color.constructor == Array && color.length == 3 )
						return color;

				// Look for rgb(num,num,num)
				if (result = /rgb\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*\)/.exec(color))
						return [parseInt(result[1]), parseInt(result[2]), parseInt(result[3])];

				// Look for rgb(num%,num%,num%)
				if (result = /rgb\(\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*\)/.exec(color))
						return [parseFloat(result[1])*2.55, parseFloat(result[2])*2.55, parseFloat(result[3])*2.55];

				// Look for #a0b1c2
				if (result = /#([a-fA-F0-9]{2})([a-fA-F0-9]{2})([a-fA-F0-9]{2})/.exec(color))
						return [parseInt(result[1],16), parseInt(result[2],16), parseInt(result[3],16)];

				// Look for #fff
				if (result = /#([a-fA-F0-9])([a-fA-F0-9])([a-fA-F0-9])/.exec(color))
						return [parseInt(result[1]+result[1],16), parseInt(result[2]+result[2],16), parseInt(result[3]+result[3],16)];

				// Look for rgba(0, 0, 0, 0) == transparent in Safari 3
				if (result = /rgba\(0, 0, 0, 0\)/.exec(color))
						return colors['transparent']

				// Otherwise, we're most likely dealing with a named color
				return colors[jQuery.trim(color).toLowerCase()];
		}

		function getColor(elem, attr) {
				var color;

				do {
						color = jQuery.curCSS(elem, attr);

						// Keep going until we find an element that has color, or we hit the body
						if ( color != '' && color != 'transparent' || jQuery.nodeName(elem, "body") )
								break;

						attr = "backgroundColor";
				} while ( elem = elem.parentNode );

				return getRGB(color);
		};

		// Some named colors to work with
		// From Interface by Stefan Petre
		// http://interface.eyecon.ro/

		var colors = {
				aqua:[0,255,255],
				azure:[240,255,255],
				beige:[245,245,220],
				black:[0,0,0],
				blue:[0,0,255],
				brown:[165,42,42],
				cyan:[0,255,255],
				darkblue:[0,0,139],
				darkcyan:[0,139,139],
				darkgrey:[169,169,169],
				darkgreen:[0,100,0],
				darkkhaki:[189,183,107],
				darkmagenta:[139,0,139],
				darkolivegreen:[85,107,47],
				darkorange:[255,140,0],
				darkorchid:[153,50,204],
				darkred:[139,0,0],
				darksalmon:[233,150,122],
				darkviolet:[148,0,211],
				fuchsia:[255,0,255],
				gold:[255,215,0],
				green:[0,128,0],
				indigo:[75,0,130],
				khaki:[240,230,140],
				lightblue:[173,216,230],
				lightcyan:[224,255,255],
				lightgreen:[144,238,144],
				lightgrey:[211,211,211],
				lightpink:[255,182,193],
				lightyellow:[255,255,224],
				lime:[0,255,0],
				magenta:[255,0,255],
				maroon:[128,0,0],
				navy:[0,0,128],
				olive:[128,128,0],
				orange:[255,165,0],
				pink:[255,192,203],
				purple:[128,0,128],
				violet:[128,0,128],
				red:[255,0,0],
				silver:[192,192,192],
				white:[255,255,255],
				yellow:[255,255,0],
				transparent: [255,255,255]
		};
		

/*
 * jQuery Easing v1.3 - http://gsgd.co.uk/sandbox/jquery/easing/
 *
 * Uses the built in easing capabilities added In jQuery 1.1
 * to offer multiple easing options
 *
 * TERMS OF USE - jQuery Easing
 * 
 * Open source under the BSD License. 
 * 
 * Copyright © 2008 George McGinley Smith
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 * 
 * Redistributions of source code must retain the above copyright notice, this list of 
 * conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list 
 * of conditions and the following disclaimer in the documentation and/or other materials 
 * provided with the distribution.
 * 
 * Neither the name of the author nor the names of contributors may be used to endorse 
 * or promote products derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 *  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 *  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED 
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
 * OF THE POSSIBILITY OF SUCH DAMAGE. 
 *
*/

// t: current time, b: begInnIng value, c: change In value, d: duration
jQuery.easing['jswing'] = jQuery.easing['swing'];

jQuery.extend( jQuery.easing,
{
	def: 'easeOutQuad',
	swing: function (x, t, b, c, d) {
		//alert(jQuery.easing.default);
		return jQuery.easing[jQuery.easing.def](x, t, b, c, d);
	},
	easeInQuad: function (x, t, b, c, d) {
		return c*(t/=d)*t + b;
	},
	easeOutQuad: function (x, t, b, c, d) {
		return -c *(t/=d)*(t-2) + b;
	},
	easeInOutQuad: function (x, t, b, c, d) {
		if ((t/=d/2) < 1) return c/2*t*t + b;
		return -c/2 * ((--t)*(t-2) - 1) + b;
	},
	easeInCubic: function (x, t, b, c, d) {
		return c*(t/=d)*t*t + b;
	},
	easeOutCubic: function (x, t, b, c, d) {
		return c*((t=t/d-1)*t*t + 1) + b;
	},
	easeInOutCubic: function (x, t, b, c, d) {
		if ((t/=d/2) < 1) return c/2*t*t*t + b;
		return c/2*((t-=2)*t*t + 2) + b;
	},
	easeInQuart: function (x, t, b, c, d) {
		return c*(t/=d)*t*t*t + b;
	},
	easeOutQuart: function (x, t, b, c, d) {
		return -c * ((t=t/d-1)*t*t*t - 1) + b;
	},
	easeInOutQuart: function (x, t, b, c, d) {
		if ((t/=d/2) < 1) return c/2*t*t*t*t + b;
		return -c/2 * ((t-=2)*t*t*t - 2) + b;
	},
	easeInQuint: function (x, t, b, c, d) {
		return c*(t/=d)*t*t*t*t + b;
	},
	easeOutQuint: function (x, t, b, c, d) {
		return c*((t=t/d-1)*t*t*t*t + 1) + b;
	},
	easeInOutQuint: function (x, t, b, c, d) {
		if ((t/=d/2) < 1) return c/2*t*t*t*t*t + b;
		return c/2*((t-=2)*t*t*t*t + 2) + b;
	},
	easeInSine: function (x, t, b, c, d) {
		return -c * Math.cos(t/d * (Math.PI/2)) + c + b;
	},
	easeOutSine: function (x, t, b, c, d) {
		return c * Math.sin(t/d * (Math.PI/2)) + b;
	},
	easeInOutSine: function (x, t, b, c, d) {
		return -c/2 * (Math.cos(Math.PI*t/d) - 1) + b;
	},
	easeInExpo: function (x, t, b, c, d) {
		return (t==0) ? b : c * Math.pow(2, 10 * (t/d - 1)) + b;
	},
	easeOutExpo: function (x, t, b, c, d) {
		return (t==d) ? b+c : c * (-Math.pow(2, -10 * t/d) + 1) + b;
	},
	easeInOutExpo: function (x, t, b, c, d) {
		if (t==0) return b;
		if (t==d) return b+c;
		if ((t/=d/2) < 1) return c/2 * Math.pow(2, 10 * (t - 1)) + b;
		return c/2 * (-Math.pow(2, -10 * --t) + 2) + b;
	},
	easeInCirc: function (x, t, b, c, d) {
		return -c * (Math.sqrt(1 - (t/=d)*t) - 1) + b;
	},
	easeOutCirc: function (x, t, b, c, d) {
		return c * Math.sqrt(1 - (t=t/d-1)*t) + b;
	},
	easeInOutCirc: function (x, t, b, c, d) {
		if ((t/=d/2) < 1) return -c/2 * (Math.sqrt(1 - t*t) - 1) + b;
		return c/2 * (Math.sqrt(1 - (t-=2)*t) + 1) + b;
	},
	easeInElastic: function (x, t, b, c, d) {
		var s=1.70158;var p=0;var a=c;
		if (t==0) return b;  if ((t/=d)==1) return b+c;  if (!p) p=d*.3;
		if (a < Math.abs(c)) { a=c; var s=p/4; }
		else var s = p/(2*Math.PI) * Math.asin (c/a);
		return -(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;
	},
	easeOutElastic: function (x, t, b, c, d) {
		var s=1.70158;var p=0;var a=c;
		if (t==0) return b;  if ((t/=d)==1) return b+c;  if (!p) p=d*.3;
		if (a < Math.abs(c)) { a=c; var s=p/4; }
		else var s = p/(2*Math.PI) * Math.asin (c/a);
		return a*Math.pow(2,-10*t) * Math.sin( (t*d-s)*(2*Math.PI)/p ) + c + b;
	},
	easeInOutElastic: function (x, t, b, c, d) {
		var s=1.70158;var p=0;var a=c;
		if (t==0) return b;  if ((t/=d/2)==2) return b+c;  if (!p) p=d*(.3*1.5);
		if (a < Math.abs(c)) { a=c; var s=p/4; }
		else var s = p/(2*Math.PI) * Math.asin (c/a);
		if (t < 1) return -.5*(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;
		return a*Math.pow(2,-10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )*.5 + c + b;
	},
	easeInBack: function (x, t, b, c, d, s) {
		if (s == undefined) s = 1.70158;
		return c*(t/=d)*t*((s+1)*t - s) + b;
	},
	easeOutBack: function (x, t, b, c, d, s) {
		if (s == undefined) s = 1.70158;
		return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;
	},
	easeInOutBack: function (x, t, b, c, d, s) {
		if (s == undefined) s = 1.70158; 
		if ((t/=d/2) < 1) return c/2*(t*t*(((s*=(1.525))+1)*t - s)) + b;
		return c/2*((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2) + b;
	},
	easeInBounce: function (x, t, b, c, d) {
		return c - jQuery.easing.easeOutBounce (x, d-t, 0, c, d) + b;
	},
	easeOutBounce: function (x, t, b, c, d) {
		if ((t/=d) < (1/2.75)) {
			return c*(7.5625*t*t) + b;
		} else if (t < (2/2.75)) {
			return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
		} else if (t < (2.5/2.75)) {
			return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
		} else {
			return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
		}
	},
	easeInOutBounce: function (x, t, b, c, d) {
		if (t < d/2) return jQuery.easing.easeInBounce (x, t*2, 0, c, d) * .5 + b;
		return jQuery.easing.easeOutBounce (x, t*2-d, 0, c, d) * .5 + c*.5 + b;
	}
});

/*
 *
 * TERMS OF USE - EASING EQUATIONS
 * 
 * Open source under the BSD License. 
 * 
 * Copyright © 2001 Robert Penner
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 * 
 * Redistributions of source code must retain the above copyright notice, this list of 
 * conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list 
 * of conditions and the following disclaimer in the documentation and/or other materials 
 * provided with the distribution.
 * 
 * Neither the name of the author nor the names of contributors may be used to endorse 
 * or promote products derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 *  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 *  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED 
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
 * OF THE POSSIBILITY OF SUCH DAMAGE. 
 *
 */

})(jQuery);

;(function($) {
	
	$.effects.blind = function(o) {

		return this.queue(function() {

			// Create element
			var el = $(this), props = ['position','top','left'];
			
			// Set options
			var mode = $.effects.setMode(el, o.options.mode || 'hide'); // Set Mode
			var direction = o.options.direction || 'vertical'; // Default direction
			
			// Adjust
			$.effects.save(el, props); el.show(); // Save & Show
			var wrapper = $.effects.createWrapper(el).css({overflow:'hidden'}); // Create Wrapper
			var ref = (direction == 'vertical') ? 'height' : 'width';
			var distance = (direction == 'vertical') ? wrapper.height() : wrapper.width();
			if(mode == 'show') wrapper.css(ref, 0); // Shift
			
			// Animation
			var animation = {};
			animation[ref] = mode == 'show' ? distance : 0;
		 
			// Animate
			wrapper.animate(animation, o.duration, o.options.easing, function() {
				if(mode == 'hide') el.hide(); // Hide
				$.effects.restore(el, props); $.effects.removeWrapper(el); // Restore
				if(o.callback) o.callback.apply(el[0], arguments); // Callback
				el.dequeue();
			});
			
		});
		
	};
	
})(jQuery);

;(function($) {

	$.effects.bounce = function(o) {

		return this.queue(function() {

			// Create element
			var el = $(this), props = ['position','top','left'];

			// Set options
			var mode = $.effects.setMode(el, o.options.mode || 'effect'); // Set Mode
			var direction = o.options.direction || 'up'; // Default direction
			var distance = o.options.distance || 20; // Default distance
			var times = o.options.times || 5; // Default # of times
			var speed = o.duration || 250; // Default speed per bounce
			if (/show|hide/.test(mode)) props.push('opacity'); // Avoid touching opacity to prevent clearType and PNG issues in IE

			// Adjust
			$.effects.save(el, props); el.show(); // Save & Show
			$.effects.createWrapper(el); // Create Wrapper
			var ref = (direction == 'up' || direction == 'down') ? 'top' : 'left';
			var motion = (direction == 'up' || direction == 'left') ? 'pos' : 'neg';
			var distance = o.options.distance || (ref == 'top' ? el.outerHeight({margin:true}) / 3 : el.outerWidth({margin:true}) / 3);
			if (mode == 'show') el.css('opacity', 0).css(ref, motion == 'pos' ? -distance : distance); // Shift
			if (mode == 'hide') distance = distance / (times * 2);
			if (mode != 'hide') times--;
			
			// Animate
			if (mode == 'show') { // Show Bounce
				var animation = {opacity: 1};
				animation[ref] = (motion == 'pos' ? '+=' : '-=') + distance;
				el.animate(animation, speed / 2, o.options.easing);
				distance = distance / 2;
				times--;
			};
			for (var i = 0; i < times; i++) { // Bounces
				var animation1 = {}, animation2 = {};
				animation1[ref] = (motion == 'pos' ? '-=' : '+=') + distance;
				animation2[ref] = (motion == 'pos' ? '+=' : '-=') + distance;
				el.animate(animation1, speed / 2, o.options.easing).animate(animation2, speed / 2, o.options.easing);
				distance = (mode == 'hide') ? distance * 2 : distance / 2;
			};
			if (mode == 'hide') { // Last Bounce
				var animation = {opacity: 0};
				animation[ref] = (motion == 'pos' ? '-=' : '+=')  + distance;
				el.animate(animation, speed / 2, o.options.easing, function(){
					el.hide(); // Hide
					$.effects.restore(el, props); $.effects.removeWrapper(el); // Restore
					if(o.callback) o.callback.apply(this, arguments); // Callback
				});
			} else {
				var animation1 = {}, animation2 = {};
				animation1[ref] = (motion == 'pos' ? '-=' : '+=') + distance;
				animation2[ref] = (motion == 'pos' ? '+=' : '-=') + distance;
				el.animate(animation1, speed / 2, o.options.easing).animate(animation2, speed / 2, o.options.easing, function(){
					$.effects.restore(el, props); $.effects.removeWrapper(el); // Restore
					if(o.callback) o.callback.apply(this, arguments); // Callback
				});
			};
			el.queue('fx', function() { el.dequeue(); });
			el.dequeue();
		});
		
	};

})(jQuery);

;(function($) {
	
	$.effects.clip = function(o) {

		return this.queue(function() {

			// Create element
			var el = $(this), props = ['position','top','left','width','height'];
			
			// Set options
			var mode = $.effects.setMode(el, o.options.mode || 'hide'); // Set Mode
			var direction = o.options.direction || 'vertical'; // Default direction
			
			// Adjust
			$.effects.save(el, props); el.show(); // Save & Show
			$.effects.createWrapper(el).css({overflow:'hidden'}); // Create Wrapper
			var ref = {
				size: (direction == 'vertical') ? 'height' : 'width',
				position: (direction == 'vertical') ? 'top' : 'left'
			};
			var distance = (direction == 'vertical') ? el.height() : el.width();
			if(mode == 'show') { el.css(ref.size, 0); el.css(ref.position, distance / 2); } // Shift
			
			// Animation
			var animation = {};
			animation[ref.size] = mode == 'show' ? distance : 0;
			animation[ref.position] = mode == 'show' ? 0 : distance / 2;
				
			// Animate
			el.animate(animation, { queue: false, duration: o.duration, easing: o.options.easing, complete: function() {
				if(mode == 'hide') el.hide(); // Hide
				$.effects.restore(el, props); $.effects.removeWrapper(el); // Restore
				if(o.callback) o.callback.apply(this, arguments); // Callback
				el.dequeue();
			}}); 
			
		});
		
	};
	
})(jQuery);

;(function($) {
	
	$.effects.drop = function(o) {

		return this.queue(function() {

			// Create element
			var el = $(this), props = ['position','top','left','opacity'];
			
			// Set options
			var mode = $.effects.setMode(el, o.options.mode || 'hide'); // Set Mode
			var direction = o.options.direction || 'left'; // Default Direction
			
			// Adjust
			$.effects.save(el, props); el.show(); // Save & Show
			$.effects.createWrapper(el); // Create Wrapper
			var ref = (direction == 'up' || direction == 'down') ? 'top' : 'left';
			var motion = (direction == 'up' || direction == 'left') ? 'pos' : 'neg';
			var distance = o.options.distance || (ref == 'top' ? el.outerHeight({margin:true}) / 2 : el.outerWidth({margin:true}) / 2);
			if (mode == 'show') el.css('opacity', 0).css(ref, motion == 'pos' ? -distance : distance); // Shift
			
			// Animation
			var animation = {opacity: mode == 'show' ? 1 : 0};
			animation[ref] = (mode == 'show' ? (motion == 'pos' ? '+=' : '-=') : (motion == 'pos' ? '-=' : '+=')) + distance;
			
			// Animate
			el.animate(animation, { queue: false, duration: o.duration, easing: o.options.easing, complete: function() {
				if(mode == 'hide') el.hide(); // Hide
				$.effects.restore(el, props); $.effects.removeWrapper(el); // Restore
				if(o.callback) o.callback.apply(this, arguments); // Callback
				el.dequeue();
			}});
			
		});
		
	};
	
})(jQuery);

;(function($) {
	
	$.effects.fold = function(o) {

		return this.queue(function() {

			// Create element
			var el = $(this), props = ['position','top','left'];
			
			// Set options
			var mode = $.effects.setMode(el, o.options.mode || 'hide'); // Set Mode
			var size = o.options.size || 15; // Default fold size
			
			// Adjust
			$.effects.save(el, props); el.show(); // Save & Show
			var wrapper = $.effects.createWrapper(el).css({overflow:'hidden'}); // Create Wrapper
			var ref = (mode == 'show') ? ['width', 'height'] : ['height', 'width'];
			var distance = (mode == 'show') ? [wrapper.width(), wrapper.height()] : [wrapper.height(), wrapper.width()];
			if(mode == 'show') wrapper.css({height: size, width: 0}); // Shift
			
			// Animation
			var animation1 = {}, animation2 = {};
			animation1[ref[0]] = mode == 'show' ? distance[0] : size;
			animation2[ref[1]] = mode == 'show' ? distance[1] : 0;
			
			// Animate
			wrapper.animate(animation1, o.duration / 2, o.options.easing)
			.animate(animation2, o.duration / 2, o.options.easing, function() {
				if(mode == 'hide') el.hide(); // Hide
				$.effects.restore(el, props); $.effects.removeWrapper(el); // Restore
				if(o.callback) o.callback.apply(el[0], arguments); // Callback
				el.dequeue();
			});
			
		});
		
	};
	
})(jQuery);

;(function($) {
	
	$.effects.highlight = function(o) {

		return this.queue(function() {
			
			// Create element
			var el = $(this), props = ['backgroundImage','backgroundColor','opacity'];
			
			// Set options
			var mode = $.effects.setMode(el, o.options.mode || 'show'); // Set Mode
			var color = o.options.color || "#ffff99"; // Default highlight color
			var oldColor = el.css("backgroundColor");
			
			// Adjust
			$.effects.save(el, props); el.show(); // Save & Show
			el.css({backgroundImage: 'none', backgroundColor: color}); // Shift
			
			// Animation
			var animation = {backgroundColor: oldColor };
			if (mode == "hide") animation['opacity'] = 0;
			
			// Animate
			el.animate(animation, { queue: false, duration: o.duration, easing: o.options.easing, complete: function() {
				if(mode == "hide") el.hide();
				$.effects.restore(el, props);
			if (mode == "show" && jQuery.browser.msie) this.style.removeAttribute('filter'); 
				if(o.callback) o.callback.apply(this, arguments);
				el.dequeue();
			}});
			
		});
		
	};
	
})(jQuery);

;(function($) {
	
	$.effects.pulsate = function(o) {

		return this.queue(function() {
			
			// Create element
			var el = $(this);
			
			// Set options
			var mode = $.effects.setMode(el, o.options.mode || 'show'); // Set Mode
			var times = o.options.times || 5; // Default # of times
			
			// Adjust
			if (mode != 'hide') times--;
			if (el.is(':hidden')) { // Show fadeIn
				el.css('opacity', 0);
				el.show(); // Show
				el.animate({opacity: 1}, o.duration / 2, o.options.easing);
				times--;
			}
			
			// Animate
			for (var i = 0; i < times; i++) { // Pulsate
				el.animate({opacity: 0}, o.duration / 2, o.options.easing).animate({opacity: 1}, o.duration / 2, o.options.easing);
			};
			if (mode == 'hide') { // Last Pulse
				el.animate({opacity: 0}, o.duration / 2, o.options.easing, function(){
					el.hide(); // Hide
					if(o.callback) o.callback.apply(this, arguments); // Callback
				});
			} else {
				el.animate({opacity: 0}, o.duration / 2, o.options.easing).animate({opacity: 1}, o.duration / 2, o.options.easing, function(){
					if(o.callback) o.callback.apply(this, arguments); // Callback
				});
			};
			el.queue('fx', function() { el.dequeue(); });
			el.dequeue();
		});
		
	};
	
})(jQuery);

;(function($) {
	
	$.effects.puff = function(o) {
	
		return this.queue(function() {
	
			// Create element
			var el = $(this);
		
			// Set options
			var options = $.extend(true, {}, o);
			var mode = $.effects.setMode(el, o.options.mode || 'hide'); // Set Mode
			var percent = parseInt(o.options.percent) || 150; // Set default puff percent
			options.fade = true; // It's not a puff if it doesn't fade! :)
			var original = {height: el.height(), width: el.width()}; // Save original
		
			// Adjust
			var factor = percent / 100;
			el.from = (mode == 'hide') ? original : {height: original.height * factor, width: original.width * factor};
		
			// Animation
			options.from = el.from;
			options.percent = (mode == 'hide') ? percent : 100;
			options.mode = mode;
		
			// Animate
			el.effect('scale', options, o.duration, o.callback);
			el.dequeue();
		});
		
	};

	$.effects.scale = function(o) {
		
		return this.queue(function() {
		
			// Create element
			var el = $(this);

			// Set options
			var options = $.extend(true, {}, o);
			var mode = $.effects.setMode(el, o.options.mode || 'effect'); // Set Mode
			var percent = parseInt(o.options.percent) || (parseInt(o.options.percent) == 0 ? 0 : (mode == 'hide' ? 0 : 100)); // Set default scaling percent
			var direction = o.options.direction || 'both'; // Set default axis
			var origin = o.options.origin; // The origin of the scaling
			if (mode != 'effect') { // Set default origin and restore for show/hide
				origin = origin || ['middle','center'];
				options.restore = true;
			}
			var original = {height: el.height(), width: el.width()}; // Save original
			el.from = o.options.from || (mode == 'show' ? {height: 0, width: 0} : original); // Default from state
		
			// Adjust
			var factor = { // Set scaling factor
				y: direction != 'horizontal' ? (percent / 100) : 1,
				x: direction != 'vertical' ? (percent / 100) : 1
			};
			el.to = {height: original.height * factor.y, width: original.width * factor.x}; // Set to state
			if (origin) { // Calculate baseline shifts
				var baseline = $.effects.getBaseline(origin, original);
				el.from.top = (original.height - el.from.height) * baseline.y;
				el.from.left = (original.width - el.from.width) * baseline.x;
				el.to.top = (original.height - el.to.height) * baseline.y;
				el.to.left = (original.width - el.to.width) * baseline.x;
			};
			if (o.options.fade) { // Fade option to support puff
				if (mode == 'show') {el.from.opacity = 0; el.to.opacity = 1;};
				if (mode == 'hide') {el.from.opacity = 1; el.to.opacity = 0;};
			};
		
			// Animation
			options.from = el.from; options.to = el.to; options.mode = mode;
		
			// Animate
			el.effect('size', options, o.duration, o.callback);
			el.dequeue();
		});
		
	};
	
	$.effects.size = function(o) {

		return this.queue(function() {
			
			// Create element
			var el = $(this), props = ['position','top','left','width','height','overflow','opacity'];
			var props1 = ['position','overflow','opacity']; // Always restore
			var props2 = ['width','height','overflow']; // Copy for children
			var cProps = ['fontSize'];
			var vProps = ['borderTopWidth', 'borderBottomWidth', 'paddingTop', 'paddingBottom'];
			var hProps = ['borderLeftWidth', 'borderRightWidth', 'paddingLeft', 'paddingRight'];
			
			// Set options
			var mode = $.effects.setMode(el, o.options.mode || 'effect'); // Set Mode
			var restore = o.options.restore || false; // Default restore
			var scale = o.options.scale || 'both'; // Default scale mode
			var original = {height: el.height(), width: el.width()}; // Save original
			el.from = o.options.from || original; // Default from state
			el.to = o.options.to || original; // Default to state
			
			// Adjust
			var factor = { // Set scaling factor
				from: {y: el.from.height / original.height, x: el.from.width / original.width},
				to: {y: el.to.height / original.height, x: el.to.width / original.width}
			};
			if (scale == 'box' || scale == 'both') { // Scale the css box
				if (factor.from.y != factor.to.y) { // Vertical props scaling
					props = props.concat(vProps);
					el.from = $.effects.setTransition(el, vProps, factor.from.y, el.from);
					el.to = $.effects.setTransition(el, vProps, factor.to.y, el.to);
				};
				if (factor.from.x != factor.to.x) { // Horizontal props scaling
					props = props.concat(hProps);
					el.from = $.effects.setTransition(el, hProps, factor.from.x, el.from);
					el.to = $.effects.setTransition(el, hProps, factor.to.x, el.to);
				};
			};
			if (scale == 'content' || scale == 'both') { // Scale the content
				if (factor.from.y != factor.to.y) { // Vertical props scaling
					props = props.concat(cProps);
					el.from = $.effects.setTransition(el, cProps, factor.from.y, el.from);
					el.to = $.effects.setTransition(el, cProps, factor.to.y, el.to);
				};
			};
			$.effects.save(el, restore ? props : props1); el.show(); // Save & Show
			$.effects.createWrapper(el); // Create Wrapper
			el.css('overflow','hidden').css(el.from); // Shift
			
			// Animate
			if (scale == 'content' || scale == 'both') { // Scale the children
				vProps = vProps.concat(['marginTop','marginBottom']).concat(cProps); // Add margins/font-size
				hProps = hProps.concat(['marginLeft','marginRight']); // Add margins
				props2 = props.concat(vProps).concat(hProps); // Concat
				el.find("*[width]").each(function(){
					child = $(this);
					if (restore) $.effects.save(child, props2);
					var c_original = {height: child.height(), width: child.width()}; // Save original
					child.from = {height: c_original.height * factor.from.y, width: c_original.width * factor.from.x};
					child.to = {height: c_original.height * factor.to.y, width: c_original.width * factor.to.x};
					if (factor.from.y != factor.to.y) { // Vertical props scaling
						child.from = $.effects.setTransition(child, vProps, factor.from.y, child.from);
						child.to = $.effects.setTransition(child, vProps, factor.to.y, child.to);
					};
					if (factor.from.x != factor.to.x) { // Horizontal props scaling
						child.from = $.effects.setTransition(child, hProps, factor.from.x, child.from);
						child.to = $.effects.setTransition(child, hProps, factor.to.x, child.to);
					};
					child.css(child.from); // Shift children
					child.animate(child.to, o.duration, o.options.easing, function(){
						if (restore) $.effects.restore(child, props2); // Restore children
					}); // Animate children
				});
			};
			
			// Animate
			el.animate(el.to, { queue: false, duration: o.duration, easing: o.options.easing, complete: function() {
				if(mode == 'hide') el.hide(); // Hide
				$.effects.restore(el, restore ? props : props1); $.effects.removeWrapper(el); // Restore
				if(o.callback) o.callback.apply(this, arguments); // Callback
				el.dequeue();
			}}); 
			
		});

	};
	
})(jQuery);

;(function($) {
	
	$.effects.shake = function(o) {

		return this.queue(function() {

			// Create element
			var el = $(this), props = ['position','top','left'];
			
			// Set options
			var mode = $.effects.setMode(el, o.options.mode || 'effect'); // Set Mode
			var direction = o.options.direction || 'left'; // Default direction
			var distance = o.options.distance || 20; // Default distance
			var times = o.options.times || 3; // Default # of times
			var speed = o.duration || o.options.duration || 140; // Default speed per shake
			
			// Adjust
			$.effects.save(el, props); el.show(); // Save & Show
			$.effects.createWrapper(el); // Create Wrapper
			var ref = (direction == 'up' || direction == 'down') ? 'top' : 'left';
			var motion = (direction == 'up' || direction == 'left') ? 'pos' : 'neg';
			
			// Animation
			var animation = {}, animation1 = {}, animation2 = {};
			animation[ref] = (motion == 'pos' ? '-=' : '+=')  + distance;
			animation1[ref] = (motion == 'pos' ? '+=' : '-=')  + distance * 2;
			animation2[ref] = (motion == 'pos' ? '-=' : '+=')  + distance * 2;
			
			// Animate
			el.animate(animation, speed, o.options.easing);
			for (var i = 1; i < times; i++) { // Shakes
				el.animate(animation1, speed, o.options.easing).animate(animation2, speed, o.options.easing);
			};
			el.animate(animation1, speed, o.options.easing).
			animate(animation, speed / 2, o.options.easing, function(){ // Last shake
				$.effects.restore(el, props); $.effects.removeWrapper(el); // Restore
				if(o.callback) o.callback.apply(this, arguments); // Callback
			});
			el.queue('fx', function() { el.dequeue(); });
			el.dequeue();
		});
		
	};
	
})(jQuery);

;(function($) {
	
	$.effects.slide = function(o) {

		return this.queue(function() {

			// Create element
			var el = $(this), props = ['position','top','left'];
			
			// Set options
			var mode = $.effects.setMode(el, o.options.mode || 'show'); // Set Mode
			var direction = o.options.direction || 'left'; // Default Direction
			
			// Adjust
			$.effects.save(el, props); el.show(); // Save & Show
			$.effects.createWrapper(el).css({overflow:'hidden'}); // Create Wrapper
			var ref = (direction == 'up' || direction == 'down') ? 'top' : 'left';
			var motion = (direction == 'up' || direction == 'left') ? 'pos' : 'neg';
			var distance = o.options.distance || (ref == 'top' ? el.outerHeight({margin:true}) : el.outerWidth({margin:true}));
			if (mode == 'show') el.css(ref, motion == 'pos' ? -distance : distance); // Shift
			
			// Animation
			var animation = {};
			animation[ref] = (mode == 'show' ? (motion == 'pos' ? '+=' : '-=') : (motion == 'pos' ? '-=' : '+=')) + distance;
			
			// Animate
			el.animate(animation, { queue: false, duration: o.duration, easing: o.options.easing, complete: function() {
				if(mode == 'hide') el.hide(); // Hide
				$.effects.restore(el, props); $.effects.removeWrapper(el); // Restore
				if(o.callback) o.callback.apply(this, arguments); // Callback
				el.dequeue();
			}});
			
		});
		
	};
	
})(jQuery);

;(function($) {
	
	$.effects.transfer = function(o) {

		return this.queue(function() {

			// Create element
			var el = $(this);
			
			// Set options
			var mode = $.effects.setMode(el, o.options.mode || 'effect'); // Set Mode
			var target = $(o.options.to); // Find Target
			var position = el.offset();
		var transfer = $('<div class="ui-effects-transfer"></div>').appendTo(document.body);
			
			// Set target css
			transfer.addClass(o.options.className);
			transfer.css({
				top: position.top,
				left: position.left,
				height: el.outerHeight(true) - parseInt(transfer.css('borderTopWidth')) - parseInt(transfer.css('borderBottomWidth')),
				width: el.outerWidth(true) - parseInt(transfer.css('borderLeftWidth')) - parseInt(transfer.css('borderRightWidth')),
				position: 'absolute'
			});
			
			// Animation
			position = target.offset();
			animation = {
				top: position.top,
				left: position.top,
				height: target.outerHeight() - parseInt(transfer.css('borderTopWidth')) - parseInt(transfer.css('borderBottomWidth')),
				width: target.outerWidth() - parseInt(transfer.css('borderLeftWidth')) - parseInt(transfer.css('borderRightWidth'))
			};
			
			// Animate
			transfer.animate(animation, o.duration, o.options.easing, function() {
				transfer.remove(); // Remove div
				if(o.callback) o.callback.apply(el[0], arguments); // Callback
				el.dequeue();
			}); 
			
		});
		
	};
	
})(jQuery);
