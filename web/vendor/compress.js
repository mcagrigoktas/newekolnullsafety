! function (e, t) {
    "object" == typeof exports && "undefined" != typeof module ? module.exports = t() : "function" == typeof define && define.amd ? define(t) : e.ImageCompressor = t()
}(this, function () {
    "use strict";
    var e, k = (function (e) {
        var t, a, f, s, h, d, i;
        t = window, a = t.HTMLCanvasElement && t.HTMLCanvasElement.prototype, f = t.Blob && function () {
            try {
                return Boolean(new Blob)
            } catch (e) {
                return !1
            }
        }(), s = f && t.Uint8Array && function () {
            try {
                return 100 === new Blob([new Uint8Array(100)]).size
            } catch (e) {
                return !1
            }
        }(), h = t.BlobBuilder || t.WebKitBlobBuilder || t.MozBlobBuilder || t.MSBlobBuilder, d = /^data:((.*?)(;charset=.*?)?)(;base64)?,/, i = (f || h) && t.atob && t.ArrayBuffer && t.Uint8Array && function (e) {
            var t, r, n, a, i, o, l, u, c;
            if (!(t = e.match(d))) throw new Error("invalid data URI");
            for (r = t[2] ? t[1] : "text/plain" + (t[3] || ";charset=US-ASCII"), n = !!t[4], a = e.slice(t[0].length), i = n ? atob(a) : decodeURIComponent(a), o = new ArrayBuffer(i.length), l = new Uint8Array(o), u = 0; u < i.length; u += 1) l[u] = i.charCodeAt(u);
            return f ? new Blob([s ? l : o], {
                type: r
            }) : ((c = new h).append(o), c.getBlob(r))
        }, t.HTMLCanvasElement && !a.toBlob && (a.mozGetAsFile ? a.toBlob = function (e, t, r) {
            var n = this;
            setTimeout(function () {
                r && a.toDataURL && i ? e(i(n.toDataURL(t, r))) : e(n.mozGetAsFile("blob", t))
            })
        } : a.toDataURL && i && (a.toBlob = function (e, t, r) {
            var n = this;
            setTimeout(function () {
                e(i(n.toDataURL(t, r)))
            })
        })), e.exports ? e.exports = i : t.dataURLtoBlob = i
    }(e = {
        exports: {}
    }, e.exports), e.exports),
        o = Object.prototype.toString,
        t = {
            checkOrientation: !0,
            maxWidth: 1 / 0,
            maxHeight: 1 / 0,
            minWidth: 0,
            minHeight: 0,
            width: void 0,
            height: void 0,
            quality: .8,
            mimeType: "auto",
            convertSize: 5e6,
            beforeDraw: null,
            drew: null,
            success: null,
            error: null
        },
        r = /^image\/.+$/;

    function A(e) {
        return r.test(e)
    }
    var m = String.fromCharCode;
    var l = window.btoa;

    function u(e) {
        var t = new DataView(e),
            r = void 0,
            n = void 0,
            a = void 0,
            i = void 0;
        if (255 === t.getUint8(0) && 216 === t.getUint8(1))
            for (var o = t.byteLength, l = 2; l < o;) {
                if (255 === t.getUint8(l) && 225 === t.getUint8(l + 1)) {
                    a = l;
                    break
                }
                l += 1
            }
        if (a) {
            var u = a + 10;
            if ("Exif" === function (e, t, r) {
                var n = "",
                    a = void 0;
                for (r += t, a = t; a < r; a += 1) n += m(e.getUint8(a));
                return n
            }(t, a + 4, 4)) {
                var c = t.getUint16(u);
                if (((n = 18761 === c) || 19789 === c) && 42 === t.getUint16(u + 2, n)) {
                    var f = t.getUint32(u + 4, n);
                    8 <= f && (i = u + f)
                }
            }
        }
        if (i) {
            var s = t.getUint16(i, n),
                h = void 0,
                d = void 0;
            for (d = 0; d < s; d += 1)
                if (h = i + 12 * d + 2, 274 === t.getUint16(h, n)) {
                    h += 8, r = t.getUint16(h, n), t.setUint16(h, 1, n);
                    break
                }
        }
        return r
    }
    var n = /\.\d*(?:0|9){12}\d*$/i;

    function R(e) {
        var t = 1 < arguments.length && void 0 !== arguments[1] ? arguments[1] : 1e11;
        return n.test(e) ? Math.round(e * t) / t : e
    }
    var a = function () {
        function n(e, t) {
            for (var r = 0; r < t.length; r++) {
                var n = t[r];
                n.enumerable = n.enumerable || !1, n.configurable = !0, "value" in n && (n.writable = !0), Object.defineProperty(e, n.key, n)
            }
        }
        return function (e, t, r) {
            return t && n(e.prototype, t), r && n(e, r), e
        }
    }(),
        c = Object.assign || function (e) {
            for (var t = 1; t < arguments.length; t++) {
                var r = arguments[t];
                for (var n in r) Object.prototype.hasOwnProperty.call(r, n) && (e[n] = r[n])
            }
            return e
        },
        i = window,
        f = i.ArrayBuffer,
        s = i.FileReader,
        h = window.URL || window.webkitURL,
        d = /\.\w+$/;
    return function () {
        function r(e, t) {
            ! function (e, t) {
                if (!(e instanceof t)) throw new TypeError("Cannot call a class as a function")
            }(this, r), this.result = null, e && this.compress(e, t)
        }
        return a(r, [{
            key: "compress",
            value: function (B, M) {
                var x = this,
                    T = new Image;
                return M = c({}, t, M), f || (M.checkOrientation = !1), new Promise(function (r, e) {
                    if ((t = B) instanceof Blob || "[object Blob]" === o.call(t)) {
                        var t, n = B.type;
                        if (A(n))
                            if (h || s) {
                                if (h && !M.checkOrientation) r({
                                    url: h.createObjectURL(B)
                                });
                                else if (s) {
                                    var a = new s,
                                        i = M.checkOrientation && "image/jpeg" === n;
                                    a.onload = function (e) {
                                        var t = e.target.result;
                                        r(i ? c({
                                            url: function (e, t) {
                                                var r = new Uint8Array(e),
                                                    n = "";
                                                if ("function" == typeof r.forEach) r.forEach(function (e) {
                                                    n += m(e)
                                                });
                                                else
                                                    for (var a = r.length, i = 0; i < a; i += 1) n += m(r[i]);
                                                return "data:" + t + ";base64," + l(n)
                                            }(t, n)
                                        }, function (e) {
                                            var t = 0,
                                                r = 1,
                                                n = 1;
                                            switch (e) {
                                                case 2:
                                                    r = -1;
                                                    break;
                                                case 3:
                                                    t = -180;
                                                    break;
                                                case 4:
                                                    n = -1;
                                                    break;
                                                case 5:
                                                    t = 90, n = -1;
                                                    break;
                                                case 6:
                                                    t = 90;
                                                    break;
                                                case 7:
                                                    t = 90, r = -1;
                                                    break;
                                                case 8:
                                                    t = -90
                                            }
                                            return {
                                                rotate: t,
                                                scaleX: r,
                                                scaleY: n
                                            }
                                        }(u(t))) : {
                                            url: t
                                        })
                                    }, a.onabort = function () {
                                        e(new Error("Aborted to load the image with FileReader."))
                                    }, a.onerror = function () {
                                        e(new Error("Failed to load the image with FileReader."))
                                    }, i ? a.readAsArrayBuffer(B) : a.readAsDataURL(B)
                                }
                            }
                            else e(new Error("The current browser does not support image compression."));
                        else e(new Error("The first argument must be an image File or Blob object."))
                    } else e(new Error("The first argument must be a File or Blob object."))
                }).then(function (r) {
                    return new Promise(function (e, t) {
                        T.onload = function () {
                            return e(c({}, r, {
                                naturalWidth: T.naturalWidth,
                                naturalHeight: T.naturalHeight
                            }))
                        }, T.onabort = function () {
                            t(new Error("Aborted to load the image."))
                        }, T.onerror = function () {
                            t(new Error("Failed to load the image."))
                        }, T.alt = B.name, T.src = r.url
                    })
                }).then(function (e) {
                    var b = e.naturalWidth,
                        w = e.naturalHeight,
                        t = e.rotate,
                        p = void 0 === t ? 0 : t,
                        r = e.scaleX,
                        y = void 0 === r ? 1 : r,
                        n = e.scaleY,
                        U = void 0 === n ? 1 : n;
                    return new Promise(function (t) {
                        var e = document.createElement("canvas"),
                            r = e.getContext("2d"),
                            n = b / w,
                            a = Math.max(M.maxWidth, 0) || 1 / 0,
                            i = Math.max(M.maxHeight, 0) || 1 / 0,
                            o = Math.max(M.minWidth, 0) || 0,
                            l = Math.max(M.minHeight, 0) || 0,
                            u = b,
                            c = w;
                        if (a < 1 / 0 && i < 1 / 0 ? a < i * n ? i = a / n : a = i * n : a < 1 / 0 ? i = a / n : i < 1 / 0 && (a = i * n), 0 < o && 0 < l ? o < l * n ? l = o / n : o = l * n : 0 < o ? l = o / n : 0 < l && (o = l * n), 0 < M.width) c = (u = M.width) / n;
                        else if (0 < M.height) {
                            u = (c = M.height) * n
                        }
                        var f = -(u = Math.min(Math.max(u, o), a)) / 2,
                            s = -(c = Math.min(Math.max(c, l), i)) / 2,
                            h = u,
                            d = c;
                        if (Math.abs(p) % 180 == 90) {
                            var m = {
                                width: c,
                                height: u
                            };
                            u = m.width, c = m.height
                        }
                        e.width = R(u), e.height = R(c), A(M.mimeType) || (M.mimeType = B.type);
                        var g = "transparent";
                        B.size > M.convertSize && "image/png" === M.mimeType && (g = "#fff", M.mimeType = "image/jpeg"), r.fillStyle = g, r.fillRect(0, 0, u, c), r.save(), r.translate(u / 2, c / 2), r.rotate(p * Math.PI / 180), r.scale(y, U), M.beforeDraw && M.beforeDraw.call(x, r, e), r.drawImage(T, Math.floor(R(f)), Math.floor(R(s)), Math.floor(R(h)), Math.floor(R(d))), M.drew && M.drew.call(x, r, e), r.restore();
                        var v = function (e) {
                            t({
                                naturalWidth: b,
                                naturalHeight: w,
                                result: e
                            })
                        };
                        e.toBlob ? e.toBlob(v, M.mimeType, M.quality) : v(k(e.toDataURL(M.mimeType, M.quality)))
                    })
                }).then(function (e) {
                    var t = e.naturalWidth,
                        r = e.naturalHeight,
                        n = e.result;
                    if (h && !M.checkOrientation && h.revokeObjectURL(T.src), n)
                        if (n.size > B.size && M.mimeType === B.type && !(M.width > t || M.height > r || M.minWidth > t || M.minHeight > r)) n = B;
                        else {
                            var a = new Date;
                            n.lastModified = a.getTime(), n.lastModifiedDate = a, n.name = B.name, n.name && n.type !== B.type && (n.name = n.name.replace(d, function (e) {
                                var t = !(1 < arguments.length && void 0 !== arguments[1]) || arguments[1],
                                    r = A(e) ? e.substr(6) : "";
                                return "jpeg" === r && (r = "jpg"), r && t && (r = "." + r), r
                            }(n.type)))
                        }
                    else n = B;
                    return x.result = n, M.success && M.success.call(x, n), Promise.resolve(n)
                }).catch(function (e) {
                    if (!M.error) throw e;
                    M.error.call(x, e)
                })
            }
        }]), r
    }()
});
var compressImage = function (d, c, w, q) {
    if (d == null) {
        return;
    }
    new ImageCompressor(d, {
        quality: q / 100,
        maxWidth: w,
        maxHeight: w,
        success(result) {
            //   console.log('S bitti:' + result);
            c(result);
        },
        error(e) {
            console.log('S error:' + e);
            c(null);
        },
    });
}
