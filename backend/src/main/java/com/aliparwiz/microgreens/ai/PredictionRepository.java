package com.aliparwiz.microgreens.ai;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PredictionRepository extends JpaRepository<Prediction, Long> {
    List<Prediction> findByDeviceId(String deviceId);
    List<Prediction> findByDeviceIdAndPredictionType(String deviceId, String predictionType);
    
    @Query("SELECT p FROM Prediction p WHERE p.deviceId = :deviceId ORDER BY p.timestamp DESC")
    List<Prediction> findLatestByDeviceId(@Param("deviceId") String deviceId);
    
    @Query("SELECT p FROM Prediction p WHERE p.deviceId = :deviceId AND p.predictionType = :predictionType ORDER BY p.timestamp DESC")
    Optional<Prediction> findLatestByDeviceIdAndPredictionType(
            @Param("deviceId") String deviceId,
            @Param("predictionType") String predictionType);
}

