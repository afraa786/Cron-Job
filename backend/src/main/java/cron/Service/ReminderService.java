package cron.Service;

import cron.Entity.Reminder;
import cron.Repository.*;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ReminderService {

    private final ReminderRepository repository;

    public ReminderService(ReminderRepository repository) {
        this.repository = repository;
    }

    public List<Reminder> getDueReminders() {
        return repository.findByActiveTrueAndNextTriggerTimeLessThanEqual(LocalDateTime.now());
    }

    public void updateNextTrigger(Reminder reminder) {
        reminder.setNextTriggerTime(
                reminder.getNextTriggerTime().plusMinutes(reminder.getIntervalMinutes())
        );
        repository.save(reminder);
    }

    public Reminder createReminder(Reminder reminder) {
        reminder.setNextTriggerTime(
                LocalDateTime.now().plusMinutes(reminder.getIntervalMinutes())
        );
        return repository.save(reminder);
    }
}
