package cron.Controller;


import org.springframework.web.bind.annotation.*;

import cron.Entity.Reminder;
import cron.Service.ReminderService;

@RestController
@RequestMapping("/api/reminders")
public class ReminderController {

    private final ReminderService service;

    public ReminderController(ReminderService service) {
        this.service = service;
    }

    @PostMapping
    public Reminder createReminder(@RequestBody Reminder reminder) {
        return service.createReminder(reminder);
    }
}
