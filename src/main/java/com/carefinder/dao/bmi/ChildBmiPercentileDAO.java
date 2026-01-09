package com.carefinder.dao.bmi;

import com.carefinder.dto.bmi.ChildBmiPercentileDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ChildBmiPercentileDAO {

    ChildBmiPercentileDTO findByGenderAndAgeMonth(
            @Param("gender") String gender,
            @Param("ageMonth") int ageMonth
    );
}
