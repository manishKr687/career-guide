package com.careerguide.api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Clock;
import java.time.ZoneId;

/**
 * The clock that decides what "today" is for a user's learning log and
 * streak. India time, not the server's: the server runs in UTC, and a student
 * logging at 1 a.m. IST would otherwise have it filed under the day before.
 * A bean so tests can fix the date.
 */
@Configuration
public class TimeConfig {

    public static final ZoneId INDIA = ZoneId.of("Asia/Kolkata");

    @Bean
    public Clock clock() {
        return Clock.system(INDIA);
    }
}
