package com.carefinder.dao.height;

import com.carefinder.dto.height.HeightDTO;
import com.carefinder.dto.child.ChildDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface HeightDAO {

    // ==========================
    // 키 목록 조회
    // ==========================

    // 본인 키 기록 (childId = null)
    List<HeightDTO> findByMno(@Param("mno") Long mno);

    // 자녀 키 기록
    List<HeightDTO> findByChildId(
            @Param("mno") Long mno,
            @Param("childId") Integer childId
    );

    // ==========================
    // 단건 조회 (수정용)
    // ==========================
    HeightDTO findById(@Param("heightId") Long heightId);

    // ==========================
    // CUD
    // ==========================
    void insert(HeightDTO dto);

    void update(HeightDTO dto);

    void delete(@Param("heightId") Long heightId);

    // ==========================
    // 자녀 목록 (childSelect 재사용)
    // ==========================
    List<ChildDTO> getChildList(@Param("mno") Long mno);

    List<HeightDTO> findByMnoWithDate(
            @Param("mno") Long mno,
            @Param("startDate") String startDate,
            @Param("endDate") String endDate
    );

    List<HeightDTO> findByChildIdWithDate(
            @Param("mno") Long mno,
            @Param("childId") Integer childId,
            @Param("startDate") String startDate,
            @Param("endDate") String endDate
    );

}
