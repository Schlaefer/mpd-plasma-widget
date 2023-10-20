.pragma library

function title(mpdItem) {
    let title = mpdItem.title;
    if (mpdItem.tracknumber)
        title = mpdItem.tracknumber + ". " + title;

    return title;
}

function artist(mpdItem) {
    return mpdItem.artist || mpdItem.albumartist || "";
}

function album(mpdItem) {
    let album = mpdItem.album || "";
    if (album && mpdItem.date)
        album += " (" + mpdItem.date + ")";

    return album
}

function queueAlbumLine(model) {
    let line = []
    line.push(model.tracknumber ? model.tracknumber + ". " : "")

    if (model.album) {
        line.push(model.album + " ")
    }
    if (model.time) {
        line.push("(" + model.time + ")")
    }

    return line.join("")
}

