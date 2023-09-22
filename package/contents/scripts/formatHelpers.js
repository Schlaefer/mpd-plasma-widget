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