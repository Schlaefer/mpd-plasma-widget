.pragma library

function title(mpdItem) {
    if (!mpdItem) {
        return ""
    }

    let title = mpdItem.title || ""
    if (mpdItem.track) {
        title = mpdItem.track + ". " + title;
    }

    return title;
}

function artist(mpdItem) {
    if (!mpdItem) {
        return ""
    }

    return mpdItem.artist || mpdItem.albumartist || "";
}

function album(mpdItem) {
    if (!mpdItem) {
        return ""
    }

    let album = mpdItem.album || "";
    if (album && mpdItem.date)
        album += " (" + mpdItem.date + ")";

    return album
}

function queueAlbumLine(model) {
    let line = []
    line.push(model.track ? model.track + ". " : "")

    if (model.album) {
        line.push(model.album + " ")
    }
    if (model.time) {
        let seconds = model.time
        let hours = Math.floor(seconds / 3600);
        seconds %= 3600;
        let minutes = Math.floor(seconds / 60);
        seconds %= 60;

        let timeString = "("
        if (hours) {
            minutes = minutes < 10 ? '0' + minutes : minutes;
            timeString += `${hours}:`
        }
        timeString += `${minutes}:`
        seconds = seconds < 10 ? '0' + seconds : seconds;
        timeString += seconds
        timeString += ")"
        line.push(timeString)
    }

    return line.join("")
}

