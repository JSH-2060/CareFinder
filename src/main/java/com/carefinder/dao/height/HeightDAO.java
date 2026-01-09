package com.carefinder.dao.height;

import com.carefinder.dto.height.HeightDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface HeightDAO {

    // 키 기록 추가
    void insert(HeightDTO dto);

    // 아이별 키 목록 조회
    List<HeightDTO> findByChildId(@Param("childId") int childId);

    // 키 기록 수정
    void update(HeightDTO dto);

    // 키 기록 삭제
    void delete(@Param("heightId") Long heightId);
}
