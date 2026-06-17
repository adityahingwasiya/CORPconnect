package com.corpconnect.backend.repository;

import com.corpconnect.backend.entity.Employee;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EmployeeRepository extends JpaRepository<Employee, Long> {
    List<Employee> findByCompanyId(Long companyId);

    @Query("""
            SELECT e
            FROM Employee e
            WHERE e.company.id = :companyId
              AND e.id <> :excludeEmployeeId
              AND (
                    LOWER(e.baseCity) = LOWER(:city)
                 OR LOWER(e.currentCity) = LOWER(:city)
              )
            """)
    List<Employee> findColleaguesByCompanyAndCity(
            @Param("companyId") Long companyId,
            @Param("city") String city,
            @Param("excludeEmployeeId") Long excludeEmployeeId
    );

    Optional<Employee> findByEmail(String email);
}
