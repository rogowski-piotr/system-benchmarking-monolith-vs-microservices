package pl.edu.pg.benchmarking.route1.place;

import lombok.Getter;

public class PlaceDto {

    @Getter
    public static class GetPlaceDtoResponse {
        Integer id;
        String coordinates;
    }

}
