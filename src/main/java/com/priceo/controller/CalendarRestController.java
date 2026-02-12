package com.priceo.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.priceo.service.StayCalendarService;

@RestController
@RequestMapping("/api/calendar")
public class CalendarRestController {

    @Autowired
    private StayCalendarService calendarService;

    @GetMapping("/list")
    public List<Map<String, Object>> getCalendarList(
            @RequestParam("sr_no") int sr_no,
            @RequestParam("startDate") String startDate, // 이름을 startDate로 통일
            @RequestParam("endDate") String endDate)      // 이름을 endDate로 통일
    {
        return calendarService.getCalendarEvents(sr_no, startDate, endDate);
    }
}