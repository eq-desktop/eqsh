const getFriendlyNotifTimeString = (timestamp, Translation) => {
    if (!timestamp) return '';
    const messageTime = new Date(timestamp);
    const now = new Date();
    const diffMs = now.getTime() - messageTime.getTime();

    // Less than 1 minute
    if (diffMs < 60000)
        return Translation.tr('Now');

    // Same day - show relative time
    if (messageTime.toDateString() === now.toDateString()) {
        const diffMinutes = Math.floor(diffMs / 60000);
        const diffHours = Math.floor(diffMs / 3600000);

        if (diffHours > 0) {
            return Translation.tr(`%1h`).arg(diffHours);
        } else {
            return Translation.tr(`%1m`).arg(diffMinutes);
        }
    }

    // Yesterday
    if (messageTime.toDateString() === new Date(now.getTime() - 86400000).toDateString())
        return Translation.tr('Yesterday');

    // Older dates
    return Qt.formatDateTime(messageTime, "dd MMMM");
};