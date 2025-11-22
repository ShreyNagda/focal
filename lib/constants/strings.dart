// --- Shared Preferences Keys ---
const kKeyTimerState = 'timer_state';
const kKeyTargetTime = 'timer_target_time'; // For foreground provider logic

// Background Service Keys
const kKeyTargetTimestamp = 'timer_target_timestamp';
const kKeyCurrentLabel = 'current_timer_label';
const kKeyNextLabel = 'next_timer_label';

// Notifications
const kChannelIdCompletion = 'focal_completion';
const kChannelNameCompletion = 'Focal Timer Complete';

const kChannelIdTimer = 'focal_channel'; // For Foreground Service
const kChannelNameTimer = 'Focal Timer Service';

// --- Notification IDs ---
const kNotificationId = 1;

// --- Service Method Channels ---
const kMethodStopService = 'stop_service';
