package com.carefinder.dao.bmi;

import com.carefinder.dto.bmi.BmiCriteriaDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface BmiCriteriaDAO {


    BmiCriteriaDTO findByGenderAndAge(String gender, int age);


}
