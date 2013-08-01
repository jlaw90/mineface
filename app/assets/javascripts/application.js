// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap

_refreshFuncs = [];
_refreshFastFuncs = [];
_refreshFast = 2000;
_refreshSlow = 30000; // Has to be divisible...
_refreshCur = 0;

function addRefreshFunction(funcy, fast) {
    var arr = fast ? _refreshFastFuncs : _refreshFuncs;
    arr.push(funcy);
}

function removeRefreshFunction(funcy, fast) {
    var arr = fast ? _refreshFastFuncs : _refreshFuncs;
    var idx = arr.indexOf(funcy);
    if (idx == -1)
        return;
    arr.splice(idx, 1);
}

function refresh() {
    for (var i = 0; i < _refreshFastFuncs; i++) {
        _refreshFastFuncs[i]();
    }
    if (_refreshCur === 0) {
        for (var i = 0; i < _refreshFuncs.length; i++) {
            _refreshFuncs[i]();
        }
    }
    _refreshCur = (_refreshCur + _refreshFast) % _refreshSlow;
    setTimeout(refresh, _refreshFast);
}

function supports_html5_storage() {
    try {
        return 'localStorage' in window && window['localStorage'] !== null;
    } catch (e) {
        return false;
    }
}

function sget(key, def) {
    if (!supports_html5_storage())
        return def;
    var val = localStorage[key];
    if (val !== null && typeof(val) !== 'undefined') {
        if (def == null)
            return val;
        switch (typeof(def)) {
            case 'string':
                return val;
            case 'number':
                if (def === (def | 0))
                    return parseInt(val);
                return parseFloat(val);
            case 'boolean':
                return !!(val == 'true');
            default:
                throw 'unknown storage type';
        }
    }
    return def;
}

function sset(key, val) {
    if (!supports_html5_storage())
        return;
    localStorage[key] = val;
}

$(function () {
    $.fn.loading = function (options) {
        t = $(this);
        var defaults = {
            bgColor: '#999',
            duration: 800,
            opacity: 0.3,
            classOveride: 'loading'
        }
        t.options = jQuery.extend(defaults, options);
        t.remove = function () {
            var overlay = t.children(".ajax_overlay");
            if (overlay.length) {
                overlay.fadeOut(t.options.classOveride, function () {
                    overlay.remove();
                });
            }
        }
        // Delete any other loaders
        t.remove();
        // Create the overlay
        var overlay = $('<div></div>').css({
            'background-color': t.options.bgColor,
            'opacity': t.options.opacity,
            'width': t.width(),
            'height': t.height(),
            'position': 'absolute',
            'top': '0px',
            'left': '0px',
            'z-index': 99999
        }).addClass('ajax_overlay');
        // add an overiding class name to set new loader style
        if (t.options.classOveride) {
            overlay.addClass(t.options.classOveride);
        }
        // insert overlay and loader into DOM
        t.append(overlay.append($('<div></div>').addClass('ajax_loader')).fadeIn(t.options.duration));
    };

    $.fn.finishedLoading = function () {
        t = $(this);
        t.remove();
    };

    setTimeout(refresh, 0);
});