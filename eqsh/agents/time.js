const getFriendlyTimeString = (timestamp, Translation) => {
    if (!timestamp) return '';
    const messageTime = new Date(timestamp);
    const now = new Date();
    const diffMs = now.getTime() - messageTime.getTime();

    // Same day - show h:mm AM/PM
    if (messageTime.toDateString() === now.toDateString()) {
        return Qt.formatDateTime(messageTime, "h:mm AP");
    }

    // Yesterday
    if (messageTime.toDateString() === new Date(now.getTime() - 86400000).toDateString())
        return Translation.tr('Yesterday');

    // Older dates
    return Qt.formatDateTime(messageTime, "dd MMMM");
};

const getFriendlyTime = (messageTime, Translation) => {
    if (!messageTime) return '';
    const now = new Date();
    const diffMs = now.getTime() - messageTime.getTime();

    // Same day - show h:mm AM/PM
    if (messageTime.toDateString() === now.toDateString()) {
        return Qt.formatDateTime(messageTime, "h:mm AP");
    }

    // Yesterday
    if (messageTime.toDateString() === new Date(now.getTime() - 86400000).toDateString())
        return Translation.tr('Yesterday');

    // Older dates
    return Qt.formatDateTime(messageTime, "dd MMMM");
};