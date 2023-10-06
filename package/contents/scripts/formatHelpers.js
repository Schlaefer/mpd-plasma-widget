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

// @SOMEDAY i10n i18n
function queueAlbumLine(model) {
    let line = []
    line.push(model.tracknumber ? model.tracknumber + ". " : "")
    line.push(model.album || "")
    line.push(line === "" ? "" : " ")
    line.push("(" + model.time + ")")

    return line.join("")
}

