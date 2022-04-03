package pl.edu.pg.benchmarking.distance.entity;

import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor(access = AccessLevel.PUBLIC)
public class Point {

    private Double latitude;

    private Double longitude;
}