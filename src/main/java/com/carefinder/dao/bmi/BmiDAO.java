package com.carefinder.dao.bmi;

import com.carefinder.dto.bmi.BmiDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface BmiDAO {

    // ==========================
    //  BMI 저장
    // ==========================
    void insert(BmiDTO dto);

    // ==========================
    // 회원 + 자녀 기준 전체 조회
    // ==========================
    List<BmiDTO> findByChild(
            @Param("mno") Long mno,
            @Param("childId") Integer childId
    );

    // ==========================
    // 회원 + 자녀 + 날짜 범위 조회
    // ==========================
    List<BmiDTO> findByDateRangeAndChild(
            @Param("mno") Long mno,
            @Param("childId") Integer childId,
            @Param("startDate") String startDate,
            @Param("endDate") String endDate
    );


    // ==========================
    //  BMI  삭제
    // ==========================
    void deleteByBmiNo(@Param("bmiNo") Long bmiNo);

    BmiDTO findById(@Param("bmiNo") Long bmiNo);

    void update(BmiDTO dto);

    BmiDTO findLatestByChildId(Integer childId);
}
