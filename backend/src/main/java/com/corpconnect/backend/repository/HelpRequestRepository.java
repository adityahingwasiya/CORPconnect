package com.corpconnect.backend.repository;

import com.corpconnect.backend.entity.HelpRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface HelpRequestRepository extends JpaRepository<HelpRequest, Long> {
    List<HelpRequest> findByRequesterId(Long requesterId);

    List<HelpRequest> findByRequesterIdOrderByCreatedAtDesc(Long requesterId);

    List<HelpRequest> findByHelperId(Long helperId);

    @Query("SELECT hr FROM HelpRequest hr WHERE hr.id = :requestId AND hr.helper.id = :helperId")
    Optional<HelpRequest> findByIdAndHelperId(@Param("requestId") Long requestId, @Param("helperId") Long helperId);
}

