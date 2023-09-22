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

function oneLine(mpdItem) {
    let line = []
    line.push(album(mpdItem))
    line.push(title(mpdItem))
    line.push(artist(mpdItem))

    line = line.filter((value) => {
        return value
    });

    return line.join(" - ")
}