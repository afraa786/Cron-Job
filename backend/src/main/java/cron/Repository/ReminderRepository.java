package cron.Repository;


import org.springframework.data.jpa.repository.JpaRepository;

import cron.Entity.Reminder;

import java.time.LocalDateTime;
import java.util.List;

public interface ReminderRepository extends JpaRepository<Reminder, Long> {

    List<Reminder> findByActiveTrueAndNextTriggerTimeLessThanEqual(LocalDateTime time);
}
