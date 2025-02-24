// fix file refs per https://github.com/jackyzha0/quartz/issues/863
"use-strict"

function getFileExtension(uri) {
    var path = uri.split("?")[0].split("#")[0]

    var segments = path.split("/")
    var fileName = segments[segments.length - 1]

    var lastDotIndex = fileName.lastIndexOf(".")

    if (lastDotIndex < 1) {
        return ""
    }

    return fileName.slice(lastDotIndex + 1).toLowerCase()
}

const knownExt = {
    canvas: true,
    css: true,
    html: true,
    js: true,
    json: true,
    png: true,
    xml: true,
    jpeg: true,
    jpg: true,
    gif: true,
}

function handler(event) {
    var request = event.request
    var uri = request.uri
    var ext = getFileExtension(uri)
    if (uri.endsWith("/")) {
        request.uri += "index.html"
    } else if (!knownExt[ext]) {
        request.uri += ".html"
    }
    return request
}
