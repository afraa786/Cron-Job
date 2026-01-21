package cron.Scheduler;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import cron.Entity.Reminder;
import cron.Service.ReminderService;

import java.util.List;

@Component
public class ReminderScheduler {

    private final ReminderService service;

    public ReminderScheduler(ReminderService service) {
        this.service = service;
    }

    @Scheduled(cron = "0 */1 * * * *")
    public void processReminders() {

        List<Reminder> dueReminders = service.getDueReminders();

        for (Reminder reminder : dueReminders) {

            System.out.println("🔔 REMINDER: " + reminder.getMessage());

            service.updateNextTrigger(reminder);
        }
    }
}
